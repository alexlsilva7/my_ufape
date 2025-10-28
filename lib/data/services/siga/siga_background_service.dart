import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/repositories/academic_achievement/academic_achievement_repository.dart';
import 'package:my_ufape/data/repositories/school_history/school_history_repository.dart';
import 'package:my_ufape/domain/entities/time_table.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/data/repositories/block_of_profile/block_of_profile_repository.dart';
import 'package:my_ufape/data/repositories/scheduled_subject/scheduled_subject_repository.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:my_ufape/data/parsers/profile_parser.dart';
import 'package:my_ufape/data/services/siga/siga_scripts.dart';
import 'package:my_ufape/domain/entities/user.dart';
import 'package:my_ufape/data/repositories/user/user_repository.dart';

/// Exceção lançada quando uma sincronização é tentada enquanto outra está em andamento
class SyncInProgressException implements Exception {
  final String message;
  SyncInProgressException(this.message);

  @override
  String toString() => message;
}

/// Serviço que mantém um WebViewController em memória
/// para manter a sessão SIGA viva e expor métodos de extração.
/// A classe agora permite múltiplas instâncias (ex: uma para background sync
/// e outra para uso pela UI/WebView). Use `injector.get<SigaBackgroundService>(key: '<key>')`.
class SigaBackgroundService extends ChangeNotifier {
  SigaBackgroundService();

  final SettingsRepository _settings = injector.get();
  final SubjectRepository _subjectRepository = injector.get();
  final SubjectNoteRepository _subjectNoteRepository = injector.get();
  final BlockOfProfileRepository _blockRepository = injector.get();
  final ScheduledSubjectRepository _scheduledSubjectRepository = injector.get();
  final UserRepository _userRepository = injector.get();
  final SchoolHistoryRepository _schoolHistoryRepository = injector.get();
  final AcademicAchievementRepository _achievementRepository = injector.get();

  WebViewController? _controller;
  WebViewController? get controller => _controller;

  // Completer para o fluxo de login ativo
  Completer<bool>? _loginCompleter;

  // Notificador para falhas de autenticação em segundo plano
  final ValueNotifier<bool> _authFailureNotifier = ValueNotifier(false);
  ValueListenable<bool> get authFailureNotifier => _authFailureNotifier;

  // Credenciais obtidas do repositório e usadas para tentar login quando a página de login terminar de carregar
  String? _pendingUsername;
  String? _pendingPassword;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  set isSyncing(bool value) {
    if (_isSyncing != value) {
      _isSyncing = value;
      notifyListeners();
    }
  }

  String statusMessage = '';

  String _syncStatusMessage = '';
  String get syncStatusMessage => _syncStatusMessage;

  String? _currentSyncOperation;
  String? get currentSyncOperation => _currentSyncOperation;

  /// Tenta adquirir o lock de sincronização
  /// Retorna true se conseguiu, false se já está sincronizando
  bool _acquireSyncLock(String operationName) {
    if (_isSyncing) {
      logarte.log(
          'Sync lock denied: $_currentSyncOperation already in progress',
          source: 'SigaBackgroundService');
      return false;
    }

    _isSyncing = true;
    _currentSyncOperation = operationName;
    _syncStatusMessage = 'Iniciando $operationName...';
    notifyListeners();
    logarte.log('Sync lock acquired for: $operationName');
    return true;
  }

  /// Libera o lock de sincronização
  void _releaseSyncLock() {
    final operation = _currentSyncOperation;
    _isSyncing = false;
    _currentSyncOperation = null;
    _syncStatusMessage = '';
    notifyListeners();
    logarte.log('Sync lock released for: $operation');
  }

  void _updateSyncStatus(String message) {
    _syncStatusMessage = message;
    notifyListeners();
  }

  Timer? _statusTimer;

  final ValueNotifier<bool> loginNotifier = ValueNotifier(false);

  // Reconexão automática: tentativas exponenciais quando detectamos logout inesperado
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectBaseDelay = const Duration(seconds: 5);

  /// Realiza a sincronização automática se as condições forem atendidas.
  Future<void> performAutomaticSyncIfNeeded(
      {Duration syncInterval = const Duration(hours: 1)}) async {
    // 1. Verifica se a funcionalidade está habilitada pelo usuário
    if (!_settings.isAutoSyncEnabled) {
      logarte.log('Auto-sync is disabled by the user.');
      return;
    }

    // 2. Verifica se o usuário está logado no SIGA
    if (!isLoggedIn) {
      logarte.log('Not logged in. Skipping auto-sync.');
      return;
    }

    // 3. Define o intervalo mínimo para a sincronização (ex: 1 hora)
    final lastSync =
        DateTime.fromMillisecondsSinceEpoch(_settings.lastSyncTimestamp);
    final now = DateTime.now();

    // 4. Verifica se o tempo desde a última sincronização é maior que o intervalo
    if (now.difference(lastSync) < syncInterval) {
      logarte.log(
          'Skipping auto-sync. Last sync was less than ${syncInterval.inHours} hours ago.');
      return;
    }

    logarte.log('Starting automatic background sync...');
    isSyncing = true;

    try {
      await _runSync();
    } catch (e) {
      logarte.log('Automatic sync failed: $e');
    }
  }

  Future<void> _runSync() async {
    try {
      await navigateAndExtractGrades(); // cheque interno de isSyncing/tokens
      await goToHome();
      await Future.delayed(const Duration(seconds: 1));
      await navigateAndExtractTimetable();
      await goToHome();
      await navigateAndExtractSchoolHistory();
      //await _settings.updateLastSyncTimestamp();
    } finally {
      goToHome();
      isSyncing = false;
    }
  }

  /// Inicializa o WebViewController e começa o timer de verificação de sessão.
  Future<void> initialize() async {
    if (_controller != null) return;

    statusMessage = 'Inicializando webview';
    notifyListeners();

    // Cria o controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            statusMessage = 'Carregando';
            notifyListeners();
          },
          onPageFinished: (url) async {
            statusMessage = '';
            notifyListeners();

            // Injeta script global de supressão de erros em todas as páginas do SIGA
            if (url.contains('siga.ufape.edu.br')) {
              try {
                await _controller
                    ?.runJavaScript(SigaScripts.suppressSigaErrorsScript);
              } catch (e) {
                // Ignora falhas na injeção do script de supressão
              }
            }

            if (url.contains('siga.ufape.edu.br/ufape/index.jsp')) {
              try {
                // Aplica estilos e supressão de erros do console
                await _controller
                    ?.runJavaScript(SigaScripts.loginPageStylesScript);
              } catch (e) {
                // Ignora erros de script de estilo para não quebrar a funcionalidade
                // Erros comuns do SIGA (jQuery Cycle, etc) são esperados e não afetam o login
                logarte.log(
                  'Aviso: Erro ao aplicar estilos na página de login (não crítico): $e',
                  source: 'SigaBackgroundService',
                );
              }
            }

            // Tenta injetar o script de login se houver credenciais pendentes.
            // Isso é acionado tanto pelo login ativo quanto pelo automático.
            if (url.contains('index.jsp') &&
                !_isLoggedIn &&
                _pendingUsername != null &&
                _pendingPassword != null) {
              await _injectLoginScript(_pendingUsername!, _pendingPassword!);
              _pendingUsername = null;
              _pendingPassword = null;
            }

            // Sempre verifica o status após a página carregar
            await _checkLoginStatus();
          },
          onWebResourceError: (err) {
            statusMessage = 'Erro ao carregar recurso';
            notifyListeners();
            // Se houver um login ativo em andamento, falha.
            if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
              _loginCompleter!.complete(false);
            }
          },
          onUrlChange: (UrlChange change) {
            final url = change.url;
            if (url != null && _isLoggedIn && url.contains('index.jsp')) {
              if (_isLoggedIn) {
                _isLoggedIn = false;
                loginNotifier.value = false;
                notifyListeners();
                _scheduleReconnect();
              }
            }
          },
        ),
      );

    // Carrega a página inicial do SIGA
    await _controller!.loadRequest(
      Uri.parse('https://siga.ufape.edu.br/ufape/index.jsp'),
    );

    // Inicia timer periódico para verificar status de login
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _checkLoginStatus();
    });

    // Obtém credenciais para o login automático em segundo plano.
    final creds = await _settings.getUserCredentials();
    creds.fold((login) {
      _pendingUsername = login.username;
      _pendingPassword = login.password;
    }, (error) {
      // sem credenciais armazenadas
    });
  }

  /// Realiza um login ativo, aguardando o resultado.
  Future<bool> login(String username, String password) async {
    _loginCompleter = Completer<bool>();

    _pendingUsername = username;
    _pendingPassword = password;

    // Força o recarregamento da página de login para acionar o onPageFinished
    await _controller?.loadRequest(
      Uri.parse('https://siga.ufape.edu.br/ufape/index.jsp'),
    );

    try {
      final result =
          await _loginCompleter!.future.timeout(const Duration(seconds: 10));
      _loginCompleter = null; // Limpa o completer após o uso
      return result;
    } catch (e) {
      // Garante que o completer seja finalizado e limpo em caso de erro/timeout
      if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
        _loginCompleter!.complete(false);
      }
      _loginCompleter = null;
      return false;
    }
  }

  void resetAuthFailure() {
    _authFailureNotifier.value = false;
  }

  Future<void> goToHome() async {
    if (_controller == null) return;
    try {
      //clicar <a id="menuTopo:imageHome" name="menuTopo:imageHome" href="javascript: paginaInicial();" title="Ir para a página inicial" class="botaoHome">Início</a>
      await _controller!
          .runJavaScriptReturningResult(SigaScripts.scriptGoHome());
    } catch (_) {}
  }

  /// Limpa recursos do serviço
  Future<void> disposeService() async {
    _statusTimer?.cancel();
    _statusTimer = null;
    _controller = null;
    try {
      loginNotifier.dispose();
      _authFailureNotifier.dispose();
    } catch (_) {}
    // Não chamar notifyListeners depois do dispose
  }

  @override
  void dispose() {
    // 1. Cancela timers PRIMEIRO
    _cancelReconnectTimer();
    _statusTimer?.cancel();
    _statusTimer = null;

    // 2. Completa pendings
    if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
      _loginCompleter!.complete(false);
    }
    _loginCompleter = null;

    // 3. Dispose dos notifiers
    loginNotifier.dispose();
    _authFailureNotifier.dispose();

    // 4. Limpa o controller (não tem dispose mas limpa referência)
    _controller = null;

    // 5. OBRIGATÓRIO: chama super.dispose() por último
    super.dispose();
  }

  Future<void> _injectLoginScript(String username, String password) async {
    final safeUsername =
        username.replaceAll(r'\', r'\\').replaceAll(r"'", r"\'");
    final safePassword =
        password.replaceAll(r'\', r'\\').replaceAll(r"'", r"\'");

    final script = SigaScripts.loginScript(safeUsername, safePassword);

    try {
      await _controller?.runJavaScript(script);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _checkLoginStatus() async {
    if (_controller == null) return;
    try {
      // 1. Verifica se está logado
      final script = SigaScripts.checkLoginScript();
      final result = await _controller!.runJavaScriptReturningResult(script);
      final bool currentlyLoggedIn =
          result == true || result.toString() == 'true';

      // 2. Se não estiver logado, verifica se é por erro de autenticação
      if (!currentlyLoggedIn) {
        final errorScript = SigaScripts.checkAuthErrorScript();
        final authError =
            await _controller!.runJavaScriptReturningResult(errorScript);
        if (authError == true || authError.toString() == 'true') {
          _authFailureNotifier.value = true;
        }
      }

      // 3. Atualiza o estado de login
      if (currentlyLoggedIn != _isLoggedIn) {
        final previous = _isLoggedIn;
        _isLoggedIn = currentlyLoggedIn;
        loginNotifier.value = _isLoggedIn;
        notifyListeners();

        if (_isLoggedIn) {
          // Login bem-sucedido: completar o future do login ativo
          if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
            _loginCompleter!.complete(true);
          }
          _reconnectAttempts = 0;
          _cancelReconnectTimer();
        } else if (previous == true && !_isLoggedIn) {
          // Logout inesperado: programar reconexão
          _scheduleReconnect();
        }
      }
    } catch (e) {
      // Em caso de erro temporário, consideramos deslogado
      if (_isLoggedIn) {
        _isLoggedIn = false;
        loginNotifier.value = false;
        notifyListeners();
        _scheduleReconnect();
      }
      // Se houver um login ativo, falha.
      if (_loginCompleter != null && !_loginCompleter!.isCompleted) {
        _loginCompleter!.complete(false);
      }
    }
  }

  /// Reconecta realizando login com as credenciais salvas
  Future<bool> reconnect() async {
    if (_controller == null) return false;
    final creds = await _settings.getUserCredentials();
    bool success = false;

    await creds.fold(
      (loginData) async {
        // Usar o método login que já existe
        success = await login(loginData.username, loginData.password);
      },
      (error) {
        success = false;
        _authFailureNotifier.value = true; // Sem credenciais, falha permanente
      },
    );

    return success;
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) return;
    _cancelReconnectTimer();
    final int multiplier = 1 << _reconnectAttempts; // 1,2,4,8...
    final int delaySeconds = _reconnectBaseDelay.inSeconds * multiplier;
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () async {
      _reconnectAttempts++;
      try {
        final ok = await reconnect();
        if (!ok) {
          // se não conectado, agendar próxima tentativa se houver tentativas restantes
          if (_reconnectAttempts < _maxReconnectAttempts) {
            _scheduleReconnect();
          }
        }
      } catch (_) {
        if (_reconnectAttempts < _maxReconnectAttempts) {
          _scheduleReconnect();
        }
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Aguarda a página de notas ser carregada (busca pelo botão Imprimir)
  Future<void> _waitForGradesPageReady(
      {Duration timeout = const Duration(seconds: 10)}) async {
    final completer = Completer<void>();
    Timer? timer;
    final stopwatch = Stopwatch()..start();

    const script = """
    (function() {
      const iframe = document.getElementById('Conteudo');
      if (!iframe || !iframe.contentDocument) return false;
      
      const printButton = iframe.contentDocument.querySelector('input[type="button"][value="Imprimir"]');
      
      return printButton != null;
    })();
    """;

    timer = Timer.periodic(const Duration(milliseconds: 50), (t) async {
      if (stopwatch.elapsed > timeout) {
        timer?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(Exception(
              'Tempo esgotado esperando a página de notas carregar.'));
        }
        return;
      }

      try {
        final result = await _controller!.runJavaScriptReturningResult(script);
        if (result == true || result.toString() == 'true') {
          timer?.cancel();
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      } catch (e) {
        // Ignora erros temporários
      }
    });

    return completer.future;
  }

  /// Aguarda a página de informações do discente carregar
  Future<void> _waitForStudentInfoPageReady(
      {Duration timeout = const Duration(seconds: 90)}) async {
    // Timeout aumentado
    final completer = Completer<void>();
    Timer? timer;
    final stopwatch = Stopwatch()..start();

    // Script mais robusto para verificar se a página está pronta
    const script = """
    (function() {
      const iframe = document.getElementById('Conteudo');
      if (!iframe || !iframe.contentDocument) return false;
      const doc = iframe.contentDocument;
      
      // Checa se a tabela principal de informações do cabeçalho já carregou
      const headerTable = doc.getElementById('tableCabecalho');
      if (!headerTable) return false;

      // Checa se as seções expansíveis (sanfona) estão presentes
      const sanfonaLists = doc.querySelectorAll('ul.sanfona');
      if (sanfonaLists.length === 0) return false;
      
      // Confirma a presença de um link específico para ter mais certeza
      const specificLink = Array.from(doc.querySelectorAll('ul.sanfona a'))
                                .some(a => a.innerText.trim().includes('Histórico do Vínculo'));
      
      return specificLink;
    })();
    """;

    timer = Timer.periodic(const Duration(milliseconds: 250), (t) async {
      // Intervalo de verificação ligeiramente maior
      if (stopwatch.elapsed > timeout) {
        timer?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(Exception(
              'Tempo esgotado esperando a página de Informações do Discente carregar.'));
        }
        return;
      }

      try {
        final result = await _controller!.runJavaScriptReturningResult(script);
        if (result == true || result.toString() == 'true') {
          timer?.cancel();
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      } catch (e) {
        // Ignora erros temporários de polling que podem ocorrer durante o carregamento
      }
    });

    return completer.future;
  }

  /// Navega até a página de notas e extrai os dados
  Future<List<SubjectNote>> navigateAndExtractGrades() async {
    if (_controller == null) throw Exception('Controller não inicializado');
    logarte.log('Starting grade extraction from SIGA...');

    // Se já existe uma sincronização global em andamento (ex: Background),
    // não tentamos adquirir o lock novamente para evitar falha por lock.
    bool localLockAcquired = false;
    if (!_isSyncing) {
      if (!_acquireSyncLock('Notas')) {
        throw SyncInProgressException(
            'Sincronização de $_currentSyncOperation já em andamento. '
            'Aguarde a conclusão ou tente novamente em alguns instantes.');
      }
      localLockAcquired = true;
    } else {
      logarte.log(
          'Usando lock existente ($_currentSyncOperation) para extração de notas',
          source: 'SigaBackgroundService');
    }

    // Script para clicar no link de notas dentro do iframe
    const script2 = """
      new Promise((resolve, reject) => {
        const maxTries = 1500;
        let tries = 0;
        const interval = setInterval(() => {
          const iframe = document.getElementsByTagName('iframe')[0];
          let gradesLink;

          if (iframe && iframe.contentDocument) {
            gradesLink = iframe.contentDocument.getElementById('form:repeatTransacoes:3:outputLinkTransacao');
          }
          
          if (gradesLink) {
            clearInterval(interval);
            gradesLink.click();
            resolve('SUCESSO: Botão de notas clicado dentro do iframe.');
            return;
          }

          tries++;
          if (tries >= maxTries) {
            clearInterval(interval);
            reject('ERRO: Tempo esgotado. Botão de notas não encontrado.');
          }
        }, 50);
      });
    """;

    try {
      // 1. Navega para o menu de detalhamento
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptNav());

      // 2. Clica no link de notas
      await _controller!.runJavaScriptReturningResult(script2);

      // 3. Aguarda a página carregar
      await _waitForGradesPageReady(timeout: const Duration(seconds: 30));

      // 5. Extrai as notas
      final grades = await extractGrades();

      // 6. Salva no banco de dados
      for (final grade in grades) {
        await _subjectNoteRepository.upsertSubjectNote(grade);
      }
      logarte
          .log('Grade extraction successful. Found ${grades.length} subjects.');

      return grades;
    } catch (e) {
      logarte.log(
        'Failed to navigate and extract grades: $e, isLoggedIn=$_isLoggedIn',
      );
      throw Exception('Erro ao navegar e extrair notas: $e');
    } finally {
      if (localLockAcquired) _releaseSyncLock();
    }
  }

  /// Executa o script de extração de notas e retorna objetos SubjectNote
  Future<List<SubjectNote>> extractGrades() async {
    if (_controller == null) throw Exception('Controller não inicializado');

    final String script = SigaScripts.extractGradesScript();

    try {
      final jsonResult =
          await _controller!.runJavaScriptReturningResult(script) as String;

      if (jsonResult.isEmpty) {
        throw Exception('Script retornou vazio');
      }

      // Decodifica o resultado (pode vir duplamente codificado)
      dynamic decodedData = jsonDecode(jsonResult);
      if (decodedData is String) {
        decodedData = jsonDecode(decodedData);
      }

      final List<dynamic> decodedList =
          decodedData is List ? decodedData : jsonDecode(decodedData);

      // Verifica se há erro no resultado
      if (decodedList.isNotEmpty &&
          decodedList.first is Map &&
          decodedList.first.containsKey('error')) {
        final errorMessage = decodedList.first['error'];
        throw Exception('Erro no script: $errorMessage');
      }

      // Converte para objetos SubjectNote
      final List<SubjectNote> disciplinas = decodedList
          .map((d) => SubjectNote.fromJson(d as Map<String, dynamic>))
          .toList();

      return disciplinas;
    } catch (e) {
      throw Exception('Erro ao executar/decodificar script: $e');
    }
  }

  /// Aguarda a página de Perfil Curricular dentro do iframe ficar pronta.
  Future<void> _waitForProfilePageReady(
      {Duration timeout = const Duration(seconds: 30)}) async {
    final completer = Completer<void>();
    Timer? timer;
    final stopwatch = Stopwatch()..start();

    final script = SigaScripts.waitForProfilePageReadyScript();

    timer = Timer.periodic(const Duration(milliseconds: 50), (t) async {
      if (stopwatch.elapsed > timeout) {
        timer?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(Exception(
              'Tempo esgotado esperando o Perfil Curricular carregar.'));
        }
        return;
      }

      try {
        final result = await _controller!.runJavaScriptReturningResult(script);
        if (result == true || result.toString() == 'true') {
          timer?.cancel();
          if (!completer.isCompleted) completer.complete();
        } else if (result.toString().startsWith('error')) {
          timer?.cancel();
          if (!completer.isCompleted) {
            completer.completeError(Exception(
                'Não foi possível acessar o conteúdo da página do SIGA.'));
          }
        }
      } catch (e) {
        // Ignora erros temporários
      }
    });

    return completer.future;
  }

  /// Navega e extrai o Perfil Curricular, salvando no banco e retornando os blocos.
  Future<List<BlockOfProfile>> navigateAndExtractProfile() async {
    if (_controller == null) throw Exception('Controller não inicializado');
    logarte.log('Starting profile extraction from SIGA...');

    bool localLockAcquired = false;
    if (!_isSyncing) {
      if (!_acquireSyncLock('Perfil Curricular')) {
        throw SyncInProgressException(
            'Sincronização de $_currentSyncOperation já em andamento. '
            'Aguarde a conclusão ou tente novamente em alguns instantes.');
      }
      localLockAcquired = true;
    } else {
      logarte.log(
          'Usando lock existente ($_currentSyncOperation) para extração de perfil',
          source: 'SigaBackgroundService');
    }

    try {
      // 1. Navega para o menu de detalhamento
      await _controller!.runJavaScript(SigaScripts.scriptNav());

      // 2. Clica em Informações do Discente
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptInfo());

      // 3. Aguarda a página de informações carregar
      await _waitForStudentInfoPageReady();

      // 4. Clica em Perfil Curricular
      await _controller!
          .runJavaScriptReturningResult(SigaScripts.scriptPerfil());

      // 5. Aguarda o perfil carregar
      await _waitForProfilePageReady(timeout: const Duration(seconds: 30));

      // 6. Pequeno delay para garantir renderização
      await Future.delayed(const Duration(milliseconds: 500));

      // 7. Extrai o HTML
      final dynamic htmlResult = await _controller!
          .runJavaScriptReturningResult(SigaScripts.getHtmlScript());
      if (htmlResult == null) throw Exception('Script retornou nulo');

      String htmlContent;
      try {
        final decodedJson = jsonDecode(htmlResult.toString());
        if (decodedJson is Map && decodedJson.containsKey('error')) {
          throw Exception('Erro do script: ${decodedJson['error']}');
        }
        htmlContent =
            decodedJson is String ? decodedJson : htmlResult.toString();
      } catch (_) {
        htmlContent = htmlResult.toString();
      }

      if (htmlContent.isEmpty) throw Exception('Conteudo HTML vazio');

      // 8. Faz o parse do HTML
      final parser = ProfileParser(htmlContent);
      final blocks = parser.parseProfile();

      // 9. Salva no banco de dados
      if (blocks.isNotEmpty) {
        for (final block in blocks) {
          for (final subject in block.subjectList) {
            await _subjectRepository.upsertSubject(subject);
          }
          await _blockRepository.upsertBlock(block);
        }
      }
      logarte
          .log('Profile extraction successful. Found ${blocks.length} blocks.');

      return blocks;
    } catch (e) {
      logarte.log(
        'Failed to navigate and extract profile: $e, isLoggedIn=$_isLoggedIn',
      );
      throw Exception('Erro ao navegar e extrair perfil: $e');
    } finally {
      if (localLockAcquired) _releaseSyncLock();
    }
  }

  Future<void> _waitForTimetablePageReady(
      {Duration timeout = const Duration(seconds: 30)}) async {
    final completer = Completer<void>();
    Timer? timer;
    final stopwatch = Stopwatch()..start();

    final script = SigaScripts.waitForTimetablePageReadyScript();

    timer = Timer.periodic(const Duration(milliseconds: 50), (t) async {
      if (stopwatch.elapsed > timeout) {
        timer?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(Exception(
              'Tempo esgotado esperando a Grade de Horário carregar.'));
        }
        return;
      }

      try {
        final result = await _controller!.runJavaScriptReturningResult(script);
        if (result == true || result.toString() == 'true') {
          timer?.cancel();
          if (!completer.isCompleted) completer.complete();
        }
      } catch (e) {
        // Ignora erros
      }
    });

    return completer.future;
  }

  /// Navega e extrai a Grade de Horário.
  Future<List<ScheduledSubject>> navigateAndExtractTimetable() async {
    if (_controller == null) throw Exception('Controller não inicializado');
    logarte.log('Starting timetable extraction from SIGA...');

    bool localLockAcquired = false;
    if (!_isSyncing) {
      if (!_acquireSyncLock('Grade de Horário')) {
        throw SyncInProgressException(
            'Sincronização de $_currentSyncOperation já em andamento. '
            'Aguarde a conclusão ou tente novamente em alguns instantes.');
      }
      localLockAcquired = true;
    } else {
      logarte.log(
          'Usando lock existente ($_currentSyncOperation) para extração de grade',
          source: 'SigaBackgroundService');
    }

    try {
      // 1. Navega para o menu de detalhamento
      await _controller!.runJavaScript(SigaScripts.scriptNav());

      // 2. Clica em Informações do Discente
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptInfo());

      // 3. Aguarda a página de informações carregar
      await _waitForStudentInfoPageReady();

      // 4. Clica em Grade de Horário
      await _controller!.runJavaScript(SigaScripts.scriptGradeHorario());

      // 5. Aguarda a página da grade carregar
      await _waitForTimetablePageReady();
      await Future.delayed(const Duration(milliseconds: 500));

      // 6. Extrai os dados
      final dynamic jsonResult = await _controller!
          .runJavaScriptReturningResult(SigaScripts.extractTimetableScript());

      if (jsonResult == null || jsonResult.toString().isEmpty) {
        logarte.log('Timetable extraction returned empty result.');
        throw Exception('Script retornou vazio');
      }

      dynamic decodedData;
      if (jsonResult is String) {
        decodedData = jsonDecode(jsonResult);
      } else {
        decodedData = jsonResult; // Já pode ser um Map/List
      }

      if (decodedData is String) {
        decodedData = jsonDecode(decodedData);
      }
      // --- FIM DA CORREÇÃO ---

      logarte.log('Timetable extraction script result: $decodedData');

      // Verifica se o resultado é um objeto de erro
      if (decodedData is Map && decodedData.containsKey('error')) {
        final errorMessage = decodedData['error'];
        logarte.log('Timetable extraction error: $errorMessage');
        throw Exception('Erro no script: $errorMessage');
      }

      final List<dynamic> decodedList = decodedData is List
          ? decodedData
          : jsonDecode(decodedData.toString());

      if (decodedList.isNotEmpty &&
          decodedList.first is Map &&
          decodedList.first.containsKey('error')) {
        final errorMessage = decodedList.first['error'];
        logarte.log('Timetable extraction error: $errorMessage');
        throw Exception('Erro no script: $errorMessage');
      }

      final subjects = decodedList
          .map((d) => ScheduledSubject.fromJson(d as Map<String, dynamic>))
          .toList();

      if (subjects.isNotEmpty) {
        await _scheduledSubjectRepository.deleteAllScheduledSubjects();
      }
      // 7. Salva no banco de dados
      for (final subject in subjects) {
        await _scheduledSubjectRepository.upsertScheduledSubject(subject);
      }
      logarte.log(
          'Timetable extraction successful. Found ${subjects.length} subjects.');

      return subjects;
    } catch (e) {
      logarte.log(
        'Failed to navigate and extract timetable: $e, isLoggedIn=$_isLoggedIn',
      );
      throw Exception('Erro ao navegar e extrair grade de horário: $e');
    } finally {
      if (localLockAcquired) _releaseSyncLock();
    }
  }

  /// Reseta o serviço para o estado inicial, limpando dados e sessão.
  Future<void> resetService() async {
    await disposeService();
    _isLoggedIn = false;
    loginNotifier.value = false;
    _pendingUsername = null;
    _pendingPassword = null;
    _loginCompleter = null;
    _reconnectAttempts = 0;
    _cancelReconnectTimer();
    await disposeService();
    await initialize();
  }

  Future<User> navigateAndExtractUser() async {
    if (_controller == null) throw Exception('Controller não inicializado');
    logarte.log('Starting user data extraction from SIGA...');

    bool localLockAcquired = false;
    if (!_isSyncing) {
      if (!_acquireSyncLock('Dados do Usuário')) {
        throw SyncInProgressException(
            'Sincronização de $_currentSyncOperation já em andamento. '
            'Aguarde a conclusão ou tente novamente em alguns instantes.');
      }
      localLockAcquired = true;
    } else {
      logarte.log(
          'Usando lock existente ($_currentSyncOperation) para extração de dados do usuário',
          source: 'SigaBackgroundService');
    }

    try {
      // 1. Navega para o menu de detalhamento
      await _controller!.runJavaScript(SigaScripts.scriptNav());

      // 2. Clica em Informações do Discente
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptInfo());

      // 3. Aguarda a página de informações carregar
      await _waitForStudentInfoPageReady();

      // 4. Extrai os dados do usuário
      final jsonResult = await _controller!
              .runJavaScriptReturningResult(SigaScripts.extractUserScript())
          as String;

      if (jsonResult.isEmpty) {
        throw Exception('O script de extração de usuário retornou vazio');
      }

      dynamic decodedData = jsonDecode(jsonResult);
      if (decodedData is String) {
        decodedData = jsonDecode(decodedData);
      }

      if (decodedData is Map && decodedData.containsKey('error')) {
        final errorMessage = decodedData['error'];
        throw Exception('Erro no script de extração de usuário: $errorMessage');
      }

      final user = User(
        name: decodedData['name'] ?? '',
        cpf: decodedData['cpf'] ?? '',
        registration: decodedData['registration'] ?? '',
        course: decodedData['course'] ?? '',
        entryPeriod: decodedData['entryPeriod'] ?? '',
        entryType: decodedData['entryType'] ?? '',
        profile: decodedData['profile'] ?? '',
        shift: decodedData['shift'] ?? '',
        situation: decodedData['situation'] ?? '',
        currentPeriod: decodedData['currentPeriod'] ?? '',
      );

      // 5. Salva no banco de dados
      await _userRepository.upsertUser(user);
      logarte.log('User data extraction successful for ${user.name}.');

      return user;
    } catch (e) {
      logarte.log(
        'Failed to navigate and extract user data: $e, isLoggedIn=$_isLoggedIn',
      );
      throw Exception('Erro ao navegar e extrair dados do usuário: $e');
    } finally {
      if (localLockAcquired) _releaseSyncLock();
    }
  }

  Future<void> navigateAndExtractSchoolHistory() async {
    bool localLockAcquired = false;
    if (!_isSyncing) {
      if (!_acquireSyncLock('Histórico Escolar')) {
        throw SyncInProgressException(
            'Sincronização de $_currentSyncOperation já em andamento. '
            'Aguarde a conclusão ou tente novamente em alguns instantes.');
      }
      localLockAcquired = true;
    } else {
      logarte.log(
          'Usando lock existente ($_currentSyncOperation) para extração de histórico',
          source: 'SigaBackgroundService');
    }

    try {
      if (_controller == null) throw Exception('Controller not initialized');
      logarte.log('Starting school history extraction from SIGA...');

      _updateSyncStatus('Navegando para o menu...');
      await _controller!.runJavaScript(SigaScripts.scriptNav());

      _updateSyncStatus('Acessando informações do discente...');
      logarte.log('Clicando em "Informações do Discente"...',
          source: 'SigaService');
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptInfo());

      logarte.log('Aguardando a página "Informações do Discente" carregar...',
          source: 'SigaService');
      await _waitForStudentInfoPageReady();
      logarte.log('Página "Informações do Discente" carregada com sucesso.',
          source: 'SigaService');

      _updateSyncStatus('Abrindo histórico escolar...');
      await _controller!
          .runJavaScriptReturningResult(SigaScripts.scriptHistoricoEscolar());
      await _waitForSchoolHistoryPageReady();
      await Future.delayed(const Duration(milliseconds: 500));

      _updateSyncStatus('Extraindo dados do histórico...');
      final jsonResult = await _controller!.runJavaScriptReturningResult(
          SigaScripts.extractSchoolHistoryScript());

      dynamic decodedData = jsonDecode(jsonResult.toString());
      if (decodedData is String) {
        decodedData = jsonDecode(decodedData);
      }

      // Verificação aprimorada de erros e logs
      if (decodedData is Map && decodedData.containsKey('error')) {
        final errorMessage = decodedData['error'];
        final errorLogs = decodedData['logs'] as List<dynamic>? ?? [];

        logarte.log('Erro no script de extração do Histórico: $errorMessage',
            source: 'SIGA BG - School History');

        if (errorLogs.isNotEmpty) {
          logarte.log('--- Logs de Execução do Script ---',
              source: 'SIGA BG - School History');
          for (var log in errorLogs) {
            logarte.log(log.toString(), source: 'JS');
          }
          logarte.log('--- Fim dos Logs ---',
              source: 'SIGA BG - School History');
        }

        throw Exception(errorMessage);
      }

      if (decodedData['periods'] is String) {
        decodedData['periods'] = jsonDecode(decodedData['periods']);
      }

      _updateSyncStatus('Salvando histórico no banco de dados...');
      await _schoolHistoryRepository.upsertFromSiga(decodedData);

      _updateSyncStatus('Atualizando dados do usuário...');
      final userResult = await _userRepository.getUser();
      userResult.fold((user) async {
        user.overallAverage =
            (decodedData['overallAverage'] as num?)?.toDouble();
        user.overallCoefficient =
            (decodedData['overallCoefficient'] as num?)?.toDouble();
        await _userRepository.upsertUser(user);
      }, (error) => null);

      _updateSyncStatus('Sincronização concluída!');
      logarte.log('School history extraction successful.');
      await goToHome();
    } catch (e) {
      logarte.log(
        'Failed to navigate and extract school history: $e',
      );
      await goToHome();
      throw Exception('Error navigating and extracting history: $e');
    } finally {
      if (localLockAcquired) _releaseSyncLock();
    }
  }

  Future<void> _waitForSchoolHistoryPageReady(
      {Duration timeout = const Duration(seconds: 10)}) async {
    final completer = Completer<void>();
    Timer? timer;
    final stopwatch = Stopwatch()..start();

    final script = SigaScripts.waitForSchoolHistoryPageReadyScript();

    timer = Timer.periodic(const Duration(milliseconds: 250), (t) async {
      if (stopwatch.elapsed > timeout) {
        timer?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
              Exception('Timeout waiting for school history page.'));
        }
        return;
      }

      try {
        final result = await _controller!.runJavaScriptReturningResult(script);
        if (result == true || result.toString() == 'true') {
          timer?.cancel();
          if (!completer.isCompleted) completer.complete();
        }
      } catch (e) {
        // Ignore temporary errors
      }
    });

    return completer.future;
  }

  Future<Map<String, dynamic>> navigateAndExtractAcademicAchievement() async {
    if (_controller == null) throw Exception('Controller not initialized');
    logarte.log('Starting academic achievement extraction from SIGA...');

    bool localLockAcquired = false;
    if (!_isSyncing) {
      if (!_acquireSyncLock('Aproveitamento Acadêmico')) {
        throw SyncInProgressException(
            'Sincronização de $_currentSyncOperation já em andamento. '
            'Aguarde a conclusão ou tente novamente em alguns instantes.');
      }
      localLockAcquired = true;
    } else {
      logarte.log(
          'Usando lock existente ($_currentSyncOperation) para aproveitamento acadêmico',
          source: 'SigaBackgroundService');
    }

    try {
      // 1. Navegação (sem alterações)
      await _controller!.runJavaScript(SigaScripts.scriptNav());
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptInfo());
      await _waitForStudentInfoPageReady();
      await _controller!.runJavaScriptReturningResult(
          SigaScripts.scriptAproveitamentoAcademico());
      await _waitForAcademicAchievementPageReady();
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Extração e Decodificação Robusta
      final dynamic jsResult = await _controller!.runJavaScriptReturningResult(
          SigaScripts.extractAcademicAchievementScript());

      if (jsResult == null || jsResult.toString().isEmpty) {
        throw Exception('Script retornou resultado vazio ou nulo.');
      }

      String jsonString = jsResult.toString();
      dynamic decodedData;

      try {
        decodedData = jsonDecode(jsonString);
        // Trata possível dupla codificação
        if (decodedData is String) {
          decodedData = jsonDecode(decodedData);
        }
      } catch (e) {
        throw Exception(
            'Falha ao decodificar JSON do script: $e\nJSON recebido: $jsonString');
      }

      // Garante que decodedData seja um Map
      if (decodedData is! Map<String, dynamic>) {
        throw Exception(
            'Resultado decodificado não é um mapa válido. Tipo: ${decodedData.runtimeType}');
      }

      // Verifica erro retornado pelo script
      if (decodedData.containsKey('error')) {
        throw Exception('Erro retornado pelo script: ${decodedData['error']}');
      }

      // --- VERIFICAÇÃO E CONVERSÃO SEGURA ---

      // Workload Summary
      dynamic workloadSummaryData = decodedData['workload_summary'];
      if (workloadSummaryData is String) {
        // Se for string, tenta decodificar
        try {
          workloadSummaryData = jsonDecode(workloadSummaryData);
        } catch (e) {
          logarte.log("Erro ao decodificar workload_summary string: $e",
              source: "SIGA Service");
          throw Exception(
              'Formato inválido para workload_summary (string não decodificável).');
        }
      }

      if (workloadSummaryData is String) {
        // Se for string, tenta decodificar
        try {
          workloadSummaryData = jsonDecode(workloadSummaryData);
        } catch (e) {
          logarte.log("Erro ao decodificar workload_summary string: $e",
              source: "SIGA Service");
          throw Exception(
              'Formato inválido para workload_summary (string não decodificável).');
        }
      }

      if (workloadSummaryData is! List) {
        // Verifica se agora é lista
        logarte.log(
            "Tipo inesperado para workload_summary: ${workloadSummaryData.runtimeType}");
        logarte.log("Conteúdo: $workloadSummaryData");
        throw Exception(
            'Formato inesperado para workload_summary: esperado List, recebido ${workloadSummaryData.runtimeType}');
      }
      final flatWorkloadList =
          (workloadSummaryData).cast<Map<String, dynamic>>();

      // Component Summary
      dynamic componentSummaryData = decodedData['component_summary'];
      if (componentSummaryData is String) {
        try {
          componentSummaryData = jsonDecode(componentSummaryData);
        } catch (e) {
          logarte.log("Erro ao decodificar component_summary string: $e",
              source: "SIGA Service");
          throw Exception(
              'Formato inválido para component_summary (string não decodificável).');
        }
      }
      if (componentSummaryData is! List) {
        try {
          componentSummaryData = jsonDecode(componentSummaryData.toString());
        } catch (e) {
          logarte.log(
              "Tipo inesperado para component_summary: ${componentSummaryData.runtimeType}");
          logarte.log("Conteúdo: $componentSummaryData");
          throw Exception(
              'Formato inesperado para component_summary: esperado List, recebido ${componentSummaryData.runtimeType}');
        }
      }

      final componentSummaryList =
          (componentSummaryData).cast<Map<String, dynamic>>();
      // Atualiza decodedData para garantir que o tipo está correto para o repositório
      decodedData['component_summary'] = componentSummaryList;

      // Pending Components
      dynamic pendingComponentsData = decodedData['pending_components'];
      if (pendingComponentsData is String) {
        try {
          pendingComponentsData = jsonDecode(pendingComponentsData);
        } catch (e) {
          logarte.log("Erro ao decodificar pending_components string: $e",
              source: "SIGA Service");
          throw Exception(
              'Formato inválido para pending_components (string não decodificável).');
        }
      }
      if (pendingComponentsData is! Map<String, dynamic>) {
        logarte.log(
            "Tipo inesperado para pending_components: ${pendingComponentsData.runtimeType}");
        logarte.log("Conteúdo: $pendingComponentsData");
        throw Exception(
            'Formato inesperado para pending_components: esperado Map, recebido ${pendingComponentsData.runtimeType}');
      }
      // Trata 'subjects' dentro de pending_components
      dynamic subjectsData = pendingComponentsData['subjects'];
      if (subjectsData is String) {
        try {
          subjectsData = jsonDecode(subjectsData);
        } catch (e) {
          logarte.log(
              "Erro ao decodificar pending_components['subjects'] string: $e",
              source: "SIGA Service");
          throw Exception(
              'Formato inválido para pending_components["subjects"] (string não decodificável).');
        }
      }
      if (subjectsData is! List) {
        try {
          subjectsData = jsonDecode(subjectsData.toString());
        } catch (e) {
          logarte.log(
              "Tipo inesperado para pending_components['subjects']: ${subjectsData.runtimeType}");
          logarte.log("Conteúdo: $subjectsData");
          throw Exception(
              'Formato inesperado para pending_components["subjects"]: esperado List, recebido ${subjectsData.runtimeType}');
        }
      }
      pendingComponentsData['subjects'] = (subjectsData)
          .cast<Map<String, dynamic>>(); // Garante a tipagem correta

      // Atualiza decodedData
      decodedData['pending_components'] = pendingComponentsData;

      // --- Construção da Árvore (sem alterações, usa flatWorkloadList) ---
      final Map<String, Map<String, dynamic>> itemsById = {
        for (var item in flatWorkloadList)
          (item['id'] as String): item..['children'] = []
      };
      final List<Map<String, dynamic>> tree = [];
      for (var item in flatWorkloadList) {
        final parentId = item['parentId'];
        if (parentId != null && itemsById.containsKey(parentId as String)) {
          (itemsById[parentId]!['children'] as List).add(item);
        } else {
          tree.add(item);
        }
      }
      decodedData['workload_summary_tree'] = tree;
      decodedData['workload_summary_flat'] =
          flatWorkloadList; // Opcional, se precisar da lista plana

      // 3. Salva no Repositório (Passa decodedData ajustado)
      await _achievementRepository.upsertFromSiga(decodedData);

      logarte.log('Academic achievement extraction successful.');
      goToHome();
      return decodedData; // Retorna os dados processados
    } catch (e) {
      logarte.log('Failed to navigate and extract academic achievement: $e');
      goToHome(); // Tenta voltar para home mesmo em erro
      throw Exception(
          'Error navigating and extracting academic achievement: $e');
    } finally {
      if (localLockAcquired) _releaseSyncLock();
    }
  }

  Future<void> _waitForAcademicAchievementPageReady(
      {Duration timeout = const Duration(seconds: 10)}) async {
    final completer = Completer<void>();
    Timer? timer;
    final stopwatch = Stopwatch()..start();

    final script = SigaScripts.waitForAcademicAchievementPageReadyScript();

    timer = Timer.periodic(const Duration(milliseconds: 50), (t) async {
      if (stopwatch.elapsed > timeout) {
        timer?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
              Exception('Timeout waiting for academic achievement page.'));
        }
        return;
      }

      try {
        final result = await _controller!.runJavaScriptReturningResult(script);
        if (result == true || result.toString() == 'true') {
          timer?.cancel();
          if (!completer.isCompleted) completer.complete();
        }
      } catch (e) {
        // Ignora erros temporários
      }
    });

    return completer.future;
  }

  /// Executa uma sincronização completa em segundo plano.
  /// Tenta fazer login com credenciais salvas e extrai todos os dados.
  Future<void> runFullBackgroundSync() async {
    if (!_settings.isAutoSyncEnabled ||
        !(await _settings.isInitialSyncCompleted())) {
      logarte.log(
          'Background Sync: Sincronização automática desativada ou inicial não concluída. Abortando.',
          source: 'SigaBackgroundService');
      return;
    }
    // Verifica se já está sincronizando ANTES de qualquer operação
    (await _userRepository.getUser()).fold((user) async {
      user.lastBackgroundSync = DateTime.now();
      await _userRepository.upsertUser(user);
    }, (error) {
      logarte.log('Erro ao obter usuário atual: $error',
          source: 'SigaBackgroundService');
    });

    if (_isSyncing) {
      logarte.log(
          'Background Sync: Sincronização já em andamento ($_currentSyncOperation). Abortando chamada duplicada.',
          source: 'SigaBackgroundService');
      throw SyncInProgressException(
          'Sincronização de $_currentSyncOperation já em andamento. '
          'Aguarde a conclusão ou tente novamente em alguns instantes.');
    }

    // Garante que o serviço e o controller da webview estejam prontos.
    await initialize();

    // Aguarda um tempo para a tentativa de login automática inicial.
    await Future.delayed(const Duration(seconds: 15));

    if (!isLoggedIn) {
      logarte.log('Background Sync: Não está logado. Tentando reconectar...',
          source: 'SigaBackgroundService');
      final success = await reconnect();
      if (!success) {
        logarte.log('Background Sync: Falha na reconexão. Abortando.',
            source: 'SigaBackgroundService');
        return;
      }
      // Aguarda a página carregar após a reconexão.
      await Future.delayed(const Duration(seconds: 10));
    }

    if (!_acquireSyncLock('Sincronização em Background')) {
      logarte.log(
          'Background Sync: Não foi possível iniciar, outra sincronização já está em andamento.',
          source: 'SigaBackgroundService');
      throw SyncInProgressException(
          'Sincronização de $_currentSyncOperation já em andamento. '
          'Aguarde a conclusão ou tente novamente em alguns instantes.');
    }

    try {
      logarte.log('Iniciando extração de dados em background...',
          source: 'SigaBackgroundService');

      _updateSyncStatus('Sincronizando notas...');
      await navigateAndExtractGrades();
      await goToHome();
      await Future.delayed(const Duration(seconds: 1));

      _updateSyncStatus('Sincronizando horário...');
      await navigateAndExtractTimetable();
      await goToHome();
      await Future.delayed(const Duration(seconds: 1));

      _updateSyncStatus('Sincronizando histórico...');
      await navigateAndExtractSchoolHistory();
      await goToHome();
      await Future.delayed(const Duration(seconds: 1));

      _updateSyncStatus('Sincronizando perfil...');
      await navigateAndExtractProfile();

      _updateSyncStatus('Sincronização em background concluída.');
      logarte.log(
          'Sincronização completa em background finalizada com sucesso.',
          source: 'SigaBackgroundService');
    } catch (e) {
      logarte.log('A sincronização completa em background falhou: $e',
          source: 'SigaBackgroundService');
    } finally {
      await goToHome();
      _releaseSyncLock();
    }
  }
}
