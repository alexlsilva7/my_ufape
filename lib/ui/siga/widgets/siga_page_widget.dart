import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
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
  bool _isLoggedIn = false;

  /// Indica se a tela foi aberta para resolver CAPTCHA
  bool _openedForCaptcha = false;

  String _message = '';
  final bool _isProcessingGrades = false;
  final bool _isProcessingProfile = false;
  final bool _isProcessingTimetable = false;
  bool _isSyncInProgress = false;

  // Listener chamado quando o serviço notifica mudança de login
  void _onLoginChange() {
    final logged = _sigaService.loginNotifier.value;
    if (!mounted) return;
    setState(() {
      _isLoggedIn = logged;
      if (_isLoggedIn) {
        _message = 'Conectado';

        // Se foi aberto para resolver CAPTCHA e agora logou, fecha a tela
        if (_openedForCaptcha) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          });
        } else {
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            setState(() {
              _message = '';
            });
          });
        }
      }
    });
  }

  // Listener para Captcha
  void _onCaptchaChange() {
    final required = _sigaService.captchaRequiredNotifier.value;
    if (!mounted) return;

    if (required) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, resolva o desafio (Não sou um robô) para continuar.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
      setState(() {
        // Força atualização da UI para mostrar webview se estivesse escondida
      });
    } else if (_openedForCaptcha && !required) {
      // CAPTCHA foi resolvido - se logou, fecha a tela
      // O fechamento real acontece no _onLoginChange quando o login for bem sucedido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CAPTCHA resolvido! Efetuando login...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Verifica se foi aberto para resolver CAPTCHA
    _openedForCaptcha = _sigaService.captchaRequiredNotifier.value;

    _sigaService.initialize().then((_) {
      if (mounted) {
        setState(() {
          _isLoggedIn = _sigaService.isLoggedIn;
          _isSyncInProgress = _sigaService.isSyncing;
        });
      }
    });
    _sigaService.loginNotifier.addListener(_onLoginChange);
    _sigaService.captchaRequiredNotifier.addListener(_onCaptchaChange);

    // Verifica estado inicial
    if (_sigaService.captchaRequiredNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onCaptchaChange());
    }
    _sigaService.addListener(_onSyncStatusChange);
  }

  void _onSyncStatusChange() {
    if (!mounted) return;
    setState(() {
      _isSyncInProgress = _sigaService.isSyncing;
    });
  }

  @override
  void dispose() {
    try {
      _sigaService.loginNotifier.removeListener(_onLoginChange);
      _sigaService.captchaRequiredNotifier.removeListener(_onCaptchaChange);
      _sigaService.removeListener(_onSyncStatusChange);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
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
          ],
        ),
        if (_isSyncInProgress)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF004D40)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Aguarde a sincronização',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _sigaService.syncStatusMessage.isNotEmpty
                            ? _sigaService.syncStatusMessage
                            : 'Sincronização em andamento...',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      if (_sigaService.currentSyncOperation != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _sigaService.currentSyncOperation!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
