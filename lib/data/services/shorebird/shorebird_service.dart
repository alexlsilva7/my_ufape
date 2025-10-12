import 'dart:async';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:terminate_restart/terminate_restart.dart';

class ShorebirdService extends ChangeNotifier {
  final _updater = ShorebirdUpdater();
  Timer? _timer;

  bool _isCheckingForUpdate = false;
  bool get isCheckingForUpdate => _isCheckingForUpdate;

  int? _currentPatchNumber;
  int? get currentPatchNumber => _currentPatchNumber;

  String? _appVersion;
  String? get appVersion => _appVersion;

  final ValueNotifier<bool> isUpdateReadyToInstall = ValueNotifier(false);

  Future<void> init() async {
    // Get current patch number
    _updater.readCurrentPatch().then((patch) {
      _currentPatchNumber = patch?.number;
      notifyListeners();
    });

    // Get app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;

    // Check if a patch is ready to install at startup
    final status = await _updater.checkForUpdate();
    if (status == UpdateStatus.restartRequired) {
      isUpdateReadyToInstall.value = true;
    }

    // Start periodic check
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 60), (timer) async {
      await _checkForUpdate(isAutomatic: true);
    });
  }

  Future<void> _checkForUpdate(
      {bool isAutomatic = false, BuildContext? context}) async {
    if (_isCheckingForUpdate) return;

    _isCheckingForUpdate = true;
    notifyListeners();

    try {
      final status = await _updater.checkForUpdate();

      // Atualiza o número do patch atual após cada verificação
      final patch = await _updater.readCurrentPatch();
      _currentPatchNumber = patch?.number;
      notifyListeners();

      switch (status) {
        case UpdateStatus.outdated:
          if (context != null && context.mounted) {
            _showUpdateDialog(context);
          } else if (isAutomatic) {
            // Download automatically on background check
            await _downloadUpdate(context: null, showRestartDialog: false);
          }
          break;
        case UpdateStatus.restartRequired:
          isUpdateReadyToInstall.value = true;
          if (context != null && context.mounted) {
            _showRestartDialog(context);
          }
          break;
        case UpdateStatus.upToDate:
          if (!isAutomatic && context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nenhuma atualização disponível')),
            );
          }
          break;
        case UpdateStatus.unavailable:
          // Handle unavailable case if needed
          break;
      }
    } on UpdateException catch (e) {
      // Silently fail on automatic checks
      if (!isAutomatic && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar atualizações: \$e')),
        );
      }
    } finally {
      _isCheckingForUpdate = false;
      notifyListeners();
    }
  }

  Future<void> checkForUpdateFromSettings(BuildContext context) async {
    await _checkForUpdate(context: context);
  }

  Future<void> _downloadUpdate(
      {BuildContext? context, bool showRestartDialog = true}) async {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Baixando atualização...')),
      );
    }

    try {
      await _updater.update();
      isUpdateReadyToInstall.value = true;

      if (showRestartDialog && context != null && context.mounted) {
        _showRestartDialog(context);
      }
    } on UpdateException catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao baixar atualização: \$e')),
        );
      }
    }
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualização Disponível'),
        content: const Text(
            'Uma nova atualização está disponível. Deseja baixar agora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mais Tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadUpdate(context: context);
            },
            child: const Text('Baixar'),
          ),
        ],
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    TerminateRestart.instance.restartAppWithConfirmation(
      context,
      title: 'Reinicialização Necessária',
      message:
          'A atualização foi baixada. Reinicie o app para aplicar as mudanças.',
      terminate: true,
      cancelText: 'Mais Tarde',
      confirmText: 'Reiniciar Agora',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    isUpdateReadyToInstall.dispose();
    super.dispose();
  }
}
