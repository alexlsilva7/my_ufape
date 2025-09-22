import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_ufape/ui/grades/grades_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/grades_model.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  String username = '';
  String password = '';
  bool _isLoading = true;
  bool _isLoggedIn = false;

  Timer? _statusCheckTimer;

  bool _isWebViewVisible = false;
  bool _isProcessingGrades = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkLoginStatus();
    });
  }

  @override
  void dispose() {
    // Cancela o timer quando a tela for destruída
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }

            // Se for a página de login e ainda não tentamos logar
            if (url.contains('index.jsp') && !_isLoggedIn) {
              _injectLoginScript();
              // Otimisticamente, consideramos logado. O timer corrigirá se falhar.
              setState(() {
                _isLoggedIn = true;
              });
            }
            _checkLoginStatus(); // Verifica o status assim que a página carrega
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              _showAlert(
                  'Erro', 'Erro ao carregar a página: ${error.description}',
                  isError: true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://siga.ufape.edu.br/ufape/index.jsp'));
  }

  void _injectLoginScript() {
    final safeUsername =
        username.replaceAll(r'\', r'\\').replaceAll(r"'", r"\'");
    final safePassword =
        password.replaceAll(r'\', r'\\').replaceAll(r"'", r"\'");

    final script = """
      (function() {
        try {
          var u = document.getElementById('cpf') || (document.getElementsByName('cpf')[0] || null);
          var p = document.getElementById('txtPassword') || (document.getElementsByName('txtPassword')[0] || null);
          if (u) u.value = '$safeUsername';
          if (p) p.value = '$safePassword';

          var btn = document.getElementById('btnEntrar');
          if (btn) { 
            btn.click(); 
            return; 
          }

          var form = document.getElementById('formulario') || document.forms[0];
          if (form) form.submit();
        } catch (e) {
          // silencioso
        }
      })();
    """;
    _controller.runJavaScript(script);
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004D40)),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _showAlert(String title, String message,
      {bool isError = false}) async {
    if (!mounted) return;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: isError ? Colors.red.shade700 : const Color(0xFF004D40),
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _extractAndShowGrades() async {
    const String script = """
    (function() {
      try {
        const iframe = document.getElementById('Conteudo');
        if (!iframe) {
            return JSON.stringify([{ "error": "iFrame 'Conteudo' não encontrado." }]);
        }
        const iframeDoc = iframe.contentDocument || iframe.contentWindow.document;
        if (!iframeDoc) {
            return JSON.stringify([{ "error": "Não foi possível acessar o conteúdo do iFrame." }]);
        }

        const mainContainer = iframeDoc.getElementById('form-corpo');
        if (!mainContainer) {
            return JSON.stringify([{ "error": "Container 'form-corpo' não encontrado no iFrame." }]);
        }

        const periodos = [];
        
        for (const element of mainContainer.children) {
            if (element.tagName === 'DIV' && /^\\d{4}\\.\\d\$/.test(element.id)) {
                const periodDiv = element;
                const periodName = periodDiv.id;
                const currentPeriod = {
                    nome: periodName,
                    disciplinas: []
                };

                const subjectTables = periodDiv.querySelectorAll('table[id="tagrodape"]');
                for (const headerTable of subjectTables) {
                    try {
                        const nameElement = headerTable.querySelector('font.editPesquisa');
                        
                        let parentTable = headerTable.parentElement;
                        while (parentTable && parentTable.tagName !== 'TABLE') {
                            parentTable = parentTable.parentElement;
                        }
                        
                        const detailsDiv = parentTable ? parentTable.nextElementSibling : null;

                        if (!nameElement || !detailsDiv || detailsDiv.tagName !== 'DIV') continue;

                        const nome = nameElement.innerText.trim().replace(/\\s+/g, ' ');

                        const statusElement = detailsDiv.querySelector('font.editPesquisa > u');
                        const situacao = statusElement ? statusElement.innerText.trim() : 'Cursando';

                        const notas = {};
                        const headerCells = detailsDiv.querySelectorAll('td[bgcolor="#FAEBD7"]');
                        if (headerCells.length > 0) {
                            const headerRow = headerCells[0].parentElement;
                            const valueRow = headerRow.nextElementSibling;
                            if (valueRow) {
                                const headers = Array.from(headerRow.children).map(cell => cell.innerText.trim());
                                const values = Array.from(valueRow.children).map(cell => cell.innerText.trim());
                                for (let i = 1; i < headers.length; i++) {
                                    if (headers[i] && values[i] && values[i] !== '-') {
                                        notas[headers[i]] = values[i];
                                    }
                                }
                            }
                        }
                        
                        currentPeriod.disciplinas.push({
                            nome: nome,
                            situacao: situacao,
                            notas: notas
                        });

                } catch (e) {
                    console.error('Erro ao analisar uma disciplina no período ' + periodName + ': ' + e);
                }
            }
            
            if (currentPeriod.disciplinas.length > 0) {
               periodos.push(currentPeriod);
            }
        }
    }
    periodos.sort((a, b) => b.nome.localeCompare(a.nome));
    return JSON.stringify(periodos);
  } catch (e) {
    return JSON.stringify([{ "error": e.toString() }]);
  }
})();
""";

    try {
      final jsonResult =
          await _controller.runJavaScriptReturningResult(script) as String;
      if (!mounted) return;

      dynamic decodedData = jsonDecode(jsonResult);
      if (decodedData is String) {
        decodedData = jsonDecode(decodedData);
      }

      final List<dynamic> decodedList = jsonDecode(decodedData);

      if (decodedList.isNotEmpty &&
          decodedList.first is Map &&
          decodedList.first.containsKey('error')) {
        final errorMessage = decodedList.first['error'];
        await _showAlert('Erro', 'Erro no script: $errorMessage',
            isError: true);
        return;
      }

      final List<Periodo> periodos = decodedList
          .map((periodoJson) =>
              Periodo.fromJson(periodoJson as Map<String, dynamic>))
          .toList();

      if (periodos.isEmpty) {
        await _showAlert(
            'Aviso', 'Nenhuma disciplina encontrada para extrair.');
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GradesPage(),
        ),
      );
    } catch (e) {
      debugPrint("Erro ao executar/decodificar script: $e");
      await _showAlert('Erro', 'Ocorreu um erro ao extrair as notas: $e',
          isError: true);
    }
  }

  /// Espera de forma robusta que a página de notas seja totalmente carregada,
  /// verificando a presença do botão "Imprimir" dentro do iframe 'Conteudo'.
  Future<void> _waitForGradesPageReady(
      {Duration timeout = const Duration(seconds: 20)}) async {
    final completer = Completer<void>();
    Timer? timer;
    final stopwatch = Stopwatch()..start();

    const script = """
    (function() {
      const iframe = document.getElementById('Conteudo');
      if (!iframe || !iframe.contentDocument) return false;
      
      // Procura pelo botão "Imprimir"
      const printButton = iframe.contentDocument.querySelector('input[type="button"][value="Imprimir"]');
      
      // Se o botão existir, a página está pronta
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
        final result = await _controller.runJavaScriptReturningResult(script);
        // O resultado pode ser bool ou String 'true'/'false'
        if (result == true || result.toString() == 'true') {
          timer?.cancel();
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      } catch (e) {
        // Ignora erros temporários enquanto a página carrega
      }
    });

    return completer.future;
  }

  Future<void> _navigateAndExtractGrades() async {
    if (_isProcessingGrades) return;

    setState(() {
      _isProcessingGrades = true;
      _isLoading = true;
    });

    _showLoadingDialog('Iniciando processo automático...');

    try {
      _hideLoadingDialog();
      _showLoadingDialog('Abrindo menu de consultas...');

      const script1 = """
        document.getElementById('menuTopo:repeatAcessoMenu:2:repeatSuperTransacoesSuperMenu:0:linkSuperTransacaoSuperMenu').click();
      """;
      await _controller.runJavaScript(script1);

      _hideLoadingDialog();
      _showLoadingDialog('Procurando link de notas...');

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
      await _controller.runJavaScriptReturningResult(script2);

      _hideLoadingDialog();
      _showLoadingDialog('Aguardando carregamento da página de notas...');

      await _waitForGradesPageReady(timeout: const Duration(seconds: 25));

      _hideLoadingDialog();
      _showLoadingDialog('Extraindo dados das notas...');

      await Future.delayed(const Duration(milliseconds: 500));

      _hideLoadingDialog();
      await _extractAndShowGrades();
    } catch (e) {
      _hideLoadingDialog();
      await _showAlert('Erro', 'Erro no processo automático: ${e.toString()}',
          isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingGrades = false;
          _isLoading = false;
        });
      }
    }
  }

  void _toggleWebViewVisibility() {
    setState(() {
      _isWebViewVisible = !_isWebViewVisible;
    });
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;

    try {
      // Este script verifica a presença do label com o nome do usuário.
      // Se existir, o usuário está logado. Caso contrário, não está.
      const script = "document.getElementById('lblNomePessoa') != null;";
      final result = await _controller.runJavaScriptReturningResult(script);

      final bool currentlyLoggedIn =
          result == true || result.toString() == 'true';

      // Atualiza o estado APENAS se houver uma mudança, para evitar rebuilds desnecessários.
      if (currentlyLoggedIn != _isLoggedIn) {
        setState(() {
          _isLoggedIn = currentlyLoggedIn;
        });
      }
    } catch (e) {
      // Se houver um erro (ex: a página ainda está carregando),
      // consideramos como deslogado por segurança.
      if (_isLoggedIn) {
        setState(() {
          _isLoggedIn = false;
        });
      }
    }
  }

  Widget _buildStatusIndicator() {
    if (_isLoggedIn) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 14),
            SizedBox(width: 4),
            Text(
              'Conectado',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error, color: Colors.red, size: 14),
            SizedBox(width: 4),
            Text(
              'Desconectado',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo_ufape_25.png', height: 60),
            const Text(
              'SIGA UFAPE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            _buildStatusIndicator(),
          ],
        ),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'toggle_webview':
                  _toggleWebViewVisibility();
                  break;
                case 'refresh':
                  _controller.reload();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_webview',
                child: Row(
                  children: [
                    Icon(_isWebViewVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    const SizedBox(width: 8),
                    Text(_isWebViewVisible
                        ? 'Ocultar WebView'
                        : 'Mostrar WebView'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Recarregar Página'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isWebViewVisible) ...[
            WebViewWidget(controller: _controller),
            if (_isLoading && !_isProcessingGrades)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF004D40)),
                  ),
                ),
              ),
          ] else ...[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF004D40).withOpacity(0.1),
                    const Color(0xFF00695C).withOpacity(0.05),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/logo_ufape_100.png',
                        height: 200),
                    const SizedBox(height: 8),
                    Text(
                      'Sistema Acadêmico',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF004D40),
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'O WebView está executando em segundo plano',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Clique em NOTAS para visualizar suas notas ou use o menu para mostrar o WebView',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isProcessingGrades
                                  ? null
                                  : _navigateAndExtractGrades,
                              icon: _isProcessingGrades
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.school,
                                      color: Colors.white),
                              label: const Text('NOTAS',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00695C),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Botões manuais
          if (_isWebViewVisible)
            Positioned(
              bottom: 16,
              right: 16,
              child: SafeArea(
                child: FloatingActionButton.extended(
                  onPressed:
                      _isProcessingGrades ? null : _navigateAndExtractGrades,
                  icon: _isProcessingGrades
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.school, color: Colors.white),
                  label: const Text('Extrair Notas Automaticamente',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: const Color(0xFF00695C),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
