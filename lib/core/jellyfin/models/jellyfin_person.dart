import 'package:jellyfin_api/jellyfin_api.dart';

/// Domain model for a person (`BaseItemPerson` in the SDK).
///
/// Keeps [PersonKind] from the SDK rather than re-declaring an enum — the
/// shape is stable and switching on `kind == PersonKind.actor` keeps callers
/// type-safe without an extra mapping step.
class JellyfinPerson {
  const JellyfinPerson({
    this.id,
    this.name,
    this.role,
    this.type,
    this.primaryImageTag,
  });

  final String? id;
  final String? name;
  final String? role;
  final PersonKind? type;
  final String? primaryImageTag;
}
