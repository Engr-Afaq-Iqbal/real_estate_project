import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../utils/logger.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final isConnected = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final connected = results.any((r) => r != ConnectivityResult.none);
    isConnected.value = connected;
    AppLogger.info('Network status: ${connected ? "connected" : "disconnected"}');
  }

  bool get hasConnection => isConnected.value;

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
