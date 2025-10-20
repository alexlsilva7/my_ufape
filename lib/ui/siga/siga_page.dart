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
  SigaPageWidget? sigaPageWidget = SigaPageWidget();

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
                injector.get<SigaBackgroundService>(key: 'siga_ui').reconnect();
              },
            ),
          ],
        ),
        body: sigaPageWidget ?? Container());
  }
}
