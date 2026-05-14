import '../storage/app_database.dart';
import 'saved_account.dart';
import 'session.dart';

/// Canonical "account key" used as the foreign-key-style identifier for
/// account-scoped rows across the app (Drift tables, providers, etc.).
///
/// Format: `"<serverId>|<userId>"`. Falls back to [legacyAccountKey] when
/// no session is active, which matches the value stamped on rows that
/// pre-date the multi-account migration (Drift schema < 4).
String accountKeyForSession(Session? session) {
  if (session == null) return legacyAccountKey;
  return '${session.serverId}|${session.userId}';
}

String accountKeyForSaved(SavedAccount account) => account.key;
