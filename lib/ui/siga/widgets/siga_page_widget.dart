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
  final _sigaService = injector.get<SigaBackgroundService>(
    key: 'siga_background',
  );
  bool _isLoggedIn = false;

  /// Indica se a tela foi aberta para resolver CAPTCHA
  bool _openedForCaptcha = false;

  String _message = '';

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
        });
      }
    });
    _sigaService.loginNotifier.addListener(_onLoginChange);
    _sigaService.captchaRequiredNotifier.addListener(_onCaptchaChange);

    // Verifica estado inicial
    if (_sigaService.captchaRequiredNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onCaptchaChange());
    }
  }

  @override
  void dispose() {
    try {
      _sigaService.loginNotifier.removeListener(_onLoginChange);
      _sigaService.captchaRequiredNotifier.removeListener(_onCaptchaChange);
    } catch (_) {}
    super.dispose();
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
      ],
    );
  }
}
