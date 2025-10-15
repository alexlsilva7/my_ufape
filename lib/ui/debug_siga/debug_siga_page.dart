import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DebugSigaPage extends StatefulWidget {
  const DebugSigaPage({super.key});

  @override
  State<DebugSigaPage> createState() => _DebugSigaPageState();
}

class _DebugSigaPageState extends State<DebugSigaPage> {
  final _sigaService = injector.get<SigaBackgroundService>();
  bool isLogarteOpen = false;

  @override
  void initState() {
    isLogarteOpen = logarte.isOverlayAttached;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_sigaService.controller == null) {
      return const Scaffold(
        body: Center(
          child: Text('SigaBackgroundService não inicializado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              setState(() {
                isLogarteOpen = true;
              });
              logarte.openConsole(context);
            },
          ),
          if (isLogarteOpen)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isLogarteOpen = false;
                });
                logarte.detachOverlay();
              },
            ),
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
