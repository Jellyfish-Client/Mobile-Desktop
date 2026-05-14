import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/jellyfin/mappers/base_item_dto_mapper.dart';

void main() {
  group('BaseItemDtoMapper.toDomain', () {
    test('returns null when source has no id', () {
      final dto = BaseItemDto((b) => b..name = 'orphan');
      expect(dto.toDomain(), isNull);
    });

    test('maps the full set of fields used by the feature layer', () {
      final dto = BaseItemDto(
        (b) => b
          ..id = 'i1'
          ..name = 'The Matrix'
          ..type = BaseItemKind.movie
          ..collectionType = CollectionType.movies
          ..overview = 'Neo wakes up.'
          ..runTimeTicks = 60000000000
          ..productionYear = 1999
          ..communityRating = 8.7
          ..officialRating = 'R'
          ..genres.replace(['Action', 'Sci-Fi'])
          ..indexNumber = 2
          ..parentIndexNumber = 1
          ..seriesName = 'Some Series'
          ..seriesId = 'srs'
          ..seasonId = 'season-1'
          ..premiereDate = DateTime.utc(1999, 3, 31)
          ..providerIds.replace({'Tmdb': '603', 'Imdb': 'tt0133093'})
          ..studios.replace([
            NameGuidPair(
              (s) => s
                ..id = 'studio-1'
                ..name = 'Warner Bros',
            ),
          ])
          ..people.replace([
            BaseItemPerson(
              (p) => p
                ..id = 'person-1'
                ..name = 'Keanu Reeves'
                ..role = 'Neo'
                ..type = PersonKind.actor
                ..primaryImageTag = 'face',
            ),
          ])
          ..externalUrls.replace([
            ExternalUrl(
              (e) => e
                ..name = 'IMDb'
                ..url = 'https://imdb.com/title/tt0133093',
            ),
          ])
          ..imageTags.replace({'Primary': 'p-tag', 'Logo': 'l-tag'})
          ..backdropImageTags.replace(['bd-1', 'bd-2'])
          ..parentLogoItemId = 'plogo-parent'
          ..parentLogoImageTag = 'plogo-tag'
          ..parentBackdropItemId = 'pbd-parent'
          ..parentBackdropImageTags.replace(['pbd-1'])
          ..parentThumbItemId = 'pthumb-parent'
          ..parentThumbImageTag = 'pthumb-tag'
          ..seriesPrimaryImageTag = 'srs-primary'
          ..userData.update(
            (ud) => ud
              ..playbackPositionTicks = 12345
              ..played = true
              ..isFavorite = false,
          ),
      );

      final domain = dto.toDomain()!;

      expect(domain.id, 'i1');
      expect(domain.name, 'The Matrix');
      expect(domain.type, BaseItemKind.movie);
      expect(domain.collectionType, CollectionType.movies);
      expect(domain.overview, 'Neo wakes up.');
      expect(domain.runTimeTicks, 60000000000);
      expect(domain.productionYear, 1999);
      expect(domain.communityRating, 8.7);
      expect(domain.officialRating, 'R');
      expect(domain.genres, ['Action', 'Sci-Fi']);
      expect(domain.indexNumber, 2);
      expect(domain.parentIndexNumber, 1);
      expect(domain.seriesName, 'Some Series');
      expect(domain.seriesId, 'srs');
      expect(domain.seasonId, 'season-1');
      expect(domain.premiereDate, DateTime.utc(1999, 3, 31));
      expect(domain.providerIds, {'Tmdb': '603', 'Imdb': 'tt0133093'});
      expect(domain.studios.single.name, 'Warner Bros');
      expect(domain.people.single.role, 'Neo');
      expect(domain.people.single.type, PersonKind.actor);
      expect(
        domain.externalUrls.single.url,
        'https://imdb.com/title/tt0133093',
      );
      expect(domain.imageTags, {'Primary': 'p-tag', 'Logo': 'l-tag'});
      expect(domain.backdropImageTags, ['bd-1', 'bd-2']);
      expect(domain.parentLogoItemId, 'plogo-parent');
      expect(domain.parentLogoImageTag, 'plogo-tag');
      expect(domain.parentBackdropItemId, 'pbd-parent');
      expect(domain.parentBackdropImageTags, ['pbd-1']);
      expect(domain.parentThumbItemId, 'pthumb-parent');
      expect(domain.parentThumbImageTag, 'pthumb-tag');
      expect(domain.seriesPrimaryImageTag, 'srs-primary');
      expect(domain.playbackPositionTicks, 12345);
      expect(domain.played, isTrue);
      expect(domain.isFavorite, isFalse);
    });

    test('defaults collections to empty when absent', () {
      final dto = BaseItemDto((b) => b..id = 'i1');
      final domain = dto.toDomain()!;
      expect(domain.genres, isEmpty);
      expect(domain.studios, isEmpty);
      expect(domain.people, isEmpty);
      expect(domain.externalUrls, isEmpty);
      expect(domain.imageTags, isEmpty);
      expect(domain.backdropImageTags, isEmpty);
      expect(domain.providerIds, isEmpty);
      expect(domain.playbackPositionTicks, isNull);
      expect(domain.played, isNull);
      expect(domain.isFavorite, isNull);
    });

    test('passes through collectionType for view items', () {
      final dto = BaseItemDto(
        (b) => b
          ..id = 'view-1'
          ..collectionType = CollectionType.tvshows,
      );
      expect(dto.toDomain()!.collectionType, CollectionType.tvshows);
    });

    test('collectionType is null when absent', () {
      final dto = BaseItemDto((b) => b..id = 'item-1');
      expect(dto.toDomain()!.collectionType, isNull);
    });

    test('drops null entries from providerIds', () {
      final dto = BaseItemDto(
        (b) => b
          ..id = 'i1'
          ..providerIds.replace(
            MapBuilder<String, String?>(<String, String?>{
              'Tmdb': '603',
              'Tvdb': null,
            }).build(),
          ),
      );
      final domain = dto.toDomain()!;
      expect(domain.providerIds, {'Tmdb': '603'});
      expect(domain.tmdbId, 603);
    });
  });

  group('JellyfinItem derived getters', () {
    test('resumeProgress returns the ratio when valid', () {
      final dto = BaseItemDto(
        (b) => b
          ..id = 'i1'
          ..runTimeTicks = 100
          ..userData.update((ud) => ud.playbackPositionTicks = 30),
      );
      expect(dto.toDomain()!.resumeProgress, 0.3);
    });

    test('resumeProgress returns null when inputs missing', () {
      final dto = BaseItemDto((b) => b..id = 'i1');
      expect(dto.toDomain()!.resumeProgress, isNull);
    });

    test('resumeProgress clamps to 1 when position exceeds runtime', () {
      final dto = BaseItemDto(
        (b) => b
          ..id = 'i1'
          ..runTimeTicks = 100
          ..userData.update((ud) => ud.playbackPositionTicks = 200),
      );
      expect(dto.toDomain()!.resumeProgress, 1.0);
    });

    test('hasResumePosition is false when played is true', () {
      final dto = BaseItemDto(
        (b) => b
          ..id = 'i1'
          ..userData.update(
            (ud) => ud
              ..playbackPositionTicks = 100
              ..played = true,
          ),
      );
      expect(dto.toDomain()!.hasResumePosition, isFalse);
    });

    test('hasResumePosition is true when position > 0 and not played', () {
      final dto = BaseItemDto(
        (b) => b
          ..id = 'i1'
          ..userData.update((ud) => ud.playbackPositionTicks = 100),
      );
      expect(dto.toDomain()!.hasResumePosition, isTrue);
    });

    test('tmdbId parses the Tmdb providerId', () {
      final dto = BaseItemDto(
        (b) => b
          ..id = 'i1'
          ..providerIds.replace({'Tmdb': '603'}),
      );
      expect(dto.toDomain()!.tmdbId, 603);
    });

    test('tmdbId is null when Tmdb absent or unparseable', () {
      final dto1 = BaseItemDto((b) => b..id = 'i1');
      expect(dto1.toDomain()!.tmdbId, isNull);
      final dto2 = BaseItemDto(
        (b) => b
          ..id = 'i1'
          ..providerIds.replace({'Tmdb': 'not-a-number'}),
      );
      expect(dto2.toDomain()!.tmdbId, isNull);
    });
  });
}
