import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _isOnline(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);

/// Emits true whenever the device has any active network connection.
final connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _isOnline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_isOnline);
});

/// Emits true when the device is connected via Wi-Fi or Ethernet.
final onWifiStreamProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool isWifi(List<ConnectivityResult> r) =>
      r.contains(ConnectivityResult.wifi) ||
      r.contains(ConnectivityResult.ethernet);
  yield isWifi(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(isWifi);
});
