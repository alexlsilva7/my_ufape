import 'package:flutter/material.dart';
import 'package:my_ufape/ui/siga/widgets/siga_page_widget.dart';
import 'package:routefly/routefly.dart';

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
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'reauthenticate':
                    setState(() {
                      sigaPageWidget = null;
                    });
                    Future.delayed(Duration(milliseconds: 100)).then((value) {
                      setState(() {
                        sigaPageWidget = SigaPageWidget();
                      });
                    });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'reauthenticate',
                  child: Row(
                    children: [
                      Icon(Icons.replay),
                      SizedBox(width: 8),
                      Text('Reautenticar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: sigaPageWidget ?? Container());
  }
}
