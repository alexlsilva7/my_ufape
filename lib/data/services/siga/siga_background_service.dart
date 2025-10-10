import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/repositories/subject/subject_repository.dart';
import 'package:my_ufape/data/repositories/subject_note/subject_note_repository.dart';
import 'package:my_ufape/data/repositories/block_of_profile/block_of_profile_repository.dart';
import 'package:my_ufape/domain/entities/subject_note.dart';
import 'package:my_ufape/domain/entities/block_of_profile.dart';
import 'package:my_ufape/data/parsers/profile_parser.dart';
import 'package:my_ufape/data/services/siga/siga_scripts.dart';

/// Serviço singleton que mantém um WebViewController em memória
/// para manter a sessão SIGA viva e expor métodos de extração.
/// Use injector.get<SigaBackgroundService>() para obter a instância.
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

  WebViewController? _controller;
  WebViewController? get controller => _controller;

  // Credenciais obtidas do repositório e usadas para tentar login quando a página de login terminar de carregar
  String? _pendingUsername;
  String? _pendingPassword;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String statusMessage = '';

  Timer? _statusTimer;

  final ValueNotifier<bool> loginNotifier = ValueNotifier(false);

  // Reconexão automática: tentativas exponenciais quando detectamos logout inesperado
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectBaseDelay = const Duration(seconds: 3);

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

            // Verifica login e, se estivermos na página de login e tivermos credenciais pendentes,
            // tenta injetar o script de login (evita tentar muito cedo, aguarda onPageFinished).
            await _checkLoginStatus();

            try {
              if (url.contains('index.jsp') &&
                  !_isLoggedIn &&
                  _pendingUsername != null &&
                  _pendingPassword != null) {
                await _injectLoginScript(_pendingUsername!, _pendingPassword!);
                // limpa credenciais pendentes para evitar tentativas repetidas
                _pendingUsername = null;
                _pendingPassword = null;
              }
            } catch (_) {
              // ignore erros de injeção
            }
          },
          onWebResourceError: (err) {
            statusMessage = 'Erro ao carregar recurso';
            notifyListeners();
          },
        ),
      );

    // Carrega a página inicial do SIGA
    await _controller!.loadRequest(
      Uri.parse('https://siga.ufape.edu.br/ufape/index.jsp'),
    );

    // Inicia timer periódico para verificar status de login
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkLoginStatus();
    });

    // Obtém credenciais e guarda como pendentes; o login será tentado quando a página de login terminar de carregar.
    final creds = await _settings.getUserCredentials();
    creds.fold((login) {
      _pendingUsername = login.username;
      _pendingPassword = login.password;
    }, (error) {
      // sem credenciais armazenadas
    });
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
      final script = SigaScripts.checkLoginScript();
      final result = await _controller!.runJavaScriptReturningResult(script);
      final bool currently = result == true || result.toString() == 'true';
      if (currently != _isLoggedIn) {
        final previous = _isLoggedIn;
        _isLoggedIn = currently;
        loginNotifier.value = _isLoggedIn;
        notifyListeners();
        // Se mudou de true para false, iniciou logout inesperado -> programar reconexão
        if (previous == true && _isLoggedIn == false) {
          _scheduleReconnect();
        } else if (_isLoggedIn == true) {
          // login bem sucedido: cancelar tentativas pendentes
          _reconnectAttempts = 0;
          _cancelReconnectTimer();
        }
      }
    } catch (e) {
      // Em caso de erro temporário consideramos deslogado e tentamos reconectar
      if (_isLoggedIn) {
        _isLoggedIn = false;
        loginNotifier.value = false;
        notifyListeners();
        _scheduleReconnect();
      }
    }
  }

  /// Reconecta realizando login com as credenciais salvas
  Future<bool> reconnect() async {
    if (_controller == null) return false;
    final creds = await _settings.getUserCredentials();
    bool attempted = false;
    bool success = false;
    await creds.fold((login) async {
      attempted = true;
      // Carrega a página de login antes de injetar, para garantir que os campos existam
      try {
        await _controller!.loadRequest(
            Uri.parse('https://siga.ufape.edu.br/ufape/index.jsp'));
      } catch (_) {}
      await _injectLoginScript(login.username, login.password);
      // Aguarda curto período e checa status
      await Future.delayed(const Duration(seconds: 2));
      await _checkLoginStatus();
      success = _isLoggedIn;
      if (success) {
        _reconnectAttempts = 0;
        _cancelReconnectTimer();
      }
    }, (error) {
      // sem credenciais
    });
    return attempted && success;
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
      {Duration timeout = const Duration(seconds: 20)}) async {
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
      {Duration timeout = const Duration(seconds: 20)}) async {
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
      await _waitForGradesPageReady(timeout: const Duration(seconds: 25));

      // 5. Extrai as notas
      final grades = await extractGrades();

      // 6. Salva no banco de dados
      for (final grade in grades) {
        await _subjectNoteRepository.upsertSubjectNote(grade);
      }

      return grades;
    } catch (e) {
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
          if (!completer.isCompleted)
            completer.completeError(Exception(
                'Não foi possível acessar o conteúdo da página do SIGA.'));
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

    try {
      // 1. Navega para o menu de detalhamento
      await _controller!.runJavaScript(SigaScripts.scriptNav());

      // 2. Clica em Informações do Discente
      await _controller!.runJavaScriptReturningResult(SigaScripts.scriptInfo());

      // 3. Aguarda a página de informações carregar
      await _waitForStudentInfoPageReady(timeout: const Duration(seconds: 25));

      // 4. Clica em Perfil Curricular
      await _controller!
          .runJavaScriptReturningResult(SigaScripts.scriptPerfil());

      // 5. Aguarda o perfil carregar
      await _waitForProfilePageReady(timeout: const Duration(seconds: 25));

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
          for (final subject in block.subjects) {
            await _subjectRepository.upsertSubject(subject);
          }
          await _blockRepository.upsertBlock(block);
        }
      }

      return blocks;
    } catch (e) {
      throw Exception('Erro ao navegar e extrair perfil: $e');
    }
  }
}
