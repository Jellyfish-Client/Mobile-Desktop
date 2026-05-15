import 'package:built_collection/built_collection.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

/// DeviceProfile envoyé à `getPostedPlaybackInfo` pour qu'un Chromecast
/// puisse lire le flux. Calqué sur le profil de Streamyfin
/// (utils/profiles/chromecast.ts).
///
/// Logique :
///   - **Direct Play** : `mp4` h264+aac/mp3/opus (couvre la majorité du contenu).
///   - **Transcoding** : HLS (`ts`) en h264+aac, 2 canaux audio max — c'est
///     ce que tous les Chromecasts savent décoder sans matériel spécifique.
///   - **Subtitles** : encodage VTT (les sous-titres sont brûlés ou délivrés
///     side-loaded via le manifeste HLS).
DeviceProfile chromecastDeviceProfile() {
  return DeviceProfile(
    (b) => b
      ..name = 'Jellyfish Chromecast'
      ..maxStreamingBitrate = 16000000
      ..maxStaticBitrate = 16000000
      ..musicStreamingTranscodingBitrate = 384000
      ..directPlayProfiles = ListBuilder<DirectPlayProfile>([
        DirectPlayProfile(
          (p) => p
            ..type = DlnaProfileType.video
            ..container = 'mp4'
            ..videoCodec = 'h264'
            ..audioCodec = 'aac,mp3,opus,vorbis',
        ),
        DirectPlayProfile(
          (p) => p
            ..type = DlnaProfileType.audio
            ..container = 'mp3',
        ),
        DirectPlayProfile(
          (p) => p
            ..type = DlnaProfileType.audio
            ..container = 'aac',
        ),
        DirectPlayProfile(
          (p) => p
            ..type = DlnaProfileType.audio
            ..container = 'flac',
        ),
        DirectPlayProfile(
          (p) => p
            ..type = DlnaProfileType.audio
            ..container = 'wav',
        ),
      ])
      ..transcodingProfiles = ListBuilder<TranscodingProfile>([
        TranscodingProfile(
          (p) => p
            ..type = DlnaProfileType.video
            ..container = 'ts'
            ..videoCodec = 'h264'
            ..audioCodec = 'aac,mp3'
            ..protocol = MediaStreamProtocol.hls
            ..context = EncodingContext.streaming
            ..maxAudioChannels = '2'
            ..minSegments = 2
            ..breakOnNonKeyFrames = true,
        ),
        TranscodingProfile(
          (p) => p
            ..type = DlnaProfileType.audio
            ..container = 'mp3'
            ..audioCodec = 'mp3'
            ..protocol = MediaStreamProtocol.http
            ..context = EncodingContext.streaming
            ..maxAudioChannels = '2',
        ),
      ])
      ..subtitleProfiles = ListBuilder<SubtitleProfile>([
        SubtitleProfile(
          (p) => p
            ..format = 'vtt'
            ..method = SubtitleDeliveryMethod.encode,
        ),
      ])
      ..codecProfiles = ListBuilder<CodecProfile>([]),
  );
}
