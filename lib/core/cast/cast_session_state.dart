import 'package:flutter/foundation.dart';

import 'cast_device.dart';

/// État du cycle de vie de la session Cast.
enum CastConnectionStatus {
  idle,
  connecting,
  connected,
  disconnecting,
  error,
}

@immutable
class CastSessionSnapshot {
  const CastSessionSnapshot({
    required this.status,
    this.device,
    this.errorMessage,
  });

  static const idle = CastSessionSnapshot(status: CastConnectionStatus.idle);

  final CastConnectionStatus status;
  final CastDevice? device;
  final String? errorMessage;

  bool get isConnected => status == CastConnectionStatus.connected;

  CastSessionSnapshot copyWith({
    CastConnectionStatus? status,
    CastDevice? device,
    String? errorMessage,
  }) {
    return CastSessionSnapshot(
      status: status ?? this.status,
      device: device ?? this.device,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CastSessionSnapshot &&
          other.status == status &&
          other.device == device &&
          other.errorMessage == errorMessage;

  @override
  int get hashCode => Object.hash(status, device, errorMessage);
}
