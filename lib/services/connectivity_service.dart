import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectionStatusController;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// Get singleton instance
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  /// Stream of connectivity status changes
  Stream<bool> get connectionStream {
    _connectionStatusController ??= StreamController<bool>.broadcast();
    return _connectionStatusController!.stream;
  }

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    _isConnected = await checkConnectivity();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final bool hasConnection =
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

      if (_isConnected != hasConnection) {
        _isConnected = hasConnection;
        _connectionStatusController?.add(_isConnected);
        print('Connectivity changed: ${_isConnected ? "Connected" : "Disconnected"}');
      }
    });
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      return result == ConnectivityResult.mobile ||
             result == ConnectivityResult.wifi ||
             result == ConnectivityResult.ethernet;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Dispose of resources
  void dispose() {
    _connectionStatusController?.close();
    _connectionStatusController = null;
  }
}
