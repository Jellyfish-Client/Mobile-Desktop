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
import 'core/updates/update_controller.dart';
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
        // Android 14+: notification dismissible in pause, service exits foreground to reduce resource footprint.
        androidStopForegroundOnPause: false,
        androidNotificationOngoing: false,
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
  // The three pre-runApp resolutions are independent IO reads (secure
  // storage, accounts DB, SharedPreferences) — start them together and let
  // the total cost be the slowest one instead of the sum of all three.
  //  • deviceId — required by the Jellyfin client headers.
  //  • auth — the router must see a settled session on the first frame,
  //    otherwise the redirect briefly sends an already-logged-in user to
  //    /onboarding/server while secure storage reads.
  //  • locale — the first frame must already be in the right language; a
  //    mid-build re-resolve can leave `MaterialApp.router`'s cached
  //    `Localizations` widget stale on some platforms.
  final deviceIdFuture = container.read(deviceIdProvider.future);
  final authFuture = container.read(authControllerProvider.future);
  final localeFuture = container.read(appLocaleSettingsProvider.future);
  await deviceIdFuture;
  try {
    await authFuture;
  } on Object {
    // Keychain locked or storage corrupt: fall through with no session.
    // The router will land on /onboarding/server, which is the correct fallback.
  }
  try {
    await localeFuture;
  } on Object {
    // SharedPreferences corrupt / unavailable: fall through to defaults.
  }
  // Eagerly create the DownloadManager so it subscribes to update events
  // and resumes tracked tasks from previous app runs.
  container.read(downloadManagerProvider);

  // In-app updater (Windows only). Fire-and-forget the auto-check so the
  // first frame isn't gated on a network round-trip — the controller
  // surfaces progress through `updateControllerProvider` and the About
  // screen renders the install banner when the download is ready.
  if (updatesSupportedHere) {
    unawaited(
      container.read(updateControllerProvider.notifier).maybeAutoCheck(),
    );
  }

  // Cast SDK init — best-effort and fire-and-forget: its result is only
  // consumed by the Cast buttons, never by the first frame, so it has no
  // business on the pre-runApp critical path. If natives aren't available
  // (emulator without Play Services, non-mobile platform, denied
  // permissions), CastService.ensureInitialized swallows and isSupported
  // stays false, which makes every CastButton hide itself. `.ignore()`
  // swallows the rare init throw — already logged inside CastService.
  container.read(castInitProvider.future).ignore();

  // Warm the Home rails in parallel with the first frame: if a session is
  // already restored, kick the network fetches now so they're already in
  // flight (or done) by the time HomeScreen mounts. Fire-and-forget — we
  // never await these here. Each provider keepAlives itself so they survive
  // until HomeScreen's first watch.
  //
  // Only Jellyfin providers are warmed: the Seerr/bridge fetches all await
  // `jellyfinHomeReadyProvider` internally, so the first network wave is
  // pure Jellyfin and Seerr revalidates once that wave has landed.
  if (container.read(authControllerProvider).valueOrNull?.hasSession ?? false) {
    try {
      unawaited(container.read(resumeItemsProvider.future));
      unawaited(container.read(latestItemsProvider.future));
      unawaited(container.read(nextUpItemsProvider.future));
      // recentlyPlayed is the slow fetch (100 items) feeding the taste
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
