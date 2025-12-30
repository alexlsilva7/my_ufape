import 'dart:async';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:my_ufape/core/debug/logarte.dart';

/// Helpers for SIGA scripts: robust JSON decoder and a generic waiter for polling JS.
/// Draft - refactor and tests required.
class SigaHelpers {
  SigaHelpers._();

  /// Decodes JSON that may be double-encoded or already decoded.
  /// Returns Map/List or throws FormatException.
  static dynamic decodeJsonRobust(dynamic input) {
    if (input == null) return null;

    try {
      if (input is String && input.isEmpty) return null;

      dynamic data = input;

      if (data is String) {
        data = data.trim();
        // Try single decode
        try {
          final decoded = jsonDecode(data);
          // If decoded is String, try decode again
          if (decoded is String) {
            return jsonDecode(decoded);
          }
          return decoded;
        } catch (e) {
          // Not valid JSON string, maybe raw HTML or plain string
          // Attempt to detect JSON-like content inside string
          final maybeJsonStart = data.contains('{') || data.contains('[');
          if (maybeJsonStart) {
            // Try to extract substring from first { or [
            final start =
                data.contains('{') ? data.indexOf('{') : data.indexOf('[');
            final substring = data.substring(start);
            try {
              return jsonDecode(substring);
            } catch (_) {
              // fallthrough
            }
          }
          // return original string if nothing else
          return data;
        }
      }

      // If already decoded (Map/List), return as-is
      if (data is Map || data is List) return data;

      // Handle cases like JS returning objects via platform channel types
      try {
        return jsonDecode(data.toString());
      } catch (e) {
        logarte.log('decodeJsonRobust: unable to decode input: $e',
            source: 'SigaHelpers');
        throw FormatException('Unable to decode JSON: ${e.toString()}');
      }
    } catch (e) {
      logarte.log('decodeJsonRobust unexpected error: $e',
          source: 'SigaHelpers');
      rethrow;
    }
  }
}

/// Generic waiter that polls a JavaScript expression/script until a predicate is satisfied or timeout.
class SigaWaiter {
  final WebViewController controller;

  SigaWaiter(this.controller);

  /// Polls [script] using controller.runJavaScriptReturningResult and resolves when [acceptPredicate] returns true.
  /// If [errorPredicate] returns true for a result, throws Exception with the last result.
  Future<dynamic> waitFor(
    String script, {
    Duration timeout = const Duration(seconds: 30),
    Duration pollInterval = const Duration(milliseconds: 50),
    bool Function(dynamic result)? acceptPredicate,
    bool Function(dynamic result)? errorPredicate,
  }) async {
    final completer = Completer<dynamic>();
    Timer? timer;
    final stopwatch = Stopwatch()..start();

    timer = Timer.periodic(pollInterval, (t) async {
      if (stopwatch.elapsed > timeout) {
        t.cancel();
        if (!completer.isCompleted) {
          completer.completeError(
              TimeoutException('waitFor timeout after $timeout'));
        }
        return;
      }

      try {
        final result = await controller.runJavaScriptReturningResult(script);

        // If errorPredicate is set and matches, cancel
        if (errorPredicate != null) {
          try {
            if (errorPredicate(result)) {
              t.cancel();
              if (!completer.isCompleted) {
                completer.completeError(
                    Exception('waitFor detected error: $result'));
              }
              return;
            }
          } catch (e) {
            // ignore predicate errors
          }
        }

        // If acceptPredicate is provided, check it; otherwise treat truthy true as success
        bool ok = false;
        if (acceptPredicate != null) {
          try {
            ok = acceptPredicate(result);
          } catch (_) {
            ok = false;
          }
        } else {
          ok = result == true ||
              result.toString() == 'true' ||
              (result.toString().isNotEmpty);
        }

        if (ok) {
          t.cancel();
          if (!completer.isCompleted) completer.complete(result);
        }
      } catch (e) {
        // Ignore transient JS errors but log them
        logarte.log('waitFor polling error: $e', source: 'SigaWaiter');
      }
    });

    return completer.future.whenComplete(() {
      timer?.cancel();
    });
  }
}
