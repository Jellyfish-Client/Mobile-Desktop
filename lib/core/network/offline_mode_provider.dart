import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connectivity_provider.dart';

/// True when the device has no active network connection. While loading
/// connectivity state we default to `false` (assume online) so that the
/// first frame doesn't briefly flash the offline UI.
final offlineModeProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStreamProvider);
  return connectivity.maybeWhen(data: (online) => !online, orElse: () => false);
});
