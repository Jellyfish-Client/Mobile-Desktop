import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../jellyfin/jellyfin_client.dart';
import '../jellyfin/mappers/base_item_dto_mapper.dart';
import '../jellyfin/models/jellyfin_item.dart';
import 'media_kit_player_backend.dart';
import 'playback_state.dart';
import 'player_backend.dart';

/// Lifecycle-scoped backend. `PlayerScreen` lives in its own ProviderScope
/// override so this auto-dispose provider tears down libmpv when the route
/// pops.
final playerBackendProvider = Provider.autoDispose<PlayerBackend>((ref) {
  final backend = MediaKitPlayerBackend();
  ref.onDispose(backend.dispose);
  return backend;
});

/// Raw DTO version of the player item. Reserved for code paths that need
/// SDK-only fields not surfaced on [JellyfinItem] (trickplay manifest,
/// chapter list). UI code should prefer [playerItemProvider].
final playerItemDtoProvider = FutureProvider.autoDispose
    .family<BaseItemDto, String>((ref, itemId) async {
      return ref.watch(jellyfinClientProvider).item(itemId);
    });

/// Domain model for the player item. Watches [playerItemDtoProvider] for
/// the same itemId — Riverpod merges their ref-counts so a single HTTP
/// request serves both, provided at least one of the two providers has an
/// active listener. UI code that doesn't need SDK-only fields must use
/// this provider; [playerItemDtoProvider] is reserved for trickplay and
/// chapters access.
///
/// Throws [StateError] if the server returns a DTO without an id (matches
/// the contract used elsewhere — see `features/details/detail_providers.dart`).
final playerItemProvider = FutureProvider.autoDispose
    .family<JellyfinItem, String>((ref, itemId) async {
      final dto = await ref.watch(playerItemDtoProvider(itemId).future);
      final domain = dto.toDomain();
      if (domain == null) {
        throw StateError('Jellyfin item $itemId has no id');
      }
      return domain;
    });

final playerPlaybackInfoProvider = FutureProvider.autoDispose
    .family<PlaybackInfoResponse, String>((ref, itemId) async {
      return ref.watch(jellyfinClientProvider).playbackInfo(itemId);
    });

/// Polls the backend every 250ms and surfaces a debounced snapshot. We poll
/// rather than merging four media_kit streams — fewer rebuilds and one source
/// of truth for the UI.
class PlaybackStateNotifier extends StateNotifier<PlaybackState> {
  PlaybackStateNotifier(this._backend) : super(const PlaybackState()) {
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => _tick());
  }

  final PlayerBackend _backend;
  Timer? _timer;

  void _tick() {
    if (!mounted) return;
    final s = PlaybackState(
      position: _backend.position,
      duration: _backend.duration,
      isPlaying: _backend.isPlaying,
      isBuffering: _backend.isBuffering,
      backendState: _backend.state,
      speed: state.speed,
    );
    if (s.position != state.position ||
        s.duration != state.duration ||
        s.isPlaying != state.isPlaying ||
        s.isBuffering != state.isBuffering ||
        s.backendState != state.backendState) {
      state = s;
    }
  }

  void setSpeed(double rate) {
    state = state.copyWith(speed: rate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final playbackStateProvider =
    StateNotifierProvider.autoDispose<PlaybackStateNotifier, PlaybackState>((
      ref,
    ) {
      final backend = ref.watch(playerBackendProvider);
      return PlaybackStateNotifier(backend);
    });
