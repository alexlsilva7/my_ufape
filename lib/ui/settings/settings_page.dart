import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:routefly/routefly.dart';
import 'package:my_ufape/app_widget.dart';

import 'package:my_ufape/data/services/shorebird/shorebird_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsRepository _settingsRepository;
  late ShorebirdService _shorebirdService;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _settingsRepository = injector.get<SettingsRepository>();
    _shorebirdService = injector.get<ShorebirdService>();
    _isDarkMode = _settingsRepository.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_settingsRepository, _shorebirdService]),
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
                      SwitchListTile(
                        title: const Text('Habilitar Overlay de Debug'),
                        subtitle: const Text(
                            'Exibe o botão de debug mesmo em release'),
                        secondary: const Icon(Icons.bug_report),
                        value: _settingsRepository.isDebugOverlayEnabled,
                        onChanged: (value) async {
                          await _settingsRepository.toggleDebugOverlay();
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
                const SizedBox(height: 24),
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
                    subtitle:
                        Text(_shorebirdService.appVersion ?? 'Desconhecida'),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Atualizações do App',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.system_update),
                        title: const Text('Verificar atualizações'),
                        subtitle: Text(
                            'Patch atual: ${_shorebirdService.currentPatchNumber ?? 'Nenhum'}'),
                        trailing: _shorebirdService.isCheckingForUpdate
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.5),
                              )
                            : const Icon(Icons.refresh),
                        onTap: _shorebirdService.isCheckingForUpdate
                            ? null
                            : () => _shorebirdService
                                .checkForUpdateFromSettings(context),
                      ),
                    ],
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
