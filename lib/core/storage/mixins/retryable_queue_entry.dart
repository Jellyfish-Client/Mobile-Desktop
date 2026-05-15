import 'package:drift/drift.dart';

/// Shared retry-bookkeeping columns for any Drift table that represents a
/// queued operation drained by a background worker (sync queue, downloads,
/// future push-notification fan-outs...).
///
/// Applied via `with RetryableQueueEntry` on a `Table` subclass. Drift's
/// code-generator picks up the column getters declared on the mixin exactly as
/// if they were declared on the table itself, so a single source of truth
/// keeps `attempts` / `lastAttemptAt` / `nextRetryAt` / `lastError` semantics
/// aligned across queues.
///
/// Convention:
/// - `attempts` counts how many flush passes have already failed for the row
///   (0 means "never tried" or "tried successfully and was deleted").
/// - `lastAttemptAt` is stamped each time the worker touches the row, success
///   or failure.
/// - `nextRetryAt` is the soonest wall-clock time at which the worker is
///   allowed to retry. Null means "eligible immediately".
/// - `lastError` is the toString() of the last exception, kept verbatim for
///   debug surfaces. Never surfaced to end users.
mixin RetryableQueueEntry on Table {
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
}
