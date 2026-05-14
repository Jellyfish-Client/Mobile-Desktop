import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// SystemInfo for the connected server (name, version, pending restart, …).
/// Auto-dispose so leaving the screen drops the cached response — the page
/// is rarely revisited and the data is cheap to refetch.
final adminSystemInfoProvider =
    FutureProvider.autoDispose<SystemInfo>((ref) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getSystemApi().getSystemInfo();
  return res.data!;
});
