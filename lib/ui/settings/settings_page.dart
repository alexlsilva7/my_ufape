import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:routefly/routefly.dart';
import 'package:my_ufape/app_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsRepository _settingsRepository;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _settingsRepository = injector.get<SettingsRepository>();
    _isDarkMode = _settingsRepository.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListenableBuilder(
        listenable: _settingsRepository,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preferências',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Modo Escuro'),
                        subtitle:
                            const Text('Alterne entre tema claro e escuro'),
                        secondary: Icon(
                          _settingsRepository.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                        ),
                        value: _settingsRepository.isDarkMode,
                        onChanged: (value) async {
                          await _settingsRepository.toggleDarkMode();
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text(
                          'Sair da Conta',
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: const Text('Remove credenciais salvas'),
                        onTap: () => _showLogoutDialog(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sobre',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Versão'),
                    subtitle: const Text('1.0.0'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair da Conta'),
          content: const Text(
              'Tem certeza que deseja sair? Suas credenciais serão removidas.'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o dialog
                await _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    try {
      // Remove credenciais usando o repositório
      await _settingsRepository.deleteUserCredentials();

      // Navega de volta para login
      Routefly.navigate(routePaths.login);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
