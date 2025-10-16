import 'package:logarte/logarte.dart';
import 'package:share_plus/share_plus.dart';

final Logarte logarte = Logarte(
  // Protect with password
  password: null,

  // Skip password in debug mode
  ignorePassword: true,

  // Share network request'
  onShare: (String content) {
    SharePlus.instance
        .share(ShareParams(text: content, title: 'My UFAPE Logs'));
  },

  // Export all logs
  onExport: (String allLogs) {
    SharePlus.instance
        .share(ShareParams(text: allLogs, title: 'My UFAPE Logs'));
  },

  // To have logs in IDE's debug console (default is false)
  disableDebugConsoleLogs: false,

  // Add shortcut actions (optional)
  onRocketLongPressed: (context) {
    // e.g: toggle theme mode
  },
  onRocketDoubleTapped: (context) {
    // e.g: change language
  },
);
