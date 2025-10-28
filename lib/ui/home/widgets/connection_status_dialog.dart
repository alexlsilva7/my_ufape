import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectionStatusDialog extends StatelessWidget {
  final List<ConnectivityResult> connectivityResult;
  final InternetConnectionStatus internetStatus;
  final bool isSigaLoggedIn;

  const ConnectionStatusDialog({
    super.key,
    required this.connectivityResult,
    required this.internetStatus,
    required this.isSigaLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalhes da Conexão'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusRow(
            'Rede:',
            _getConnectivityText(),
            _getConnectivityIcon(),
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'Internet:',
            internetStatus == InternetConnectionStatus.connected
                ? 'Conectado'
                : 'Desconectado',
            internetStatus == InternetConnectionStatus.connected
                ? Icons.cloud_done
                : Icons.cloud_off,
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'SIGA:',
            isSigaLoggedIn ? 'Conectado' : 'Desconectado',
            isSigaLoggedIn ? Icons.lock_open : Icons.lock,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String title, String status, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(title),
        const Spacer(),
        Text(
          status,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getConnectivityText() {
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return 'Wi-Fi';
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return 'Dados Móveis';
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      return 'VPN';
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      return 'Bluetooth';
    } else if (connectivityResult.contains(ConnectivityResult.other)) {
      return 'Outro';
    }
    return 'Offline';
  }

  IconData _getConnectivityIcon() {
    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      return Icons.wifi;
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      return Icons.signal_cellular_alt;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      return Icons.settings_ethernet;
    } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
      return Icons.vpn_lock;
    } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
      return Icons.bluetooth;
    }
    return Icons.wifi_off;
  }
}
