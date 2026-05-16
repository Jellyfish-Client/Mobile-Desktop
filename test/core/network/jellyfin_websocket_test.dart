import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/network/jellyfin_websocket.dart';
import 'package:jellyfish/core/network/jellyfin_ws_frame.dart';
import 'package:stream_channel/stream_channel.dart';

void main() {
  group('JellyfinWsFrame.decode', () {
    test('decodes a KeepAlive', () {
      final frame = JellyfinWsFrame.decode('{"MessageType":"KeepAlive"}');
      expect(frame, isA<JellyfinWsFrameKeepAlive>());
    });

    test('decodes a ForceKeepAlive with timeout', () {
      final frame = JellyfinWsFrame.decode(
        '{"MessageType":"ForceKeepAlive","Data":42}',
      );
      expect(frame, isA<JellyfinWsFrameForceKeepAlive>());
      expect((frame as JellyfinWsFrameForceKeepAlive).timeoutSeconds, 42);
    });

    test('falls back to Unknown on malformed JSON', () {
      final frame = JellyfinWsFrame.decode('not-json');
      expect(frame, isA<JellyfinWsFrameUnknown>());
    });

    test('falls back to Unknown on unrecognised MessageType', () {
      final frame = JellyfinWsFrame.decode(
        '{"MessageType":"SomeNewThing","Data":{}}',
      );
      expect(frame, isA<JellyfinWsFrameUnknown>());
    });
  });

  group('JellyfinWebSocket pump', () {
    test(
      'emits decoded frames received from the channel',
      () async {
        final controller = StreamChannelController<dynamic>();
        // `controller.foreign` exposes the side we hand off to the consumer
        // (here: our WebSocket service); `controller.local` is the test side.
        final ws = JellyfinWebSocket(
          accessToken: 'tok',
          deviceId: 'dev',
          serverUrl: 'https://example.com/',
          channelFactory: (_) => controller.foreign,
        )..start();

        final firstFrame = ws.frames.first;
        controller.local.sink.add('{"MessageType":"KeepAlive"}');
        final frame = await firstFrame.timeout(const Duration(seconds: 2));
        expect(frame, isA<JellyfinWsFrameKeepAlive>());

        unawaited(ws.dispose());
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );

    test(
      'schedules a reconnect after a non-intentional close',
      () async {
        // Each call to `channelFactory` is recorded. The first call serves
        // the initial connection ; subsequent calls validate that the backoff
        // timer actually re-issued a connect.
        final attempts = <StreamChannelController<dynamic>>[];
        final ws = JellyfinWebSocket(
          accessToken: 'tok',
          deviceId: 'dev',
          serverUrl: 'http://example.com/',
          channelFactory: (_) {
            final c = StreamChannelController<dynamic>();
            attempts.add(c);
            return c.foreign;
          },
        )..start();

        // Wait a tick so the listen() is wired, then close the active
        // controller's sink to simulate a server-side drop.
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(attempts.length, 1);
        await attempts.first.local.sink.close();

        // Backoff: first retry is at 1 s.
        await Future<void>.delayed(const Duration(milliseconds: 1500));
        expect(attempts.length, greaterThanOrEqualTo(2));

        // Stop without awaiting the dispose future — the lib uses
        // fire-and-forget close because real WebSocketChannel.sink.close()
        // can hang waiting for a peer that already disconnected.
        unawaited(ws.dispose());
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );
  });
}
