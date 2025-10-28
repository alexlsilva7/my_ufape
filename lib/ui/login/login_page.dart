import 'package:brasil_fields/brasil_fields.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:routefly/routefly.dart';

import '../../core/ui/gen/assets.gen.dart';

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
  bool _isLoading = false;

  // Storage seguro para salvar credenciais
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // --- INÍCIO DA VERIFICAÇÃO DE CONECTIVIDADE ---

      // 1. Verifica se há alguma conexão de rede ativa (Wi-Fi, Dados Móveis, etc.)
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        if (mounted) {
          _showNoInternetSnackbar();
          setState(() {
            _isLoading = false;
          });
        }
        return; // Para a execução aqui
      }

      // 2. Verifica se a conexão ativa realmente tem acesso à internet
      final hasInternet = await InternetConnectionChecker().hasConnection;
      if (!hasInternet) {
        if (mounted) {
          _showNoInternetSnackbar();
          setState(() {
            _isLoading = false;
          });
        }
        return; // Para a execução aqui
      }

      // --- FIM DA VERIFICAÇÃO DE CONECTIVIDADE ---

      final username = _usernameController.text;
      final password = _passwordController.text;

      try {
        await _secureStorage.write(key: 'username', value: username);
        await _secureStorage.write(key: 'password', value: password);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha ao salvar credenciais: $e'),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final sigaService =
          injector.get<SigaBackgroundService>(key: 'siga_background');
      final success = await sigaService.login(username, password);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          Routefly.navigate(routePaths.initialSync);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Falha no login. Verifique suas credenciais e conexão.')),
          );
        }
      }
    }
  }

  // 👇 Adicione este método auxiliar dentro da classe _LoginPageState
  void _showNoInternetSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Text('Sem conexão com a internet.',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
      ),
    );
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
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                      child: Assets.images.myUfapeLogo.image(
                        width: 150,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'My UFAPE',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Acesse sua conta',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use suas credenciais do SIGA para entrar',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    // Campo de Usuário
                    TextFormField(
                      controller: _usernameController,
                      enabled: !_isLoading,
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
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Campo de Senha
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
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
                    const SizedBox(height: 24),
                    // Botão de Entrar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
