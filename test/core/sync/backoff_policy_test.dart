import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfish/core/sync/backoff_policy.dart';

void main() {
  group('BackoffPolicy.nextRetryAt', () {
    // Pin a fixed clock so we can reason about durations as deltas instead of
    // absolute timestamps. Real-time tests are flaky and we already pin the
    // RNG below.
    final fixedNow = DateTime.utc(2026);
    const policy = BackoffPolicy(
      base: Duration(seconds: 30),
      cap: Duration(hours: 1),
      jitterFactor: 0.2,
    );

    test('returns delays within the expected jitter window for attempts 0..4', () {
      // Seeded RNG → deterministic jitter, but we only assert the window,
      // never an exact value (a future Dart RNG bump shouldn't break us).
      for (var attempts = 0; attempts < policy.maxAttempts; attempts++) {
        final retryAt = policy.nextRetryAt(
          attempts,
          now: fixedNow,
          random: Random(42 + attempts),
        );
        expect(retryAt, isNotNull, reason: 'attempts=$attempts');

        final rawMicros = policy.base.inMicroseconds * (1 << attempts);
        final cappedMicros = rawMicros < policy.cap.inMicroseconds
            ? rawMicros
            : policy.cap.inMicroseconds;
        final minDelta = Duration(
          microseconds: (cappedMicros * (1 - policy.jitterFactor)).floor(),
        );
        final maxDelta = Duration(
          microseconds: (cappedMicros * (1 + policy.jitterFactor)).ceil(),
        );

        final actualDelta = retryAt!.difference(fixedNow);
        expect(
          actualDelta >= minDelta,
          isTrue,
          reason: 'attempts=$attempts: $actualDelta < $minDelta',
        );
        expect(
          actualDelta <= maxDelta,
          isTrue,
          reason: 'attempts=$attempts: $actualDelta > $maxDelta',
        );
      }
    });

    test('caps the raw delay before applying jitter', () {
      // attempts=10 → 2^10 * 30s = ~8.5h, which must collapse onto the 1h cap
      // (±20% jitter). Without the cap we'd schedule retries that effectively
      // never fire.
      final retryAt = policy.nextRetryAt(
        10,
        now: fixedNow,
        random: Random(7),
      );
      // attempts=10 is below the default maxAttempts of 5? No — 10 >= 5, so
      // we expect null. Use a lower-maxAttempts policy to reach the cap
      // branch.
      expect(retryAt, isNull);

      const generousPolicy = BackoffPolicy(
        base: Duration(seconds: 30),
        cap: Duration(hours: 1),
        jitterFactor: 0.2,
        maxAttempts: 20,
      );
      final cappedRetry = generousPolicy.nextRetryAt(
        10,
        now: fixedNow,
        random: Random(7),
      );
      final delta = cappedRetry!.difference(fixedNow);
      // Upper bound: cap * (1 + jitter) = 1h * 1.2 = 1h12m.
      expect(delta <= const Duration(hours: 1, minutes: 12), isTrue);
      // Lower bound: cap * (1 - jitter) = 1h * 0.8 = 48m.
      expect(delta >= const Duration(minutes: 48), isTrue);
    });

    test('returns null once attempts == maxAttempts', () {
      expect(
        policy.nextRetryAt(policy.maxAttempts, now: fixedNow),
        isNull,
      );
      expect(
        policy.nextRetryAt(policy.maxAttempts + 3, now: fixedNow),
        isNull,
      );
    });

    test('zero jitter produces a deterministic delay equal to the raw value', () {
      const deterministic = BackoffPolicy(
        base: Duration(seconds: 30),
        cap: Duration(hours: 1),
        jitterFactor: 0,
      );
      final retryAt = deterministic.nextRetryAt(
        2,
        now: fixedNow,
        random: Random(0),
      );
      // 2^2 * 30s = 120s exactly.
      expect(
        retryAt!.difference(fixedNow),
        const Duration(seconds: 120),
      );
    });
  });

  group('BackoffPolicy.isEligible', () {
    const policy = BackoffPolicy();
    final now = DateTime.utc(2026, 5, 15, 12);

    test('eligible when attempts < max and nextRetryAt is null', () {
      expect(
        policy.isEligible(attempts: 0, nextRetryAt: null, now: now),
        isTrue,
      );
      expect(
        policy.isEligible(attempts: 3, nextRetryAt: null, now: now),
        isTrue,
      );
    });

    test('not eligible when nextRetryAt is in the future', () {
      final future = now.add(const Duration(minutes: 5));
      expect(
        policy.isEligible(attempts: 1, nextRetryAt: future, now: now),
        isFalse,
      );
    });

    test('eligible when nextRetryAt is in the past (or now)', () {
      final past = now.subtract(const Duration(seconds: 1));
      expect(
        policy.isEligible(attempts: 1, nextRetryAt: past, now: now),
        isTrue,
      );
      // `nextRetryAt == now` is also eligible — we don't make workers wait
      // an extra tick for an exact tie.
      expect(
        policy.isEligible(attempts: 1, nextRetryAt: now, now: now),
        isTrue,
      );
    });

    test('never eligible once attempts >= maxAttempts (dead-lettered)', () {
      final past = now.subtract(const Duration(hours: 2));
      expect(
        policy.isEligible(
          attempts: policy.maxAttempts,
          nextRetryAt: past,
          now: now,
        ),
        isFalse,
      );
      expect(
        policy.isEligible(
          attempts: policy.maxAttempts,
          nextRetryAt: null,
          now: now,
        ),
        isFalse,
      );
    });
  });

  group('BackoffPolicy.exponential factory', () {
    test('maps `jitter` onto `jitterFactor` and keeps default base/cap', () {
      final p = BackoffPolicy.exponential(jitter: 0.1);
      expect(p.base, const Duration(seconds: 30));
      expect(p.cap, const Duration(hours: 1));
      expect(p.jitterFactor, 0.1);
      expect(p.maxAttempts, 5);
    });
  });
}
