import 'package:flutter/material.dart';
import 'package:my_ufape/app_widget.dart';
import 'package:routefly/routefly.dart';

class SplashViewModel extends ChangeNotifier {
  final bool _isLoading = true;

  init() async {
    // Simulate a loading process
    await Future.delayed(const Duration(seconds: 2));
    Routefly.navigate(routePaths.webview);
    notifyListeners();
  }
}
