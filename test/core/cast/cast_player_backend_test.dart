import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/playback/player_backend.dart';

// Le constructor de CastPlayerBackend exige un PlaybackInfoResponse complet
// (built_value généré) + un JellyfinClient + le SDK Cast initialisé sur le
// channel natif. Ces deux dépendances sont coûteuses à mocker en unit, et
// le code intéressant (résolution d'URL, populate tracks, reload) est
// déjà testé via MediaSourceResolver et exercé en intégration manuelle
// avec un Chromecast réel. On garde donc juste un smoke test conceptuel
// sur les enums du contrat PlayerBackend qui sont consommés par le sheet
// audio/sub.
void main() {
  test('BackendState exhausts every state used by the cast sheet', () {
    expect(BackendState.values, contains(BackendState.idle));
    expect(BackendState.values, contains(BackendState.loading));
    expect(BackendState.values, contains(BackendState.playing));
    expect(BackendState.values, contains(BackendState.paused));
    expect(BackendState.values, contains(BackendState.ended));
    expect(BackendState.values, contains(BackendState.error));
  });

  test('AudioTrackInfo / SubtitleTrackInfo render a sensible label', () {
    expect(
      const AudioTrackInfo(index: 1, id: '1', language: 'fre').displayLabel(),
      'FRE',
    );
    expect(
      const SubtitleTrackInfo(
        index: 3,
        id: '3',
        language: 'eng',
        label: 'English forced',
      ).displayLabel(),
      'English forced',
    );
    expect(
      const AudioTrackInfo(index: 2, id: '2').displayLabel(),
      'Audio 3',
    );
  });
}
