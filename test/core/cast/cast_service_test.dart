import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/cast/cast_device.dart';
import 'package:jellyfish/core/cast/cast_service.dart';
import 'package:jellyfish/core/cast/cast_session_state.dart';

/// Reproduit le pattern de `castSessionProvider` : émet [seed] immédiatement,
/// puis suit [tail]. Permet de tester le comportement sans passer par Riverpod.
Stream<T> _replayThenFollow<T>(T seed, Stream<T> tail) async* {
  yield seed;
  yield* tail;
}

void main() {
  group('CastSessionSnapshot', () {
    test('idle snapshot is the canonical empty state', () {
      const snap = CastSessionSnapshot.idle;
      expect(snap.status, CastConnectionStatus.idle);
      expect(snap.device, isNull);
      expect(snap.errorMessage, isNull);
      expect(snap.isConnected, isFalse);
    });

    test('copyWith produces an updated value with structural equality', () {
      const a = CastSessionSnapshot(
        status: CastConnectionStatus.connecting,
        device: CastDevice(id: 'tv-1', friendlyName: 'Living Room'),
      );
      final b = a.copyWith(status: CastConnectionStatus.connected);
      expect(b.status, CastConnectionStatus.connected);
      expect(b.device, a.device);
      expect(b == a, isFalse);
      expect(b == a.copyWith(status: CastConnectionStatus.connected), isTrue);
    });

    test('isConnected mirrors the status', () {
      const connected = CastSessionSnapshot(
        status: CastConnectionStatus.connected,
        device: CastDevice(id: 'tv-2', friendlyName: 'Kitchen'),
      );
      expect(connected.isConnected, isTrue);
    });
  });

  group('CastDevice', () {
    test('equality is identity by id', () {
      const a = CastDevice(id: 'x', friendlyName: 'TV A');
      const b = CastDevice(id: 'x', friendlyName: 'TV B (renamed)');
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different ids are not equal', () {
      const a = CastDevice(id: 'x', friendlyName: 'TV');
      const b = CastDevice(id: 'y', friendlyName: 'TV');
      expect(a == b, isFalse);
    });
  });

  group('CastService on unsupported platform', () {
    // Tests run on the dev host (Linux/macOS), where Platform.isIOS &
    // Platform.isAndroid are both false. ensureInitialized should mark the
    // feature as unsupported and never touch the native SDK.
    late CastService service;

    setUp(() {
      service = CastService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('starts in idle state', () {
      expect(service.currentSnapshot, CastSessionSnapshot.idle);
      expect(service.isSupported, isFalse);
    });

    test('ensureInitialized stays inert (no-op) and is idempotent', () async {
      await service.ensureInitialized();
      expect(service.isSupported, isFalse);
      // Second call must not retry or throw.
      await service.ensureInitialized();
      expect(service.isSupported, isFalse);
    });

    test('discovery + connect are no-ops when unsupported', () async {
      await service.ensureInitialized();
      await service.startDiscovery();
      await service.stopDiscovery();
      expect(await service.connectTo('any-id'), isFalse);
      await service.disconnect();
      expect(service.currentSnapshot, CastSessionSnapshot.idle);
    });

    test('devicesStream is empty when unsupported', () async {
      await service.ensureInitialized();
      // `Stream.empty()` closes immediately without emitting; collecting
      // it gives us an empty list rather than a timeout.
      final devices = await service.devicesStream.toList();
      expect(devices, isEmpty);
    });

    test(
        'sessionStream replay — un second abonné obtient le snapshot courant '
        'sans passer par AsyncLoading', () async {
      // Simule le pattern castSessionProvider :
      // _replayThenFollow(currentSnapshot, sessionStream).distinct()
      // Sur plateforme non supportée currentSnapshot est toujours idle.
      final replayStream =
          _replayThenFollow(service.currentSnapshot, service.sessionStream)
              .distinct();

      // Le premier événement doit arriver rapidement (async generator).
      CastSessionSnapshot? firstEvent;
      final sub = replayStream.listen((s) => firstEvent ??= s);
      // Pump quelques microtasks pour que l'async* generator démarre.
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(
        firstEvent,
        equals(CastSessionSnapshot.idle),
        reason: 'Le premier événement doit être le snapshot courant, '
            'pas null (i.e. pas de flash AsyncLoading)',
      );
    });

    test(
        'sessionStream replay — distinct() supprime les doublons consécutifs',
        () async {
      final replayStream =
          _replayThenFollow(service.currentSnapshot, service.sessionStream)
              .distinct();

      final events = <CastSessionSnapshot>[];
      final sub = replayStream.listen(events.add);
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      // sessionStream n'émet rien sur plateforme non supportée → un seul event.
      expect(events, hasLength(1));
      expect(events.first, CastSessionSnapshot.idle);
    });
  });
}
