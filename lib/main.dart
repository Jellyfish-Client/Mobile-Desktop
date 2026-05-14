import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'app/app.dart';
import 'core/auth/auth_controller.dart';
import 'core/downloads/download_manager.dart';
import 'core/storage/device_id.dart';
import 'features/home/home_providers.dart';
import 'features/home/home_sections_controller.dart';

/// Cold-start clock — started at the top of `main` so any feature can log
/// "time since app launch" to compare home-paint readiness against the
/// engine's first-frame timing. Declared `late` so the assignment in `main`
/// (not lazy first-access in HomeScreen) is what starts the clock.
late final Stopwatch appStartStopwatch;

Future<void> main() async {
  appStartStopwatch = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final container = ProviderContainer();
  await container.read(deviceIdProvider.future);
  // Resolve the persisted session before runApp so the router sees a settled
  // auth state on the first frame — otherwise the redirect briefly sends an
  // already-logged-in user to /onboarding/server while secure storage reads.
  try {
    await container.read(authControllerProvider.future);
  } on Object {
    // Keychain locked or storage corrupt: fall through with no session.
    // The router will land on /onboarding/server, which is the correct fallback.
  }
  // Eagerly create the DownloadManager so it subscribes to update events
  // and resumes tracked tasks from previous app runs.
  container.read(downloadManagerProvider);

  // Warm the Home rails in parallel with the first frame: if a session is
  // already restored, kick the network fetches now so they're already in
  // flight (or done) by the time HomeScreen mounts. Fire-and-forget — we
  // never await these here. Each provider keepAlives itself so they survive
  // until HomeScreen's first watch.
  if (container.read(authControllerProvider).valueOrNull?.hasSession ?? false) {
    try {
      unawaited(container.read(resumeItemsProvider.future));
      unawaited(container.read(latestItemsProvider.future));
      unawaited(container.read(nextUpItemsProvider.future));
      // recentlyPlayed is the slow fetch (200 items) feeding the taste
      // profile + recommendation rails — start it now so the cold-start
      // pipeline isn't gated on it.
      unawaited(container.read(recentlyPlayedItemsProvider.future));
      unawaited(container.read(homeSectionsControllerProvider.future));
    } on Object {
      // Session was restored but JellyfinClient isn't usable yet (e.g. partial
      // secure storage). HomeScreen will retry naturally on its first watch.
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const JellyfishApp(),
    ),
  );
}
