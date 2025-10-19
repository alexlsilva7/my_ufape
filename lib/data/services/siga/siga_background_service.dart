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
// ignore: depend_on_referenced_packages
import 'package:async/async.dart';

/// Serviço singleton que mantém um WebViewController em memória
/// para manter a sessão SIGA viva e expor métodos de extração.
/// Use `injector.get<SigaBackgroundService>()` para obter a instância.
class SigaBackgroundService extends ChangeNotifier {
  static SigaBackgroundService? _instance;

  factory SigaBackgroundService() {
    _instance ??= SigaBackgroundService._();
    return _instance!;
  }

  SigaBackgroundService._();

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

  Timer? _statusTimer;

  final ValueNotifier<bool> loginNotifier = ValueNotifier(false);

  // Reconexão automática: tentativas exponenciais quando detectamos logout inesperado
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectBaseDelay = const Duration(seconds: 5);

  CancelableOperation<void>? _syncOp;

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

    _syncOp = CancelableOperation.fromFuture(_runSync(), onCancel: () async {
      // Sinaliza fim e faz limpeza
      isSyncing = false;
      _reconnectTimer?.cancel();
      _statusTimer?.cancel();
    });

    try {
      await _syncOp!.value;
    } catch (e) {
      logarte.log('Automatic sync failed: $e');
    } finally {
      _syncOp = null;
      // _cts = null;
    }
  }

  Future<void> _runSync() async {
    try {
      if (!isSyncing) return;
      await navigateAndExtractGrades(); // cheque interno de isSyncing/tokens
      if (!isSyncing) return;
      await goToHome();
      if (!isSyncing) return;
      await Future.delayed(const Duration(seconds: 2));
      if (!isSyncing) return;
      await navigateAndExtractTimetable();
      if (!isSyncing) return;
      await goToHome();
      if (!isSyncing) return;
      await navigateAndExtractSchoolHistory();
      if (!isSyncing) return;
      await _settings.updateLastSyncTimestamp();
    } finally {
      goToHome();
      isSyncing = false;
    }
  }

  Future<void> cancelSync() async {
    isSyncing = false;
    if (_syncOp != null) {
      await _syncOp!.cancel();
      _syncOp = null;
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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            statusMessage = 'Carregando';
            notifyListeners();
          },
          onPageFinished: (url) async {
            statusMessage = '';
            notifyListeners();

            if (url.contains('siga.ufape.edu.br/ufape/index.jsp')) {
              try {
                await _controller
                    ?.runJavaScript(SigaScripts.loginPageStylesScript);
              } catch (e) {
                // Ignora erros de script de estilo para não quebrar a funcionalidade
                if (kDebugMode) {
                  print('Erro ao aplicar estilos na página de login: $e');
                }
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
          await _loginCompleter!.future.timeout(const Duration(seconds: 30));
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
      {Duration timeout = const Duration(seconds: 30)}) async {
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

    timer = Timer.periodic(const Duration(milliseconds: 250), (t) async {
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
      {Duration timeout = const Duration(seconds: 30)}) async {
    final completer = Completer<void>();
    Timer? timer;
    final stopwatch = Stopwatch()..start();

    const script = """
    (function() {
      const iframe = document.getElementById('Conteudo');
      if (iframe && iframe.contentDocument) {
        const sanfonaLinks = iframe.contentDocument.querySelectorAll('ul.sanfona a');
        for(let i = 0; i < sanfonaLinks.length; i++) {
          if(sanfonaLinks[i].innerText.trim() === 'Perfil Curricular') {
            return true;
          }
        }
      }
      return false;
    })();
    """;

    timer = Timer.periodic(const Duration(milliseconds: 250), (t) async {
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
        // Ignora erros temporários
      }
    });

    return completer.future;
  }

  /// Navega até a página de notas e extrai os dados
  Future<List<SubjectNote>> navigateAndExtractGrades() async {
    if (_controller == null) throw Exception('Controller não inicializado');
    logarte.log('Starting grade extraction from SIGA...');

    // Script para clicar no link de notas dentro do iframe
    const script2 = """
      new Promise((resolve, reject) => {
        const maxTries = 40;
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
        }, 250);
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

    try {
      // 1. Navega para o menu de detalhamento
      await _controller!.runJavaScript(SigaScripts.scriptNav());

      // 2. Clica em Informações do Discente
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptInfo());

      // 3. Aguarda a página de informações carregar
      await _waitForStudentInfoPageReady(timeout: const Duration(seconds: 30));

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
    }
  }

  Future<void> navigateAndExtractSchoolHistory() async {
    if (_controller == null) throw Exception('Controller not initialized');
    logarte.log('Starting school history extraction from SIGA...');

    try {
      await _controller!.runJavaScript(SigaScripts.scriptNav());
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptInfo());
      await _waitForStudentInfoPageReady();
      await _controller!
          .runJavaScriptReturningResult(SigaScripts.scriptHistoricoEscolar());
      await _waitForSchoolHistoryPageReady();
      await Future.delayed(const Duration(milliseconds: 500));

      final jsonResult = await _controller!.runJavaScriptReturningResult(
          SigaScripts.extractSchoolHistoryScript());

      dynamic decodedData = jsonDecode(jsonResult.toString());
      if (decodedData is String) {
        decodedData = jsonDecode(decodedData);
      }

      if (decodedData is Map && decodedData.containsKey('error')) {
        logarte.log('Script error: ${decodedData['error']}',
            source: 'SIGA BG - School History');
        throw Exception('Script error: ${decodedData['error']}');
      }

      if (decodedData['periods'] is String) {
        decodedData['periods'] = jsonDecode(decodedData['periods']);
      }
      await _schoolHistoryRepository.upsertFromSiga(decodedData);

      final userResult = await _userRepository.getUser();
      userResult.fold((user) async {
        user.overallAverage =
            (decodedData['overallAverage'] as num?)?.toDouble();
        user.overallCoefficient =
            (decodedData['overallCoefficient'] as num?)?.toDouble();
        await _userRepository.upsertUser(user);
      }, (error) => null);

      logarte.log('School history extraction successful.');
      goToHome();
    } catch (e) {
      logarte.log(
        'Failed to navigate and extract school history: $e',
      );
      goToHome();
      throw Exception('Error navigating and extracting history: $e');
    }
  }

  Future<void> _waitForSchoolHistoryPageReady(
      {Duration timeout = const Duration(seconds: 30)}) async {
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
        logarte.log(
            "Tipo inesperado para component_summary: ${componentSummaryData.runtimeType}");
        logarte.log("Conteúdo: $componentSummaryData");
        throw Exception(
            'Formato inesperado para component_summary: esperado List, recebido ${componentSummaryData.runtimeType}');
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
        logarte.log(
            "Tipo inesperado para pending_components['subjects']: ${subjectsData.runtimeType}");
        logarte.log("Conteúdo: $subjectsData");
        throw Exception(
            'Formato inesperado para pending_components["subjects"]: esperado List, recebido ${subjectsData.runtimeType}');
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
    }
  }

  Future<void> _waitForAcademicAchievementPageReady(
      {Duration timeout = const Duration(seconds: 30)}) async {
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
}
