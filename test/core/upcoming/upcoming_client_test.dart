import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/upcoming/models.dart';
import 'package:jellyfish/core/upcoming/upcoming_client.dart';

UpcomingClient _client(_FakeAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://example.test/'))
    ..httpClientAdapter = adapter;
  return UpcomingClient(dio);
}

void main() {
  group('UpcomingClient.get', () {
    test('parses a mixed movie/episode payload', () async {
      final client = _client(
        _FakeAdapter((opts) {
          expect(opts.path, contains('jellyfish/upcoming'));
          return ResponseBody.fromString(
            jsonEncode({
              'count': 2,
              'windowStart': '2026-05-13T00:00:00Z',
              'windowEnd': '2026-06-12T00:00:00Z',
              'items': [
                {
                  'kind': 'movie',
                  'releaseDate': '2026-05-20T00:00:00Z',
                  'title': 'The Big One',
                  'year': 2026,
                  'overview': 'Synopsis',
                  'posterUrl': 'http://example.test/poster.jpg',
                  'hasFile': false,
                  'sourceId': 42,
                },
                {
                  'kind': 'episode',
                  'releaseDate': '2026-05-22T00:00:00Z',
                  'title': 'Pilot',
                  'seriesTitle': 'New Show',
                  'seasonNumber': 1,
                  'episodeNumber': 1,
                  'overview': 'Synopsis',
                  'posterUrl': '',
                  'hasFile': true,
                  'sourceId': 17,
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          );
        }),
      );

      final items = await client.get();
      expect(items, hasLength(2));

      final movie = items[0];
      expect(movie, isA<UpcomingMovie>());
      final m = movie as UpcomingMovie;
      expect(m.title, 'The Big One');
      expect(m.year, 2026);
      expect(m.hasFile, isFalse);
      expect(m.sourceId, 42);

      final episode = items[1];
      expect(episode, isA<UpcomingEpisode>());
      final e = episode as UpcomingEpisode;
      expect(e.seriesTitle, 'New Show');
      expect(e.seasonNumber, 1);
      expect(e.episodeNumber, 1);
      expect(e.hasFile, isTrue);
      expect(e.posterUrl, '');
    });

    test('skips items with unknown kind or missing dates', () async {
      final client = _client(
        _FakeAdapter((opts) {
          return ResponseBody.fromString(
            jsonEncode({
              'items': [
                {'kind': 'person', 'releaseDate': '2026-05-20T00:00:00Z'},
                {'kind': 'movie', 'title': 'No date'},
                {
                  'kind': 'movie',
                  'releaseDate': '2026-06-01T00:00:00Z',
                  'title': 'OK',
                  'hasFile': false,
                  'sourceId': 1,
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          );
        }),
      );

      final items = await client.get();
      expect(items, hasLength(1));
      expect(items.single, isA<UpcomingMovie>());
      expect((items.single as UpcomingMovie).title, 'OK');
    });

    test('forwards the query parameters', () async {
      late RequestOptions captured;
      final client = _client(
        _FakeAdapter((opts) {
          captured = opts;
          return ResponseBody.fromString(
            jsonEncode({'items': <Map<String, dynamic>>[]}),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          );
        }),
      );

      await client.get(
        days: 90,
        kinds: const {UpcomingKind.episodes},
        onlyMissing: false,
        limit: 200,
      );

      expect(captured.queryParameters['days'], 90);
      expect(captured.queryParameters['kinds'], 'episodes');
      expect(captured.queryParameters['onlyMissing'], false);
      expect(captured.queryParameters['limit'], 200);
    });
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
