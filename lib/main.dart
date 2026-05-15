import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'app/app.dart';
import 'core/app_settings/app_locale_settings.dart';
import 'core/auth/auth_controller.dart';
import 'core/cast/cast_providers.dart';
import 'core/downloads/download_manager.dart';
import 'core/playback/media_session_service.dart';
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

  // Boot the system media session once. The handler outlives every
  // PlayerScreen — PlayerScreen attaches its short-lived backend on mount.
  // If init fails (rare — usually a manifest / native plugin misconfig),
  // we fall through with no override: any later read of audioHandlerProvider
  // throws, but the rest of the app keeps booting so the user can see the
  // home screen and a logged error instead of a black launch.
  JellyfishAudioHandler? audioHandler;
  try {
    audioHandler = await AudioService.init<JellyfishAudioHandler>(
      builder: JellyfishAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.jellyfish.audio',
        androidNotificationChannelName: 'Jellyfish',
        androidNotificationChannelDescription: 'Playback controls',
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidStopForegroundOnPause: true,
        androidNotificationOngoing: true,
        preloadArtwork: true,
      ),
    );
  } on Object catch (e, st) {
    // Logger sinks aren't wired until runApp runs; print is the only
    // reliable channel pre-boot. Failure is silent for the user but the
    // notification feature will be inert until app restart.
    // ignore: avoid_print
    print('AudioService.init failed: $e\n$st');
  }

  final container = ProviderContainer(
    overrides: [
      if (audioHandler != null)
        audioHandlerProvider.overrideWithValue(audioHandler),
    ],
  );
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
  // Resolve the app locale before runApp so the first frame is already in the
  // right language. If we let the AsyncNotifier resolve mid-build, the initial
  // frame uses the defaults (= follow device), then re-resolves to the saved
  // preference — that transition can leave `MaterialApp.router`'s cached
  // `Localizations` widget stale on some platforms.
  try {
    await container.read(appLocaleSettingsProvider.future);
  } on Object {
    // SharedPreferences corrupt / unavailable: fall through to defaults.
  }
  // Eagerly create the DownloadManager so it subscribes to update events
  // and resumes tracked tasks from previous app runs.
  container.read(downloadManagerProvider);

  // Cast SDK init — best-effort. If natives aren't available (emulator
  // without Play Services, non-mobile platform, denied permissions),
  // CastService.ensureInitialized swallows and isSupported stays false,
  // which makes every CastButton hide itself.
  try {
    await container.read(castInitProvider.future);
  } on Object {
    // Already logged inside CastService; the feature stays inert.
  }

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
