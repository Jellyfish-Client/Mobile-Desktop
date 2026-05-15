import 'dart:math';

/// Strategy object that decides when a failing queued operation may be retried
/// and when it should be considered dead-lettered. Stateless on purpose — the
/// caller owns persistence (typically a Drift row carrying the columns from
/// `RetryableQueueEntry`).
///
/// The math is straightforward exponential backoff with symmetric jitter:
///
/// ```text
/// raw   = base * 2^attempts          // capped at `cap`
/// delay = raw * (1 + U(-jitter, jitter))
/// ```
///
/// Jitter spreads thundering-herd retries when many devices come back online
/// after a server outage. `random` is injectable so tests can pin it.
class BackoffPolicy {
  const BackoffPolicy({
    this.base = const Duration(seconds: 30),
    this.cap = const Duration(hours: 1),
    this.jitterFactor = 0.2,
    this.maxAttempts = 5,
  }) : assert(jitterFactor >= 0 && jitterFactor < 1, 'jitter must be in [0,1)'),
       assert(maxAttempts > 0, 'maxAttempts must be > 0');

  /// Convenience constructor matching the legacy "exponential with jitter"
  /// shorthand used by other queues. Defaults to the same base/cap as the
  /// primary constructor; `jitter` maps to `jitterFactor`.
  factory BackoffPolicy.exponential({
    Duration base = const Duration(seconds: 30),
    Duration cap = const Duration(hours: 1),
    double jitter = 0.2,
  }) => BackoffPolicy(base: base, cap: cap, jitterFactor: jitter);

  /// Initial delay applied to the first retry (attempts == 0 → base * 1).
  final Duration base;

  /// Hard ceiling on the raw (pre-jitter) delay. Past this point further
  /// attempts all share the same expected wait time.
  final Duration cap;

  /// Half-width of the symmetric jitter window, expressed as a fraction of the
  /// raw delay. `0.2` means "spread by ±20%".
  final double jitterFactor;

  /// Past this many failed attempts the entry is permanently dead-lettered:
  /// `nextRetryAt` returns null and `isEligible` returns false.
  final int maxAttempts;

  /// Computes the next retry instant given how many attempts have already
  /// failed (0-based: `attempts == 0` means "the first try just failed and we
  /// need to schedule attempt #2").
  ///
  /// Returns `null` once `attempts >= maxAttempts` — callers must treat that
  /// as "stop retrying, dead-letter the row".
  DateTime? nextRetryAt(int attempts, {DateTime? now, Random? random}) {
    if (attempts >= maxAttempts) return null;
    final clock = now ?? DateTime.now();
    final rng = random ?? Random();
    // `2^attempts` for attempts up to ~62 stays inside int range; we still
    // clamp early so a runaway counter can't blow up `pow`.
    final safeAttempts = attempts.clamp(0, 32);
    final factor = 1 << safeAttempts; // 2^safeAttempts
    final rawMicros = base.inMicroseconds * factor;
    final cappedMicros = rawMicros < cap.inMicroseconds
        ? rawMicros
        : cap.inMicroseconds;
    // Symmetric jitter in [-jitterFactor, +jitterFactor].
    final jitterMultiplier = 1 + (rng.nextDouble() * 2 - 1) * jitterFactor;
    final jitteredMicros = (cappedMicros * jitterMultiplier).round();
    // Guard against negative durations if jitterFactor ever drifts >= 1.
    final finalMicros = jitteredMicros < 0 ? 0 : jitteredMicros;
    return clock.add(Duration(microseconds: finalMicros));
  }

  /// True when the worker is allowed to pick up the row right now.
  ///
  /// Logic:
  /// - rows past `maxAttempts` are dead and never eligible;
  /// - rows with no scheduled retry are eligible immediately;
  /// - otherwise we wait until `nextRetryAt` is in the past.
  bool isEligible({
    required int attempts,
    required DateTime? nextRetryAt,
    DateTime? now,
  }) {
    if (attempts >= maxAttempts) return false;
    if (nextRetryAt == null) return true;
    final clock = now ?? DateTime.now();
    return !nextRetryAt.isAfter(clock);
  }
}
