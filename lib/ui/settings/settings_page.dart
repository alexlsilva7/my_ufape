import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';

import 'package:my_ufape/data/services/shorebird/shorebird_service.dart';
import 'package:terminate_restart/terminate_restart.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsRepository _settingsRepository;
  late ShorebirdService _shorebirdService;

  @override
  void initState() {
    super.initState();
    _settingsRepository = injector.get<SettingsRepository>();
    _shorebirdService = injector.get<ShorebirdService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            _settingsRepository.toggleDebugOverlay();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_settingsRepository.isDebugOverlayEnabled
                    ? 'Modo de debug ativado'
                    : 'Modo de debug desativado'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Configurações'),
        ),
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
                      // Adicione o novo SwitchListTile aqui
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Sincronização Automática'),
                        subtitle: const Text('Atualizar dados ao abrir o app'),
                        secondary: Icon(
                          _settingsRepository.isAutoSyncEnabled
                              ? Icons.sync
                              : Icons.sync_disabled,
                        ),
                        value: _settingsRepository.isAutoSyncEnabled,
                        onChanged: (value) async {
                          await _settingsRepository.toggleAutoSync();
                        },
                      ),
                      if (_settingsRepository.isDebugOverlayEnabled) ...[
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Habilitar Debug'),
                          secondary: Icon(Icons.bug_report),
                          value: _settingsRepository.isDebugOverlayEnabled,
                          onChanged: (value) async {
                            await _settingsRepository.toggleDebugOverlay();
                          },
                        ),
                      ],
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.restore,
                            color: Colors.red), // Ícone alterado
                        title: const Text(
                          'Restaurar Aplicativo', // Texto alterado
                          style: TextStyle(color: Colors.red),
                        ),
                        subtitle: const Text(
                            'Apaga todos os dados e credenciais'), // Subtítulo alterado
                        onTap: () => _showResetDialog(), // Método alterado
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

  void _showResetDialog() {
    // Renomeado de _showLogoutDialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restaurar Aplicativo'), // Título alterado
          content: const Text(
              'Tem certeza? Todos os dados locais, incluindo suas credenciais salvas, serão apagados. Você precisará fazer login e sincronizar novamente.'), // Mensagem alterada
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Restaurar', // Texto alterado
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o dialog
                await _performReset(); // Método alterado
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performReset() async {
    // Renomeado de _performLogout
    try {
      // Chama o método `restoreApp` que apaga tudo
      await _settingsRepository.restoreApp();

      await TerminateRestart.instance.restartApp(
          options: TerminateRestartOptions(
        terminate: true,
        clearData: true,
        preserveKeychain: false,
        preserveUserDefaults: false,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao restaurar o aplicativo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
