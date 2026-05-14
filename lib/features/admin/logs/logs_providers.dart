import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../core/jellyfin/jellyfin_client.dart';

/// Catalogue of log files available on the server. Sorted by `dateModified`
/// descending so the most recently rotated file (typically the active one)
/// surfaces first.
final adminServerLogsProvider =
    FutureProvider.autoDispose<List<LogFile>>((ref) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getSystemApi().getServerLogs();
  final list = res.data?.toList() ?? const <LogFile>[];
  return list
    ..sort((a, b) {
      final aDate = a.dateModified ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.dateModified ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
});

/// Decoded contents of a specific server log file. The endpoint returns raw
/// bytes; we decode as UTF-8 (allowing malformed sequences) so the viewer can
/// always render something even if the log carries an odd byte.
final adminLogFileProvider =
    FutureProvider.autoDispose.family<String, String>((ref, name) async {
  final api = ref.watch(jellyfinApiProvider);
  final res = await api.getSystemApi().getLogFile(name: name);
  final bytes = res.data ?? <int>[];
  return utf8.decode(bytes, allowMalformed: true);
});
