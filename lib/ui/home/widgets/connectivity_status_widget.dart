import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:my_ufape/config/dependencies.dart';
import 'package:my_ufape/data/services/siga/siga_background_service.dart';

import 'connection_status_dialog.dart';

class ConnectivityStatusWidget extends StatefulWidget {
  const ConnectivityStatusWidget({super.key});

  @override
  State<ConnectivityStatusWidget> createState() =>
      _ConnectivityStatusWidgetState();
}

class _ConnectivityStatusWidgetState extends State<ConnectivityStatusWidget> {
  final SigaBackgroundService _sigaService =
      injector.get<SigaBackgroundService>();

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late StreamSubscription<InternetConnectionStatus>
      _internetConnectionSubscription;
  late VoidCallback _sigaLoginListener;

  List<ConnectivityResult> _connectivityResult = [ConnectivityResult.none];
  InternetConnectionStatus _internetStatus =
      InternetConnectionStatus.disconnected;
  bool _isSigaLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _connectivityResult = result;
      });
    });

    _internetConnectionSubscription =
        InternetConnectionChecker().onStatusChange.listen((status) {
      setState(() {
        _internetStatus = status;
      });
    });

    _sigaLoginListener = () {
      if (mounted) {
        setState(() {
          _isSigaLoggedIn = _sigaService.isLoggedIn;
        });
      }
    };
    _sigaService.loginNotifier.addListener(_sigaLoginListener);

    // Initial checks
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final connectivity = await Connectivity().checkConnectivity();
    final internet = await InternetConnectionChecker().hasConnection;
    setState(() {
      _connectivityResult = connectivity;
      _internetStatus = internet
          ? InternetConnectionStatus.connected
          : InternetConnectionStatus.disconnected;
      _isSigaLoggedIn = _sigaService.isLoggedIn;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _internetConnectionSubscription.cancel();
    _sigaService.loginNotifier.removeListener(_sigaLoginListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getStatus();

    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ConnectionStatusDialog(
            connectivityResult: _connectivityResult,
            internetStatus: _internetStatus,
            isSigaLoggedIn: _isSigaLoggedIn,
          ),
        );
      },
    );
  }

  (IconData, Color) _getStatus() {
    if (_sigaService.isSyncing) {
      return (Icons.sync, Colors.greenAccent.shade200);
    }
    if (_internetStatus == InternetConnectionStatus.disconnected) {
      return (Icons.wifi_off, Colors.red);
    }
    if (_isSigaLoggedIn) {
      return (_getIconForConnectivity(), Colors.greenAccent.shade200);
    }
    return (_getIconForConnectivity(), Colors.grey);
  }

  IconData _getIconForConnectivity() {
    if (_connectivityResult.contains(ConnectivityResult.wifi)) {
      return Icons.wifi;
    } else if (_connectivityResult.contains(ConnectivityResult.mobile)) {
      return Icons.signal_cellular_alt;
    }
    return Icons.wifi_off;
  }
}
