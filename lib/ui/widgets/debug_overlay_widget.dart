import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:routefly/routefly.dart';

class DebugOverlayWidget extends StatelessWidget {
  final Widget child;

  const DebugOverlayWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Routefly.push(routePaths.debugSiga);
            },
            child: const Icon(Icons.bug_report),
          ),
        ),
      ],
    );
  }
}
