import 'dart:io';

import 'package:floating/floating.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thin wrapper around the `floating` plugin. Android-only at the moment —
/// iOS PiP for media_kit needs native AVPictureInPictureController wiring and
/// is tracked as a follow-up.
class PipService {
  PipService() : _floating = Platform.isAndroid ? Floating() : null;

  final Floating? _floating;

  bool get isSupported => _floating != null;

  Future<bool> get isAvailable async {
    if (_floating == null) return false;
    return _floating.isPipAvailable;
  }

  Future<void> enterPip() async {
    final f = _floating;
    if (f == null) return;
    if (!await f.isPipAvailable) return;
    await f.enable(const ImmediatePiP());
  }

  /// Arms Android's auto-enter PiP so the OS shrinks the activity into a
  /// floating window when the user gestures Home / Recent. Best-effort —
  /// no-op on unsupported devices.
  Future<void> enableAutoEnter() async {
    final f = _floating;
    if (f == null) return;
    if (!await f.isPipAvailable) return;
    await f.enable(const OnLeavePiP());
  }

  Future<void> disableAutoEnter() async {
    final f = _floating;
    if (f == null) return;
    await f.cancelOnLeavePiP();
  }

  Stream<PiPStatus>? get statusStream => _floating?.pipStatusStream;

  void dispose() {}
}

final pipServiceProvider = Provider.autoDispose<PipService>((ref) {
  final service = PipService();
  ref.onDispose(service.dispose);
  return service;
});
