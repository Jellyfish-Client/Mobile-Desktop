# Jellyfish Video Player — Implementation Plan

## A. File / Folder Layout

```
lib/
  core/
    playback/                          ← backend lives here, next to jellyfin/
      player_backend.dart              ← abstract PlayerBackend interface + enums
      media_kit_player_backend.dart    ← MediaKit implementation of PlayerBackend
      playback_manager.dart            ← orchestrator: session, reporting, queue
      playback_reporting_service.dart  ← timer + Jellyfin API calls (start/progress/stop)
      playback_state.dart              ← Freezed value-class: position, duration, etc.
      playback_providers.dart          ← all @riverpod providers for playback
      media_source_resolver.dart       ← picks best MediaSourceInfo from PlaybackInfoResponse
      segments_provider.dart           ← fetches & models skippable segments
      next_up_provider.dart            ← episode-only next-up resolver
  features/
    player/
      player_screen.dart               ← root StatefulWidget, orientation + lifecycle
      player_controller.dart           ← thin glue ConsumerStatefulWidget feeding the backend
      widgets/
        video_surface.dart             ← media_kit_video Video widget wrapper
        controls_overlay.dart          ← visibility-animated container of all controls
        top_bar.dart                   ← title, back, lock button
        bottom_bar.dart                ← seekbar, transport row
        seek_bar.dart                  ← custom SliderTheme seek widget with trickplay
        transport_row.dart             ← play/pause, skip prev/next, speed button
        double_tap_seek_indicator.dart ← ripple + arrow + seconds label
        brightness_volume_indicator.dart ← vertical drag HUD (icon + percentage bar)
        subtitle_audio_sheet.dart      ← bottom sheet: tracks + audio delay picker
        speed_sheet.dart               ← bottom sheet: 0.5× … 3.0× selector
        skip_segment_button.dart       ← "Skip Intro" / "Skip Outro" floating button
        next_up_overlay.dart           ← countdown card + next episode thumb
        lock_osd_overlay.dart          ← padlock icon, swipe-up to unlock
```

Rationale: backends sit in `lib/core/playback/` (parallel to `lib/core/jellyfin/`) because they are infrastructure, not UI. The player UI lives exclusively in `lib/features/player/`. This mirrors the existing core/feature split already in the project.

---

## B. PlayerBackend Abstraction

```dart
// lib/core/playback/player_backend.dart

enum BackendState { idle, loading, playing, paused, ended, error }

abstract class PlayerBackend {
  // Lifecycle
  Future<void> open(String url, {Duration startPosition = Duration.zero});
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> setSubtitleTrack(int trackIndex); // -1 = off
  Future<void> setAudioTrack(int trackIndex);
  Future<void> setSpeed(double speed);
  Future<void> setAudioDelay(Duration delay);
  Future<void> dispose();

  // Reactive streams
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<bool> get bufferingStream;
  Stream<bool> get completedStream;  // fires once when playback ends naturally
  Stream<BackendState> get stateStream;

  // Sync getters (safe to read without listening)
  Duration get position;
  Duration get duration;
  bool get isPlaying;
  bool get isBuffering;
  BackendState get state;

  // Track metadata (populated after open())
  List<SubtitleTrackInfo> get subtitleTracks;
  List<AudioTrackInfo> get audioTracks;
}

class SubtitleTrackInfo { final int index; final String? language; final String? label; }
class AudioTrackInfo    { final int index; final String? language; final String? label; }
```

---

## C. MediaKitPlayerBackend

- Wraps `media_kit.Player` and `media_kit_video.VideoController`.
- `open()`: calls `player.open(Media(url), play: false)`, then waits for duration > 0, then seeks to `startPosition`, then calls `player.play()`.
- Stream forwarding: `player.stream.position` → `positionStream`; `player.stream.duration` → `durationStream`; `player.stream.buffering` → `bufferingStream`; `player.stream.completed` → `completedStream`.
- Track selection: `player.setSubtitleTrack(SubtitleTrack.no())` for off, `SubtitleTrack.uri(...)` or index-based selection via `player.state.tracks.subtitle[i]`; audio via `player.setAudioTrack(player.state.tracks.audio[i])`.
- Speed: `player.setRate(speed)`.
- Audio delay: `player.setAudioPitchShift` is not the right API — use `player.setAudioDelay(delay)` (available in media_kit ≥ 1.1).
- Error boundary: wrap every `player.*` call in try/catch, emit to a `StreamController<String> errorStream`; `PlayerScreen` shows a `SnackBar` and calls `context.pop()` on fatal error.
- `VideoController` must be created with `VideoController(player)` and held on the backend; exposed as `VideoController get videoController`.
- Track metadata populated in `open()` by reading `player.state.tracks` after a `player.stream.tracks.first` future.

---

## D. PlaybackManager / Riverpod State

### Provider map

```dart
// lib/core/playback/playback_providers.dart

// 1. Backend — scoped to player route via ProviderScope override in PlayerScreen
@riverpod
MediaKitPlayerBackend playerBackend(PlayerBackendRef ref) {
  final backend = MediaKitPlayerBackend();
  ref.onDispose(backend.dispose);
  return backend;
}

// 2. Current item loaded at player entry
@riverpod
Future<BaseItemDto> playerItem(PlayerItemRef ref, String itemId) =>
    ref.watch(jellyfinClientProvider).item(itemId);

// 3. PlaybackInfo (media source, session id)
@riverpod
Future<PlaybackInfoResponse> playerPlaybackInfo(
    PlayerPlaybackInfoRef ref, String itemId) =>
    ref.watch(jellyfinClientProvider).playbackInfo(itemId);

// 4. Live playback state (rebuilt ~4 Hz from position stream)
// Freezed class PlaybackState { position, duration, isPlaying, isBuffering, speed }
@riverpod
class PlaybackStateNotifier extends _$PlaybackStateNotifier { ... }

// 5. Track selection
@riverpod
class TrackSelectionNotifier extends _$TrackSelectionNotifier {
  // state = ({int subtitleIndex, int audioIndex, Duration audioDelay})
}

// 6. Skippable segments
@riverpod
Future<List<SkipSegment>> playerSegments(PlayerSegmentsRef ref, String itemId) { ... }

// 7. Next-up (episode only — null for movies)
@riverpod
Future<BaseItemDto?> playerNextUp(PlayerNextUpRef ref, String? seriesId) {
  if (seriesId == null) return Future.value(null);
  return ref.watch(jellyfinClientProvider).seriesNextUp(seriesId);
}

// 8. playSessionId — generated once by PlaybackManager.initialize()
// Stored as a field on PlaybackManager, not a separate provider.
```

### Responsibilities
- `playSessionId`: generated with `uuid` package (`const Uuid().v4()`). Generated inside `PlaybackManager.initialize()`, stored as a final field.
- `playbackInfo()` is called by `PlayerScreen.initState` via `ref.read(playerPlaybackInfoProvider(itemId))`.
- `MediaSourceResolver` (`media_source_resolver.dart`) picks the first `MediaSourceInfo` with `supportsDirectPlay == true`; falls back to first source.
- Progress reporting timer: owned by `PlaybackReportingService`. Started after `reportPlaybackStart` completes. Fires every 10 s. Also triggered by `pause()`, `play()`, and `seek()` calls on the backend (via `PlaybackManager`). Cancelled in `PlaybackManager.dispose()`.

---

## E. PlayerScreen Widget Composition

```
PlayerScreen (StatefulWidget + WidgetsBindingObserver)
  └─ ProviderScope (overrides playerBackendProvider with fresh instance)
     └─ Scaffold(backgroundColor: black, resizeToAvoidBottomInset: false)
        └─ Stack
           ├─ VideoSurface            ← Video(controller) from media_kit_video; fills screen
           ├─ GestureDetector         ← handles all touch gestures (see §F)
           ├─ ControlsOverlay         ← AnimatedOpacity; hidden after 3 s idle
           │   ├─ TopBar              ← reads playerItemProvider for title; back + lock icons
           │   ├─ BottomBar
           │   │   ├─ SeekBar         ← reads PlaybackStateNotifier; custom SliderTheme
           │   │   └─ TransportRow    ← play/pause, skip, speed; reads PlaybackStateNotifier
           │   └─ (center) BufferingIndicator ← shows when isBuffering
           ├─ SubtitleOverlay         ← media_kit handles embedded subs; this widget is
           │                             a placeholder for forced-external-SRT display
           ├─ BrightnessVolumeIndicator ← Positioned left/right; visible during drag only
           ├─ DoubleTapSeekIndicator  ← two Positioned instances (left, right)
           ├─ SkipSegmentButton       ← reads playerSegmentsProvider + position; shows when inside segment
           ├─ NextUpOverlay           ← reads playerNextUpProvider; visible at 80% or after end
           └─ LockOSDOverlay          ← replaces ControlsOverlay when locked
```

Provider consumption per widget:
- `VideoSurface` — reads `playerBackendProvider` (to get `videoController`)
- `TopBar` — reads `playerItemProvider`
- `SeekBar` / `TransportRow` — reads `PlaybackStateNotifier`
- `SubtitleAudioSheet` — reads `TrackSelectionNotifier` + `playerBackendProvider` (for track lists)
- `SkipSegmentButton` — reads `playerSegmentsProvider` + `PlaybackStateNotifier`
- `NextUpOverlay` — reads `playerNextUpProvider` + `PlaybackStateNotifier`

---

## F. Gestures & Input

| Gesture | Zone | Action |
|---|---|---|
| Single tap anywhere | full screen | toggle ControlsOverlay visibility; reset 3 s hide timer |
| Double-tap left 30% | left | seek −10 s; show DoubleTapSeekIndicator left |
| Double-tap right 30% | right | seek +10 s; show DoubleTapSeekIndicator right |
| Vertical drag start: left half | left 50% | adjust screen brightness (screen_brightness package); show BrightnessVolumeIndicator |
| Vertical drag start: right half | right 50% | adjust system volume (volume_controller package); show BrightnessVolumeIndicator |
| Horizontal drag on SeekBar | seekbar widget | scrub; emit seek on drag end |
| Back button (Android) | system | if locked: ignore; else pop route (reportPlaybackStopped fires in dispose) |

App lifecycle (`WidgetsBindingObserver.didChangeAppLifecycleState`):
- `paused` → call `backend.pause()` + `reportingService.sendProgress(isPaused: true)`
- `resumed` → call `backend.play()` + `reportingService.sendProgress(isPaused: false)`

---

## G. Jellyfin Reporting Lifecycle

```
1. detail_screen pushes /play/:id
2. PlayerScreen.initState
   a. lock orientation (§L)
   b. ref.read(playerPlaybackInfoProvider(itemId)) → PlaybackInfoResponse
   c. MediaSourceResolver.pick(response) → MediaSourceInfo
   d. playSessionId = Uuid().v4()
   e. streamUrl = jellyfinClient.streamUrl(itemId, mediaSourceInfo.id)
   f. backend.open(streamUrl, startPosition: resumePosition)
   g. await jellyfinClient.reportPlaybackStart(...)
   h. PlaybackReportingService.start(timer: 10s)
3. While playing
   - Every 10 s: reportPlaybackProgress(positionTicks, isPaused: false)
   - On pause: reportPlaybackProgress(isPaused: true)
   - On play: reportPlaybackProgress(isPaused: false)
   - On seek: reportPlaybackProgress at new position
4. PlayerScreen.dispose
   - PlaybackReportingService.stop()
   - jellyfinClient.reportPlaybackStopped(positionTicks: backend.position.inMicroseconds * 10)
   - backend.dispose()
   - restore orientation (§L)
```

Files: step b–f in `PlaybackManager.initialize()` (`lib/core/playback/playback_manager.dart`); step g–h in `PlaybackReportingService.start()` (`lib/core/playback/playback_reporting_service.dart`).

---

## H. Resume Support

- In `PlayerScreen.initState`, before calling `backend.open()`: read `item.userData?.playbackPositionTicks`.
- Convert: `Duration resumePosition = Duration(microseconds: (ticks ~/ 10))` (Jellyfin ticks = 100 ns → ÷10 = µs).
- Use `hasResumePosition(item)` from `lib/features/details/_format.dart` to decide.
- Visual: show a brief `SnackBar` ("Resuming from 47 min") for 2 s after the video starts playing, not a blocking dialog. Auto-seek is silent/automatic (Moonfin-style).
- Fresh start: `startPosition = Duration.zero`; no toast.

---

## I. Skip Segments (Intro / Outro / Chapters)

- `MediaSegmentsApi.getItemSegments(itemId: itemId)` already exists in the generated client (confirmed at line 39 of `media_segments_api.dart`).
- Add `mediaSegments(String itemId)` method to `JellyfinClient` (~3 lines) returning `List<MediaSegmentDto>`.
- `SkipSegment` value class: `{ Duration start, Duration end, SegmentType type }`.
- Provider `playerSegmentsProvider(String itemId)` in `lib/core/playback/segments_provider.dart`: calls the new client method, maps to `SkipSegment` list.
- In `PlayerScreen`, position-stream listener: check if current position falls in any segment with `type == intro || type == outro`; if so, show `SkipSegmentButton`.
- `SkipSegmentButton` taps call `backend.seek(segment.end)` and hide themselves.
- The button auto-dismisses after 8 s if not pressed.
- No trickplay/thumbnail scrubbing required for MVP — SeekBar shows plain position.

---

## J. Next-Up Overlay

- Provider: `playerNextUpProvider(seriesId)` in `lib/core/playback/next_up_provider.dart`. Only instantiated when `item.seriesId != null`.
- Trigger threshold: `position >= duration * 0.80` (checked in position-stream listener inside `PlayerScreen`).
- Also triggered immediately when `backend.completedStream` fires.
- Overlay: `NextUpOverlay` widget — thumbnail via `jellyfinClient.imageUrl(nextItem)`, episode title, a countdown `AnimatedBuilder` (15 s), "Play Now" button, "Dismiss" text button.
- On countdown reaching 0 or "Play Now" press: `context.pushReplacement('/play/${nextItem.id}')` (use `pushReplacement` so back stack doesn't accumulate).
- On "Dismiss": hide overlay, let current item finish normally.
- File: `lib/features/player/widgets/next_up_overlay.dart`.

---

## K. Routing

Keep `/play/:id` as-is for the common case.

Add a `PlayExtra` class passed via `context.push('/play/:id', extra: PlayExtra(...))`:

```dart
class PlayExtra {
  final String? mediaSourceId;
  final int? audioStreamIndex;
  final int? subtitleStreamIndex;
}
```

Router reads `state.extra as PlayExtra?` and passes it to `PlayerScreen`. This is nullable/optional so existing `context.push('/play/${item.id}')` calls in detail screens continue to work without change. No query params (avoids encoding issues with IDs).

---

## L. System UI (Landscape Lock + Immersive Mode)

In `PlayerScreen.initState`:
```dart
SystemChrome.setPreferredOrientations([
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
WakelockPlus.enable();
```

In `PlayerScreen.dispose`:
```dart
SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
WakelockPlus.disable();
```

ControlsOverlay visibility toggle: when showing controls, call `SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge)`; when hiding, call `SystemUiMode.immersiveSticky`.

---

## M. New Dependencies

### Required for MVP

| Package | Version | Purpose |
|---|---|---|
| `wakelock_plus` | `^1.2.8` | Prevent screen sleep during playback |
| `screen_brightness` | `^0.2.2+1` | Brightness gesture control (iOS + Android) |
| `volume_controller` | `^2.0.7` | System volume gesture control |
| `uuid` | `^4.4.2` | Generate `playSessionId` (v4 UUID) |

### Nice-to-Have (post-MVP)

| Package | Version | Purpose |
|---|---|---|
| `flutter_pip` | latest | Picture-in-Picture (Android only) |
| `audio_service` | `^0.18.x` | Lock-screen media controls / background audio |
| `media_kit_libs_ios_video` | matching | Hardware-accelerated iOS decoding (check if needed) |

---

## N. Verification Plan

1. **Basic playback** — open a movie from detail screen, video plays fullscreen landscape, controls show/hide on tap, progress bar advances.
2. **Seek** — drag seekbar to 50%, confirm position jumps, confirm Jellyfin admin shows updated position.
3. **Double-tap seek** — double-tap left/right, confirm −10/+10 s with ripple indicator.
4. **Subtitle / audio track switch** — open sheet, pick alternate track, confirm media_kit switches without restart.
5. **Resume** — partially watch a movie, exit, re-enter from detail screen; confirm video seeks to saved position and toast shows.
6. **Jellyfin reporting** — open Jellyfin admin → Dashboard → Active Sessions during playback; confirm session appears with correct position updating every 10 s.
7. **Pause → background → resume** — pause, put app in background, return; confirm video is still paused, session still present in admin.
8. **Background without pause** — while playing, background the app; confirm video pauses and admin shows paused state.
9. **Playback stopped reporting** — press back; confirm active session disappears from Jellyfin admin within ~5 s.
10. **Skip intro** — play an episode that has intro markers on the server; confirm "Skip Intro" button appears at the correct timestamp.
11. **Next-up overlay** — watch an episode past 80%; confirm overlay appears with correct next episode; press "Play Now" and confirm next episode starts.
12. **Speed change** — set 1.5×, confirm audio and video speed change in sync.
13. **OSD lock** — tap lock icon; confirm all gestures except unlock swipe are disabled.
14. **Brightness / volume gestures** — vertical drag left/right; confirm system brightness / volume change with HUD indicator visible.
15. **Series with no next episode** — watch last episode in series past 80%; confirm next-up overlay does NOT appear.

---

## O. Open Questions / Risks

1. **HLS / Transcoding URL**: `streamUrl()` currently builds a `static=true` direct-play URL. If the server cannot direct-play the codec (e.g., H.265 on older Android), `PlaybackInfoResponse.mediaSources[0].transcodingUrl` must be used instead. `MediaSourceResolver` should check `supportsDirectPlay` and fall back to `transcodingUrl`; this field needs verification in the generated model.

2. **Subtitle rendering — bitmap subs (PGS/VOBSUB)**: media_kit on mobile may not render bitmap subtitle tracks. Text-based (SRT/ASS) tracks work. PGS/VOBSUB would require a separate subtitle-stream fetch from Jellyfin's `/Videos/{id}/{mediaSourceId}/Subtitles/{index}/Stream.ass` endpoint and custom overlay rendering. Flag as a follow-up.

3. **HDR signaling**: media_kit passes HDR metadata to the platform renderer but Flutter's `FlutterView` may not correctly set `HDR_DISPLAY_WINDOW` on Android. Test on HDR device; if colors are wrong, add `VideoController` with `configuration: const VideoControllerConfiguration(enableHardwareAcceleration: true)` explicitly.

4. **AudioDelay API availability**: `player.setAudioDelay()` availability depends on libmpv version bundled in `media_kit_libs_video ^1.0.5`. Verify at runtime; if absent, hide the audio delay picker in `SubtitleAudioSheet` and add a comment.

5. **`PlaybackInfoResponse` model fields**: the generated Dart class uses `built_value`; confirm `mediaSources[0].id`, `supportsDirectPlay`, and `transcodingUrl` are non-null-annotated and actually populated by the server version in use.

6. **Orientation on iPad / tablets**: the plan forces landscape but `SystemChrome.setPreferredOrientations` is silently ignored on iPads with rotation lock off in some configurations. Not a mobile concern for MVP but worth noting.

7. **`completedStream` vs `player.stream.completed`**: media_kit fires `completed` true once at natural end then resets to false. Ensure the `NextUpOverlay` trigger is edge-triggered (listen for `true` transition), not level-triggered, to avoid showing the overlay on every stream event.
