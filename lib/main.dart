import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- Ponto de entrada da aplicação ---
void main() {
  runApp(const SigaUfapeApp());
}

class SigaUfapeApp extends StatelessWidget {
  const SigaUfapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login SIGA UFAPE',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF004D40), // Verde escuro
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00796B), // Verde médio
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- Tela de Login ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _savePassword = false;

  // Storage seguro para salvar credenciais
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final savedUser = await _secureStorage.read(key: 'username');
      final savedPass = await _secureStorage.read(key: 'password');

      if (savedUser != null && savedPass != null) {
        _usernameController.text = savedUser;
        _passwordController.text = savedPass;
        setState(() {
          _savePassword = true;
        });

        // Navega automaticamente após o build completar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => WebViewPage(
                username: savedUser,
                password: savedPass,
              ),
            ),
          );
        });
      }
    } catch (e) {
      // Falha ao ler storage: ignora (não impede o app)
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        if (_savePassword) {
          await _secureStorage.write(key: 'username', value: username);
          await _secureStorage.write(key: 'password', value: password);
        } else {
          await _secureStorage.delete(key: 'username');
          await _secureStorage.delete(key: 'password');
        }
      } catch (e) {
        // Ignore storage errors; continue login
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(
            username: username,
            password: password,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Automático - SIGA'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(
                  'https://ufape.edu.br/sites/default/files/BRAS%C3%83O_SITE.fw_.png',
                  height: 120,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.school, size: 80),
                ),
                const SizedBox(height: 32),
                Text(
                  'Acesse sua conta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF004D40),
                      ),
                ),
                const SizedBox(height: 24),
                // Campo de Usuário
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Usuário (CPF)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu CPF';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                // Salvar senha
                CheckboxListTile(
                  title: const Text('Salvar senha e entrar automaticamente'),
                  value: _savePassword,
                  onChanged: (v) {
                    setState(() {
                      _savePassword = v ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                // Botão de Entrar
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Entrar no SIGA'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

// NOVA VERSÃO - MAIS ROBUSTA
class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasLoggedIn = false; // Flag para evitar login múltiplo

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
          },
          onWebResourceError: (WebResourceError error) {
            // Lógica para tratar erros
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Erro ao carregar a página: ${error.description}')),
            );
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
    // SCRIPT 1: Clica no menu "Detalhamento de Discente".
    // Este link geralmente está disponível na página principal após o login.
    final script1 = """
      document.getElementById('menuTopo:repeatAcessoMenu:2:repeatSuperTransacoesSuperMenu:0:linkSuperTransacaoSuperMenu').click();
    """;

    // SCRIPT 2: Procura e clica no link "Notas".
    // Este script é uma Promise que resolve quando o botão é clicado.
    // Ele procura o botão dentro do primeiro <iframe> da página.
    final script2 = """
      new Promise((resolve, reject) => {
        const maxTries = 40; // Tenta por 10 segundos (40 * 250ms)
        let tries = 0;
        const interval = setInterval(() => {
          // O conteúdo principal do SIGA geralmente carrega em um iframe.
          const iframe = document.getElementsByTagName('iframe')[0];
          let gradesLink;

          if (iframe && iframe.contentDocument) {
            // Procura o botão DENTRO do iframe.
            gradesLink = iframe.contentDocument.getElementById('form:repeatTransacoes:3:outputLinkTransacao');
          }
          
          if (gradesLink) {
            // Se encontrou, limpa o intervalo, clica e resolve a promise.
            clearInterval(interval);
            gradesLink.click();
            resolve('SUCESSO: Botão de notas clicado dentro do iframe.');
            return;
          }

          tries++;
          if (tries >= maxTries) {
            // Se excedeu as tentativas, limpa o intervalo e rejeita a promise.
            clearInterval(interval);
            reject('ERRO: Tempo esgotado. Botão de notas não encontrado.');
          }
        }, 250); // Tenta a cada 250ms
      });
    """;

    try {
      // Executa o primeiro clique.
      await _controller.runJavaScript(script1);

      // Informa ao usuário que está aguardando o próximo passo.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Navegando para o menu de notas...'),
            duration: Duration(seconds: 2)),
      );

      // Executa o segundo script (com polling) e espera pelo resultado.
      final result = await _controller.runJavaScriptReturningResult(script2);
      debugPrint(result
          .toString()); // Imprime o resultado ("SUCESSO" ou "ERRO") no console de debug.
    } catch (e) {
      // Se ocorrer algum erro na execução do JavaScript, mostra na tela.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Não foi possível navegar para as notas: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIGA UFAPE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.school_outlined),
            tooltip: 'Ver Notas',
            onPressed: _navigateToGrades,
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
