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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsRepository _settingsRepository;
  late UserRepository _userRepository;
  late ShorebirdService _shorebirdService;

  DateTime? _lastSyncAttempt;
  DateTime? _lastSyncSuccess;
  SyncStatus? _lastSyncStatus;
  String? _lastSyncMessage;

  double? _currentSliderValue;
  DateTime? _nextSyncTime;

  StreamSubscription<User?>? _userStream;

  @override
  void initState() {
    super.initState();
    _settingsRepository = injector.get<SettingsRepository>();
    _shorebirdService = injector.get<ShorebirdService>();
    _userRepository = injector.get<UserRepository>();
    _userStream = _userRepository.userStream().listen((user) {
      logarte.log('userStream listener chamado com o usuário: ${user?.name}',
          source: 'SettingsPage');
      setState(() {
        _lastSyncAttempt = user?.lastSyncAttempt;
        _lastSyncSuccess = user?.lastSyncSuccess;
        _lastSyncStatus = user?.lastSyncStatus;
        _lastSyncMessage = user?.lastSyncMessage;
        _nextSyncTime = user?.nextSyncTimestamp;
      });
    });

    _currentSliderValue = _settingsRepository.syncInterval.inMinutes.toDouble();
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

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    // Formata a data e hora conforme desejado dd/MM/yyyy HH:mm
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutos';
    } else {
      return '${duration.inHours} horas';
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
                          title: const Text('Sincronização em segundo plano'),
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
                        if (_settingsRepository.isAutoSyncEnabled) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: SegmentedButton<SyncMode>(
                              segments: const [
                                ButtonSegment<SyncMode>(
                                  value: SyncMode.interval,
                                  label: Text('Intervalo'),
                                  icon: Icon(Icons.timer),
                                ),
                                ButtonSegment<SyncMode>(
                                  value: SyncMode.fixedTime,
                                  label: Text('Horário Fixo'),
                                  icon: Icon(Icons.schedule),
                                ),
                              ],
                              selected: {_settingsRepository.syncMode},
                              onSelectionChanged: (newSelection) {
                                _settingsRepository
                                    .setSyncMode(newSelection.first);
                              },
                            ),
                          ),
                          if (_settingsRepository.syncMode ==
                              SyncMode.interval) ...[
                            ListTile(
                              title: Text(
                                  'Sincronizar a cada: ${_formatDuration(Duration(minutes: _currentSliderValue!.round()))}'),
                              subtitle: Slider(
                                value: _currentSliderValue!,
                                min: 15,
                                max: 1440,
                                divisions: (1440 - 15) ~/ 15,
                                label: _formatDuration(Duration(
                                    minutes: _currentSliderValue!.round())),
                                onChanged: (double value) {
                                  setState(() {
                                    _currentSliderValue = value;
                                    _nextSyncTime = DateTime.now()
                                        .add(Duration(minutes: value.round()));
                                  });
                                },
                                onChangeEnd: (double value) {
                                  _settingsRepository.setSyncInterval(
                                      Duration(minutes: value.round()));
                                },
                                inactiveColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          ] else ...[
                            ListTile(
                              leading: const Icon(Icons.access_time_filled),
                              title: const Text('Horário da sincronização'),
                              subtitle: Text(
                                  'Todos os dias às ${_settingsRepository.syncFixedTime.format(context)}'),
                              onTap: () async {
                                final newTime = await showTimePicker(
                                  context: context,
                                  initialTime:
                                      _settingsRepository.syncFixedTime,
                                );
                                if (newTime != null) {
                                  _settingsRepository.setSyncFixedTime(newTime);
                                }
                              },
                            ),
                          ],
                          if (_settingsRepository.syncMode == SyncMode.interval)
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              child: ListTile(
                                key: ValueKey<int?>(
                                    _nextSyncTime?.millisecondsSinceEpoch),
                                leading: const Icon(Icons.update),
                                title: const Text('Próxima Sincronização'),
                                subtitle: Text(
                                  _nextSyncTime != null
                                      ? 'Agendada para: ${_formatTimestamp(_nextSyncTime!.millisecondsSinceEpoch)}'
                                      : '...',
                                ),
                              ),
                            ),
                          _buildSyncStatusTile(),
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Autenticação falhou. Tente novamente.')),
                                      );
                                    }
                                  }
                                } else {
                                  // Ao desativar, apenas desliga a configuração
                                  await _settingsRepository
                                      .toggleBiometricAuth();
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

  Widget _buildSyncStatusTile() {
    IconData icon;
    Color color;
    String statusText;
    String? subtitle;

    switch (_lastSyncStatus) {
      case SyncStatus.inProgress:
        icon = Icons.sync;
        color = Colors.blue;
        statusText = 'Sincronização em andamento...';
        break;
      case SyncStatus.success:
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = 'Sincronizado com sucesso';
        if (_lastSyncSuccess != null) {
          subtitle =
              'em ${_formatTimestamp(_lastSyncSuccess!.millisecondsSinceEpoch)}';
        }
        break;
      case SyncStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        statusText = 'Falha na sincronização';
        if (_lastSyncAttempt != null) {
          subtitle =
              'Tentativa em ${_formatTimestamp(_lastSyncAttempt!.millisecondsSinceEpoch)}\n';
        }
        if (_lastSyncMessage != null) {
          subtitle = (subtitle ?? '') + _lastSyncMessage!;
        }
        break;
      default:
        icon = Icons.hourglass_empty;
        color = Colors.grey;
        statusText = 'Sincronização pendente';
        break;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(statusText, style: TextStyle(color: color)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      isThreeLine: subtitle != null && subtitle.contains('\n'),
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
