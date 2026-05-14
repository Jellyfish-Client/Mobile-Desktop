import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_api/jellyfin_api.dart';
import 'package:jellyfish/core/auth/session.dart';
import 'package:jellyfish/core/jellyfin/jellyfin_url_service.dart';
import 'package:jellyfish/core/jellyfin/models/jellyfin_item.dart';
import 'package:jellyfish/core/jellyfin/models/jellyfin_person.dart';

JellyfinUrlService _service({Session? session}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://jf.example.com/'));
  return JellyfinUrlService(dio: dio, session: session);
}

Session _session({String accessToken = 'TOKEN'}) => Session(
  serverUrl: 'https://jf.example.com',
  serverId: 'srv',
  userId: 'usr',
  userName: 'name',
  accessToken: accessToken,
);

void main() {
  group('JellyfinUrlService.imageUrl', () {
    test('returns null when no tag exists for the requested type', () {
      const item = JellyfinItem(id: 'i1');
      expect(_service().imageUrl(item), isNull);
    });

    test('builds a primary image URL with the matching tag and quality', () {
      const item = JellyfinItem(id: 'i1', imageTags: {'Primary': 'p-tag'});
      final url = _service().imageUrl(item, maxWidth: 600);
      expect(
        url,
        'https://jf.example.com/Items/i1/Images/Primary?tag=p-tag&maxWidth=600&quality=90',
      );
    });

    test('falls back to backdropImageTags when imageTags.Backdrop missing', () {
      const item = JellyfinItem(id: 'i1', backdropImageTags: ['bd-tag']);
      final url = _service().imageUrl(item, type: 'Backdrop');
      expect(url, contains('Images/Backdrop?tag=bd-tag'));
    });

    test('prefers imageTags.Backdrop over the backdropImageTags fallback', () {
      const item = JellyfinItem(
        id: 'i1',
        imageTags: {'Backdrop': 'primary-bd'},
        backdropImageTags: ['fallback'],
      );
      final url = _service().imageUrl(item, type: 'Backdrop');
      expect(url, contains('tag=primary-bd'));
    });
  });

  group('JellyfinUrlService.logoUrl', () {
    test('returns own logo URL when imageTags.Logo is present', () {
      const item = JellyfinItem(id: 'i1', imageTags: {'Logo': 'logo-tag'});
      final url = _service().logoUrl(item, maxWidth: 600);
      expect(url, contains('Items/i1/Images/Logo?tag=logo-tag&maxWidth=600'));
    });

    test('falls back to parent logo when own logo missing', () {
      const item = JellyfinItem(
        id: 'episode',
        parentLogoItemId: 'series',
        parentLogoImageTag: 'series-logo',
      );
      final url = _service().logoUrl(item);
      expect(url, contains('Items/series/Images/Logo?tag=series-logo'));
    });

    test('returns null when no logo is available', () {
      const item = JellyfinItem(id: 'i1');
      expect(_service().logoUrl(item), isNull);
    });
  });

  group('JellyfinUrlService.landscapeUrl', () {
    test('for non-episode prefers own backdrop', () {
      const item = JellyfinItem(id: 'i1', imageTags: {'Backdrop': 'bd-tag'});
      expect(_service().landscapeUrl(item), contains('tag=bd-tag'));
    });

    test('for non-episode falls back to backdropImageTags', () {
      const item = JellyfinItem(id: 'i1', backdropImageTags: ['list-bd']);
      expect(_service().landscapeUrl(item), contains('tag=list-bd'));
    });

    test('for non-episode falls back to own primary as last resort', () {
      const item = JellyfinItem(id: 'i1', imageTags: {'Primary': 'p-tag'});
      expect(
        _service().landscapeUrl(item),
        contains('Images/Primary?tag=p-tag'),
      );
    });

    test('for episode prefers episode still', () {
      const item = JellyfinItem(
        id: 'ep1',
        type: BaseItemKind.episode,
        imageTags: {'Primary': 'ep-still'},
      );
      expect(
        _service().landscapeUrl(item),
        contains('Items/ep1/Images/Primary?tag=ep-still'),
      );
    });

    test(
      'for episode falls back to parent backdrop, then series, then thumb',
      () {
        const ep1 = JellyfinItem(
          id: 'ep1',
          type: BaseItemKind.episode,
          parentBackdropItemId: 'series',
          parentBackdropImageTags: ['bd1'],
        );
        expect(_service().landscapeUrl(ep1), contains('Items/series'));

        const ep2 = JellyfinItem(
          id: 'ep2',
          type: BaseItemKind.episode,
          seriesId: 'srs',
          seriesPrimaryImageTag: 'srs-primary',
        );
        expect(
          _service().landscapeUrl(ep2),
          contains('Items/srs/Images/Primary'),
        );

        const ep3 = JellyfinItem(
          id: 'ep3',
          type: BaseItemKind.episode,
          parentThumbItemId: 'thumb-parent',
          parentThumbImageTag: 'thumb',
        );
        expect(
          _service().landscapeUrl(ep3),
          contains('Items/thumb-parent/Images/Thumb'),
        );
      },
    );

    test('returns null for an episode with no usable image', () {
      const item = JellyfinItem(id: 'ep', type: BaseItemKind.episode);
      expect(_service().landscapeUrl(item), isNull);
    });

    test('returns null for non-episode with no usable image', () {
      const item = JellyfinItem(id: 'i1');
      expect(_service().landscapeUrl(item), isNull);
    });
  });

  group('JellyfinUrlService.personUrl', () {
    test('builds the primary URL when both id and tag present', () {
      const person = JellyfinPerson(id: 'p1', primaryImageTag: 'face');
      final url = _service().personUrl(person, maxWidth: 200);
      expect(
        url,
        'https://jf.example.com/Items/p1/Images/Primary?tag=face&maxWidth=200&quality=90',
      );
    });

    test('returns null when either id or tag missing', () {
      expect(_service().personUrl(const JellyfinPerson(id: 'only-id')), isNull);
      expect(
        _service().personUrl(const JellyfinPerson(primaryImageTag: 'tag')),
        isNull,
      );
    });
  });

  group('JellyfinUrlService.trickplayTileUrl', () {
    test('produces a URL with ApiKey when session present', () {
      final url = _service(
        session: _session(accessToken: 'TK'),
      ).trickplayTileUrl(itemId: 'i1', width: 320, tileIndex: 5);
      expect(
        url,
        'https://jf.example.com/Videos/i1/Trickplay/320/5.jpg?ApiKey=TK',
      );
    });

    test('throws StateError when no session', () {
      expect(
        () =>
            _service().trickplayTileUrl(itemId: 'i1', width: 320, tileIndex: 0),
        throwsStateError,
      );
    });

    test('throws StateError when accessToken is empty', () {
      expect(
        () => _service(
          session: _session(accessToken: ''),
        ).trickplayTileUrl(itemId: 'i1', width: 320, tileIndex: 0),
        throwsStateError,
      );
    });
  });

  group('JellyfinUrlService.chapterUrl', () {
    test('builds the chapter image URL with quality', () {
      final url = _service().chapterUrl(
        itemId: 'i1',
        index: 3,
        tag: 'chap-tag',
        maxWidth: 320,
      );
      expect(
        url,
        'https://jf.example.com/Items/i1/Images/Chapter/3?tag=chap-tag&maxWidth=320&quality=90',
      );
    });

    test('omits maxWidth from the query when not provided', () {
      final url = _service().chapterUrl(itemId: 'i1', index: 0, tag: 'chap');
      expect(url, isNot(contains('maxWidth')));
      expect(url, contains('tag=chap'));
      expect(url, contains('quality=90'));
    });
  });

  group('JellyfinUrlService.streamUrl', () {
    test('produces a direct-play URL with static=true and ApiKey', () {
      final url = _service(
        session: _session(accessToken: 'TK'),
      ).streamUrl(itemId: 'i1', mediaSourceId: 'src');
      expect(
        url,
        'https://jf.example.com/Videos/i1/stream?static=true&mediaSourceId=src&ApiKey=TK',
      );
    });

    test('throws StateError when no session', () {
      expect(
        () => _service().streamUrl(itemId: 'i1', mediaSourceId: 'src'),
        throwsStateError,
      );
    });

    test('throws StateError when accessToken is empty', () {
      expect(
        () => _service(
          session: _session(accessToken: ''),
        ).streamUrl(itemId: 'i1', mediaSourceId: 'src'),
        throwsStateError,
      );
    });
  });

  test('joins URLs correctly when baseUrl has no trailing slash', () {
    final dio = Dio(BaseOptions(baseUrl: 'https://jf.example.com'));
    final service = JellyfinUrlService(dio: dio, session: null);
    const item = JellyfinItem(id: 'i1', imageTags: {'Primary': 't'});
    expect(service.imageUrl(item), startsWith('https://jf.example.com/Items/'));
  });
}
