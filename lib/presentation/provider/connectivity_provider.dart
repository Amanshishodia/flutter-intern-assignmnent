
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  void initialize() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      final hasConnection = (result != ConnectivityResult.none);

      if (_isOnline != hasConnection) {
        _isOnline = hasConnection;
        notifyListeners();
      }
    } as void Function(List<ConnectivityResult> event)?);

    // Check initial connection state
    checkConnection();
  }

  Future<void> checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    _isOnline = (result != ConnectivityResult.none);
    notifyListeners();
  }
}