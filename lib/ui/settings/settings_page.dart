import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';

import 'package:my_ufape/data/services/shorebird/shorebird_service.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir o link: $url')),
        );
      }
    }
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
      body: SingleChildScrollView(
        child: ListenableBuilder(
          listenable:
              Listenable.merge([_settingsRepository, _shorebirdService]),
          builder: (context, child) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16.0),
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
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getThemeIcon(
                                        _settingsRepository.themeMode),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Tema',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: SegmentedButton<ThemeMode>(
                                  segments: const [
                                    ButtonSegment<ThemeMode>(
                                      value: ThemeMode.light,
                                      icon: Icon(Icons.light_mode),
                                      label: Text('Claro'),
                                    ),
                                    ButtonSegment<ThemeMode>(
                                      value: ThemeMode.system,
                                      icon: Icon(Icons.settings_brightness),
                                      label: Text('Sistema'),
                                    ),
                                    ButtonSegment<ThemeMode>(
                                      value: ThemeMode.dark,
                                      icon: Icon(Icons.dark_mode),
                                      label: Text('Escuro'),
                                    ),
                                  ],
                                  selected: {_settingsRepository.themeMode},
                                  onSelectionChanged:
                                      (Set<ThemeMode> newSelection) {
                                    _settingsRepository
                                        .changeThemeMode(newSelection.first);
                                  },
                                  showSelectedIcon: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Sincronização Automática'),
                          subtitle:
                              const Text('Atualizar dados ao abrir o app'),
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
                        if (_settingsRepository.isBiometricAvailable) ...[
                          const Divider(height: 1),
                          SwitchListTile(
                            title: const Text('Acesso com Biometria'),
                            subtitle: const Text(
                                'Use sua digital ou rosto para entrar'),
                            secondary: Icon(
                              _settingsRepository.isBiometricAuthEnabled
                                  ? Icons.fingerprint
                                  : Icons.fingerprint_outlined,
                            ),
                            value: _settingsRepository.isBiometricAuthEnabled,
                            onChanged: (value) async {
                              if (value) {
                                // Ao ativar, pede a biometria para confirmar a identidade
                                final didAuthenticate =
                                    await _settingsRepository
                                        .authenticateWithBiometrics();
                                if (didAuthenticate) {
                                  await _settingsRepository
                                      .toggleBiometricAuth();
                                } else {
                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Autenticação falhou. Tente novamente.')),
                                    );
                                  }
                                }
                              } else {
                                // Ao desativar, apenas desliga a configuração
                                await _settingsRepository.toggleBiometricAuth();
                              }
                            },
                          ),
                        ],
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
                    margin: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.code),
                          title: const Text('Código Fonte'),
                          subtitle: const Text('Veja o projeto no GitHub'),
                          onTap: () => _launchURL(
                              'https://github.com/alexlsilva7/my_ufape'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Desenvolvido por'),
                          subtitle: const Text('Alex Silva'),
                          onTap: () =>
                              _launchURL('https://github.com/alexlsilva7'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('Versão'),
                          subtitle: Text(
                              _shorebirdService.appVersion ?? 'Desconhecida'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.system_update),
                          title: const Text('Verificar atualizações'),
                          subtitle: Text(
                              'Patch atual: ${_shorebirdService.currentPatchNumber ?? 'Nenhum'}'),
                          trailing: _shorebirdService.isCheckingForUpdate
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5),
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
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.system:
        return Icons.settings_brightness;
    }
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
