import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/ui/siga/widgets/siga_page_widget.dart';
import 'package:routefly/routefly.dart';

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
          Routefly.navigate(routePaths.home);
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

      Routefly.navigate(routePaths.home);
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
                Image.asset('assets/images/logo_ufape_100.png', height: 100),
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
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CpfInputFormatter(),
                  ],
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
