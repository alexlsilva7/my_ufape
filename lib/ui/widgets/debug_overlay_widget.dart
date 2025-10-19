import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/repositories/settings/settings_repository.dart';
import 'package:routefly/routefly.dart';

class DebugOverlayWidget extends StatelessWidget {
  final Widget child;

  const DebugOverlayWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final settingsRepository = injector.get<SettingsRepository>();

    return ListenableBuilder(
      listenable: settingsRepository,
      builder: (context, _) {
        final showOverlay =
            kDebugMode || settingsRepository.isDebugOverlayEnabled;

        if (!showOverlay) {
          return child;
        }

        return Stack(
          children: [
            child,
            Positioned(
              bottom: 88,
              right: 16,
              child: GestureDetector(
                onDoubleTap: () {
                  settingsRepository.changeThemeMode(ThemeMode.system);
                },
                child: FloatingActionButton(
                  onPressed: () {
                    if (settingsRepository.themeMode == ThemeMode.dark) {
                      settingsRepository.changeThemeMode(ThemeMode.light);
                    } else {
                      settingsRepository.changeThemeMode(ThemeMode.dark);
                    }
                  },
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.blueAccent),
                  ),
                  child: Icon(
                    settingsRepository.themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : settingsRepository.themeMode == ThemeMode.light
                            ? Icons.light_mode
                            : Icons.brightness_auto,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onDoubleTap: () {
                  settingsRepository.toggleDebugOverlay();
                },
                child: FloatingActionButton(
                  onPressed: () {
                    Routefly.push(routePaths.debugSiga);
                  },
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.blueAccent),
                  ),
                  child: const Icon(Icons.bug_report),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
