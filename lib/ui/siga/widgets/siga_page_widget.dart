import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:routefly/routefly.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SigaPageWidget extends StatefulWidget {
  const SigaPageWidget({
    super.key,
  });

  @override
  State<SigaPageWidget> createState() => _SigaPageWidgetState();
}

class _SigaPageWidgetState extends State<SigaPageWidget> {
  WebViewController? get _controller => _sigaService.controller;
  final _sigaService = injector.get<SigaBackgroundService>();
  final _settings = injector.get<SettingsRepository>();
  bool _isLoggedIn = false;

  String _message = '';
  bool _isProcessingGrades = false;
  bool _isProcessingProfile = false;
  bool _isProcessingTimetable = false;

  // Listener chamado quando o serviço notifica mudança de login
  void _onLoginChange() {
    final logged = _sigaService.loginNotifier.value;
    if (!mounted) return;
    setState(() {
      _isLoggedIn = logged;
      if (_isLoggedIn) {
        _message = 'Conectado';
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() {
            _message = '';
          });
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sigaService.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isLoggedIn = _sigaService.isLoggedIn;
        });
      }
    });
    _sigaService.loginNotifier.addListener(_onLoginChange);
  }

  @override
  void dispose() {
    try {
      _sigaService.loginNotifier.removeListener(_onLoginChange);
    } catch (_) {}
    super.dispose();
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004D40)),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> _showAlert(String title, String message,
      {bool isError = false}) async {
    if (!mounted) return;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: isError ? Colors.red.shade700 : const Color(0xFF004D40),
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateAndExtractGrades() async {
    if (_isProcessingGrades) return;

    setState(() => _isProcessingGrades = true);
    _showLoadingDialog('Extraindo notas do SIGA...');

    try {
      final grades = await _sigaService.navigateAndExtractGrades();

      _hideLoadingDialog();
      _sigaService.goToHome();

      if (grades.isEmpty) {
        await _showAlert('Aviso', 'Nenhuma nota encontrada.');
      } else {
        await Routefly.push(routePaths.grades);
      }
    } catch (e) {
      _hideLoadingDialog();
      await _showAlert('Erro', 'Erro ao extrair notas: ${e.toString()}',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessingGrades = false);
      }
    }
  }

  Future<void> _navigateAndExtractProfile() async {
    if (_isProcessingProfile) return;

    setState(() => _isProcessingProfile = true);
    _showLoadingDialog('Extraindo perfil curricular do SIGA...');

    try {
      final blocks = await _sigaService.navigateAndExtractProfile();

      _hideLoadingDialog();
      _sigaService.goToHome();
      if (blocks.isEmpty) {
        await _showAlert(
            'Aviso', 'Não foi possível extrair os dados do perfil curricular.');
      } else {
        await Routefly.push(routePaths.curricularProfile);
      }
    } catch (e) {
      _hideLoadingDialog();
      await _showAlert('Erro', 'Erro ao extrair perfil: ${e.toString()}',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessingProfile = false);
      }
    }
  }

  Future<void> _navigateAndExtractTimetable() async {
    if (_isProcessingTimetable) return;

    setState(() => _isProcessingTimetable = true);
    _showLoadingDialog('Extraindo grade de horário...');

    try {
      final subjects = await _sigaService.navigateAndExtractTimetable();
      _hideLoadingDialog();
      _sigaService.goToHome();

      if (subjects.isEmpty) {
        await _showAlert('Aviso', 'Nenhuma disciplina encontrada na grade.');
      } else {
        await Routefly.push(routePaths.timetable,
            arguments: {'subjects': subjects});
      }
    } catch (e) {
      _hideLoadingDialog();
      await _showAlert('Erro', 'Erro ao extrair grade: ${e.toString()}',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _isProcessingTimetable = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _message.isNotEmpty
              ? Text(_message, key: ValueKey(_message))
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
        _controller != null
            ? Expanded(
                child: WebViewWidget(controller: _sigaService.controller!))
            : const Spacer(),
        if (_settings.isDebugOverlayEnabled || kDebugMode)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessingGrades ||
                          _isProcessingProfile ||
                          _isProcessingTimetable ||
                          !_isLoggedIn
                      ? null
                      : _navigateAndExtractGrades,
                  icon: _isProcessingGrades
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.school, color: Colors.white),
                  label: const Text(
                    'Extrair Notas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessingGrades ||
                          _isProcessingProfile ||
                          _isProcessingTimetable ||
                          !_isLoggedIn
                      ? null
                      : _navigateAndExtractProfile,
                  icon: _isProcessingProfile
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.list_alt, color: Colors.white),
                  label: const Text('Extrair Perfil Curricular',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isProcessingGrades ||
                          _isProcessingProfile ||
                          _isProcessingTimetable || // ADICIONAR CONDIÇÃO
                          !_isLoggedIn
                      ? null
                      : _navigateAndExtractTimetable,
                  icon: _isProcessingTimetable
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.grid_on, color: Colors.white),
                  label: const Text('Extrair Grade',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Cor diferente
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}
