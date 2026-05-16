import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart' show PersonKind;

import '../../../app/theme/app_spacing.dart';
import '../../../core/jellyfin/jellyfin_url_service.dart';
import '../../../core/jellyfin/models/jellyfin_item.dart';
import '../../../core/jellyfin/models/jellyfin_person.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';

/// Horizontal carousel of actors with a round photo, name and role.
/// Hides itself when no Actor-typed people are available.
class CastRow extends ConsumerWidget {
  const CastRow({required this.item, super.key});

  final JellyfinItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer actors; if the item is missing PersonKind annotations entirely,
    // fall back to the full list so we still surface something.
    var cast = item.people.where((p) => p.type == PersonKind.actor).toList();
    if (cast.isEmpty) cast = item.people;
    if (cast.isEmpty) return const SizedBox.shrink();

    final urls = ref.watch(jellyfinUrlServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JfSectionTitle(title: context.l10n.castSectionTitle),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: cast.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) => _CastTile(person: cast[i], urls: urls),
          ),
        ),
      ],
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.person, required this.urls});

  final JellyfinPerson person;
  final JellyfinUrlService urls;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final url = urls.personUrl(person, maxWidth: 200);
    final name = person.name ?? '';
    final role = person.role ?? '';
    final personId = person.id;

    final avatar = Hero(
      tag: 'person-avatar-${personId ?? name}',
      child: ClipOval(
        child: SizedBox(
          width: 84,
          height: 84,
          child: url != null
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: scheme.surfaceContainerHigh),
                  errorWidget: (_, __, ___) => JfAvatarInitials(name: name),
                )
              : JfAvatarInitials(name: name),
        ),
      ),
    );

    final tile = SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          avatar,
          const SizedBox(height: AppSpacing.sm),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (role.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );

    if (personId == null) return tile;

    return JfTappable(
      semanticLabel: name,
      onTap: () => context.push('/person/$personId'),
      borderRadius: BorderRadius.circular(8),
      child: tile,
    );
  }
}
