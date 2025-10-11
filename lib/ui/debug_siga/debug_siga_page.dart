import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:routefly/routefly.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DebugSigaPage extends StatefulWidget {
  const DebugSigaPage({super.key});

  @override
  State<DebugSigaPage> createState() => _DebugSigaPageState();
}

class _DebugSigaPageState extends State<DebugSigaPage> {
  final _sigaService = injector.get<SigaBackgroundService>();

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const Scaffold(
        body: Center(
          child: Text('Acesso negado. Esta página é apenas para debug.'),
        ),
      );
    }

    if (_sigaService.controller == null) {
      return const Scaffold(
        body: Center(
          child: Text('SigaBackgroundService não inicializado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug SIGA WebView'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _sigaService.controller?.reload();
            },
          ),
        ],
      ),
      body: WebViewWidget(controller: _sigaService.controller!),
    );
  }
}
