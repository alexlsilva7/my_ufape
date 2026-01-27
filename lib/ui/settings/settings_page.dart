import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logarte/logarte.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/repositories/user/user_repository.dart';

import 'package:my_ufape/data/services/shorebird/shorebird_service.dart';

import 'package:my_ufape/domain/entities/user.dart';
import 'package:share_plus/share_plus.dart';
import 'package:terminate_restart/terminate_restart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsRepository _settingsRepository;
  late UserRepository _userRepository;
  late ShorebirdService _shorebirdService;
  late SigaBackgroundService _sigaService;

  DateTime? _lastSyncTime;

  StreamSubscription<User?>? _userStream;

  @override
  void initState() {
    super.initState();
    _settingsRepository = injector.get<SettingsRepository>();
    _shorebirdService = injector.get<ShorebirdService>();
    _userRepository = injector.get<UserRepository>();
    _sigaService = injector.get<SigaBackgroundService>();

    _userStream = _userRepository.userStream().listen((user) {
      setState(() {
        _lastSyncTime = user?.lastBackgroundSync;
      });
    });
  }

  @override
  void dispose() {
    _userStream?.cancel();
    super.dispose();
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

  // Função para compartilhar os logs
  Future<void> _shareLogs() async {
    try {
      List<LogarteEntry> logs = logarte.logs.value;

      String text = '';
      for (var log in logs) {
        var datetime = log.date;
        text +=
            '[${datetime.toIso8601String()}] [${log.type}] ${log.contents.join('\n')}\n';
      }
      await SharePlus.instance
          .share(ShareParams(text: text, title: 'Logs de Diagnóstico'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao compartilhar logs: $e')),
        );
      }
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
          listenable: Listenable.merge(
              [_settingsRepository, _shorebirdService, _sigaService]),
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
                        ListTile(
                          leading: const Icon(Icons.auto_awesome),
                          title: const Text('Gemini API Key'),
                          subtitle:
                              const Text('Configurar Inteligência Artificial'),
                          onTap: _showApiKeyDialog,
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          title: const Text('Sincronizar ao abrir o app'),
                          subtitle: const Text(
                              'Sincroniza dados a cada 4 horas ao abrir o app'),
                          secondary: Icon(
                            _settingsRepository.isSyncOnOpenEnabled
                                ? Icons.sync
                                : Icons.sync_disabled,
                          ),
                          value: _settingsRepository.isSyncOnOpenEnabled,
                          onChanged: (value) async {
                            await _settingsRepository.toggleSyncOnOpen();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Última sincronização'),
                          subtitle: Text(
                            _lastSyncTime != null
                                ? _formatTimestamp(_lastSyncTime!)
                                : 'Nenhuma sincronização recente',
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: FilledButton.icon(
                            onPressed: _sigaService.isSyncing
                                ? null
                                : () {
                                    _sigaService.performAutomaticSyncIfNeeded(
                                        syncInterval: Duration.zero,
                                        ignoreSettings: true);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Iniciando sincronização...'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                            icon: _sigaService.isSyncing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.sync),
                            label: Text(_sigaService.isSyncing
                                ? 'Sincronizando...'
                                : 'Sincronizar Agora'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
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
                            secondary: const Icon(Icons.bug_report),
                            value: _settingsRepository.isDebugOverlayEnabled,
                            onChanged: (value) async {
                              await _settingsRepository.toggleDebugOverlay();
                            },
                          ),
                        ],
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.restore, color: Colors.red),
                          title: const Text(
                            'Restaurar Aplicativo',
                            style: TextStyle(color: Colors.red),
                          ),
                          subtitle:
                              const Text('Apaga todos os dados e credenciais'),
                          onTap: () => _showResetDialog(),
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
                              _launchURL('https://wa.me/5587981504902'),
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
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.bug_report),
                          title: const Text('Compartilhar Logs de Diagnóstico'),
                          subtitle: const Text(
                              'Ajude a resolver problemas enviando os logs'),
                          onTap: _shareLogs,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restaurar Aplicativo'),
          content: const Text(
              'Tem certeza? Todos os dados locais, incluindo suas credenciais salvas, serão apagados. Você precisará fazer login e sincronizar novamente.'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Restaurar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _performReset();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performReset() async {
    try {
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

  Future<void> _showApiKeyDialog() async {
    final controller = TextEditingController();
    final currentKey = await _settingsRepository.getGeminiKey();
    controller.text = currentKey ?? '';

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Insira sua chave do Google AI Studio para recursos de IA.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'API Key',
                hintText: 'Cole sua chave aqui',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () =>
                    _launchURL('https://aistudio.google.com/app/apikey'),
                child: const Text(
                  'Obter chave gratuitamente',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _settingsRepository.saveGeminiKey(controller.text.trim());
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chave salva com sucesso!')),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
