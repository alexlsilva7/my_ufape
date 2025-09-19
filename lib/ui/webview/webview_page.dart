import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_ufape/ui/grades/grades_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../domain/entities/grades_model.dart';

class WebViewPage extends StatefulWidget {
  final String username;
  final String password;

  const WebViewPage({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasLoggedIn = false; // Flag para evitar login múltiplo
  bool _iframeLoaded = false;
  Completer<void>? _iframeReadyCompleter;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'IframeChannel',
        onMessageReceived: (JavaScriptMessage msg) {
          if (msg.message == 'Conteudo:load') {
            if (!_iframeLoaded) {
              _iframeLoaded = true;
              _iframeReadyCompleter?.complete();
              _iframeReadyCompleter = null;
              if (mounted) setState(() {});
            }
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            // Faz o login apenas na página inicial e apenas uma vez
            if (url.contains('index.jsp') && !_hasLoggedIn) {
              _injectLoginScript();
              setState(() {
                _hasLoggedIn = true; // Marca que o login foi tentado
              });
            }

            // Observa carregamentos de iframes (inclui criação dinâmica) e notifica via JavaScriptChannel
            _controller.runJavaScript(r"""
              (function() {
                if (window.__iframeWatcherInstalled) return;
                window.__iframeWatcherInstalled = true;

                function notify(tag){ try{ IframeChannel.postMessage((tag||'iframe') + ':load'); }catch(e){} }

                function attach(iframe){
                  if (!iframe || iframe.__watched) return;
                  iframe.__watched = true;
                  iframe.addEventListener('load', function(){
                    notify(iframe.id || 'iframe');
                  }, { once: true });
                }

                function attachAll(){
                  var ifr = document.getElementsByTagName('iframe');
                  for (var i=0;i<ifr.length;i++) attach(ifr[i]);
                }

                var mo = new MutationObserver(function(muts){
                  muts.forEach(function(m){
                    if (m.type === 'childList') {
                      m.addedNodes && m.addedNodes.forEach(function(n){
                        if (n.tagName === 'IFRAME') { attach(n); }
                        else if (n.querySelectorAll) { n.querySelectorAll('iframe').forEach(attach); }
                      });
                    }
                  });
                });
                try { mo.observe(document.documentElement || document.body, { childList: true, subtree: true }); } catch(e) {}

                attachAll();

                // Sinalização tardia caso o iframe já tenha carregado antes da injeção
                setTimeout(function(){
                  if (document.getElementById('Conteudo')) notify('Conteudo');
                  else if (document.getElementsByTagName('iframe').length) notify('iframe');
                }, 1200);
              })();
            """);
          },
          onWebResourceError: (WebResourceError error) {
            // Lógica para tratar erros
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        'Erro ao carregar a página: ${error.description}')),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://siga.ufape.edu.br/ufape/index.jsp'));
  }

  void _injectLoginScript() {
    // Escapa caracteres especiais que podem quebrar o script JS
    final safeUsername =
        widget.username.replaceAll(r'\', r'\\').replaceAll(r"'", r"\'");
    final safePassword =
        widget.password.replaceAll(r'\', r'\\').replaceAll(r"'", r"\'");

    final script = """
      (function() {
        try {
          var u = document.getElementById('cpf') || (document.getElementsByName('cpf')[0] || null);
          var p = document.getElementById('txtPassword') || (document.getElementsByName('txtPassword')[0] || null);
          if (u) u.value = '$safeUsername';
          if (p) p.value = '$safePassword';

          var btn = document.getElementById('btnEntrar');
          if (btn) { btn.click(); return; }

          var form = document.getElementById('formulario') || document.forms[0];
          if (form) form.submit();
        } catch (e) {
          // silencioso
        }
      })();
    """;
    _controller.runJavaScript(script);
  }

  // Função para navegar até a página de notas com polling
  Future<void> _navigateToGrades() async {
    // SCRIPT 1: Clica no menu "Consultas".
    const script1 = """
      document.getElementById('menuTopo:repeatAcessoMenu:2:repeatSuperTransacoesSuperMenu:0:linkSuperTransacaoSuperMenu').click();
    """;

    // SCRIPT 2: Procura e clica no link "Notas".
    const script2 = """
      new Promise((resolve, reject) => {
        const maxTries = 40; // Tenta por 10 segundos (40 * 250ms)
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
      await _controller.runJavaScript(script1);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Navegando para o menu de notas...'),
            duration: Duration(seconds: 2)),
      );

      final result = await _controller.runJavaScriptReturningResult(script2);
      debugPrint(result.toString());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Não foi possível navegar para as notas: ${e.toString()}')),
      );
    }
  }

  // Função para extrair as notas e navegar para a página de visualização
  Future<void> _extractAndShowGrades() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Extraindo dados com JavaScript...')),
    );

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
    console.log('Períodos encontrados:', periodos);
    periodos.sort((a, b) => b.nome.localeCompare(a.nome));
    console.log('Json final:', JSON.stringify(periodos));
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
        decodedData = jsonDecode(decodedData); // Decodifica pela segunda vez
      }

      final List<dynamic> decodedList = jsonDecode(decodedData);

      if (decodedList.isNotEmpty &&
          decodedList.first is Map &&
          decodedList.first.containsKey('error')) {
        final errorMessage = decodedList.first['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no script: $errorMessage')),
        );
        return;
      }

      final List<Periodo> periodos = decodedList
          .map((periodoJson) =>
              Periodo.fromJson(periodoJson as Map<String, dynamic>))
          .toList();

      if (periodos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Nenhuma disciplina encontrada para extrair.')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GradesPage(periodos: periodos),
        ),
      );
    } catch (e) {
      debugPrint("Erro ao executar/decodificar script: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro ao extrair as notas: $e')),
      );
    }
  }

  Future<void> _waitForConteudoLoad(
      {Duration timeout = const Duration(seconds: 20)}) async {
    // Fast-path: conferir se já está pronto
    try {
      final ok = await _controller.runJavaScriptReturningResult(r"""
        (function(){
          var iframe = document.getElementById('Conteudo');
          if(!iframe || !iframe.contentDocument) return false;
          var fc = iframe.contentDocument.getElementById('form-corpo');
          if(!fc) return false;
          var periodDivs = fc.querySelectorAll('div[id]');
          for (var i=0;i<periodDivs.length;i++){
            if (/^\d{4}\.\d$/.test(periodDivs[i].id)) return true;
          }
          return false;
        })();
      """);
      if (ok == true || ok.toString() == 'true') {
        _iframeLoaded = true;
      }
    } catch (_) {}

    if (_iframeLoaded) return;

    _iframeReadyCompleter ??= Completer<void>();

    bool timedOut = false;
    final t = Timer(timeout, () {
      timedOut = true;
      if (!(_iframeReadyCompleter?.isCompleted ?? true)) {
        _iframeReadyCompleter?.complete();
      }
    });

    await _iframeReadyCompleter!.future;
    if (!timedOut) t.cancel();
  }

  /// MÉTODO AUTOMÁTICO CORRIGIDO
  Future<void> _navigateAndExtractGrades() async {
    // Mostra um indicador de carregamento e desabilita cliques múltiplos
    setState(() {
      _isLoading = true;
      _iframeLoaded = false;
    });
    _iframeReadyCompleter = null;

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Iniciando processo automático...')),
    );

    try {
      // ETAPA 1: Clica no menu "Consultas"
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Passo 1/4: Abrindo menu de consultas...')),
      );

      const script1 = """
        document.getElementById('menuTopo:repeatAcessoMenu:2:repeatSuperTransacoesSuperMenu:0:linkSuperTransacaoSuperMenu').click();
      """;
      await _controller.runJavaScript(script1);

      // ETAPA 2: Aguarda e clica no link "Notas" dentro do primeiro iframe
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passo 2/4: Procurando link de notas...')),
      );

      const script2 = """
        new Promise((resolve, reject) => {
          const maxTries = 40; // Tenta por 10 segundos (40 * 250ms)
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

      // ETAPA 3: Aguarda a página de notas carregar completamente no iframe "Conteudo"
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Passo 3/4: Aguardando carregamento da página de notas...')),
      );

      await _waitForConteudoLoad(timeout: const Duration(seconds: 20));

      // ETAPA 4: Extrai os dados das notas
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Passo 4/4: Extraindo dados das notas...')),
      );

      // Aguarda um tempo adicional para garantir estabilidade
      await Future.delayed(const Duration(milliseconds: 500));

      await _extractAndShowGrades();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no processo automático: ${e.toString()}')),
      );
    } finally {
      // Garante que o indicador de carregamento seja removido no final
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIGA UFAPE'),
        actions: [
          // NOVO BOTÃO AUTOMÁTICO
          IconButton(
            icon: const Icon(Icons.download_for_offline_outlined),
            tooltip: 'Navegar e Extrair Notas (Automático)',
            onPressed: _navigateAndExtractGrades,
          ),
          // Botões manuais
          IconButton(
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Ir para Notas no SIGA (Manual)',
            onPressed: _navigateToGrades,
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Extrair Notas da Página Atual (Manual)',
            onPressed: _extractAndShowGrades,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar Página',
            onPressed: () {
              setState(() {
                _hasLoggedIn = false;
              });
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
