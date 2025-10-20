import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/core/debug/logarte.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:routefly/routefly.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DebugSigaPage extends StatefulWidget {
  const DebugSigaPage({super.key});

  @override
  State<DebugSigaPage> createState() => _DebugSigaPageState();
}

class _DebugSigaPageState extends State<DebugSigaPage> {
  final _sigaService =
      injector.get<SigaBackgroundService>(key: 'siga_background');
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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _sigaService.controller?.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ListenableBuilder(
            listenable: _sigaService,
            builder: (context, child) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                            onPressed: () {
                              Routefly.navigate(routePaths.initialSync);
                            },
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              backgroundColor: Colors.indigo,
                            ),
                            icon: const Icon(Icons.sync_rounded),
                            label: const Text('initialSync')),
                        ElevatedButton.icon(
                            onPressed: () {
                              _sigaService.goToHome();
                            },
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              backgroundColor: Colors.indigo,
                            ),
                            icon: const Icon(Icons.home),
                            label: const Text('Home')),
                        ElevatedButton.icon(
                            onPressed: () {
                              _sigaService.performAutomaticSyncIfNeeded();
                            },
                            style: ElevatedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              backgroundColor: Colors.indigo,
                            ),
                            icon: const Icon(Icons.sync),
                            label: const Text('Sync')),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // LogsButton
                        ElevatedButton.icon(
                          onPressed: () {
                            if (!isLogarteOpen) {
                              setState(() {
                                isLogarteOpen = true;
                              });
                              logarte.openConsole(context);
                            } else {
                              setState(() {
                                isLogarteOpen = false;
                              });
                              logarte.detachOverlay();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            backgroundColor: Colors.deepOrange[700],
                          ),
                          icon: Icon(isLogarteOpen
                              ? Icons.close
                              : Icons.article_outlined),
                          label: Text(isLogarteOpen
                              ? 'Fechar Logs Overlay'
                              : 'Abrir Logs Overlay'),
                        ),
                      ],
                    ),
                    if (_sigaService.isSyncing)
                      const Padding(
                        padding: EdgeInsets.only(top: 6.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white70,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sincronizando...',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(child: WebViewWidget(controller: _sigaService.controller!)),
        ],
      ),
    );
  }
}
