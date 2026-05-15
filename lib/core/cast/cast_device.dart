import 'package:flutter/foundation.dart';
import 'package:flutter_chrome_cast/entities.dart';

/// Vue UI minimale d'un appareil Cast découvert.
@immutable
class CastDevice {
  const CastDevice({
    required this.id,
    required this.friendlyName,
    this.modelName,
  });

  factory CastDevice.fromGoogle(GoogleCastDevice device) {
    return CastDevice(
      id: device.deviceID,
      friendlyName: device.friendlyName,
      modelName: device.modelName,
    );
  }

  final String id;
  final String friendlyName;
  final String? modelName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CastDevice && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
