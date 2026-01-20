import 'package:flutter/material.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';
import 'package:my_ufape/ui/siga/widgets/siga_page_widget.dart';

class SigaPage extends StatefulWidget {
  const SigaPage({super.key});

  @override
  State<SigaPage> createState() => _SigaPageState();
}

class _SigaPageState extends State<SigaPage> {
  late SigaBackgroundService _sigaService;

  @override
  void initState() {
    super.initState();
    _sigaService = injector.get<SigaBackgroundService>();

    // Se estiver sincronizando, cancela imediatamente para permitir uso manual
    // Usa addPostFrameCallback para evitar erro de setState durante build
    if (_sigaService.isSyncing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sigaService.cancelSync();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sincronização interrompida para acesso manual'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text(
                'SIGA UFAPE',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                injector
                    .get<SigaBackgroundService>(key: 'siga_background')
                    .reconnect();
              },
            ),
          ],
        ),
        body: SigaPageWidget());
  }
}
