import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../app/theme/breakpoints.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/widgets.dart';

/// Compact, no-backdrop hero for an actor / person page. Vertical centred
/// layout on mobile; horizontal on tablet & desktop. Avatar is wrapped in a
/// [Hero] so the round photo from a `_CastTile` (or search tile) animates
/// into place.
class PersonHero extends StatelessWidget {
  const PersonHero({
    required this.personId,
    required this.name,
    required this.titleCount,
    this.imageUrl,
    super.key,
  });

  final String personId;
  final String name;
  final int titleCount;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final isPhone = context.isPhone;
    final avatarSize = isPhone ? 96.0 : 120.0;

    final avatar = Hero(
      tag: 'person-avatar-$personId',
      child: ClipOval(
        child: SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.surfaceContainerHigh),
                  errorWidget: (_, __, ___) =>
                      JfAvatarInitials(name: name, fontSize: isPhone ? 32 : 38),
                )
              : JfAvatarInitials(name: name, fontSize: isPhone ? 32 : 38),
        ),
      ),
    );

    final headline = _Headline(name: name, titleCount: titleCount);

    Widget body;
    if (isPhone) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            label: context.l10n.personPhotoSemantics(name),
            image: true,
            child: avatar,
          ),
          const SizedBox(height: AppSpacing.lg),
          headline,
        ],
      );
    } else {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Semantics(
            label: context.l10n.personPhotoSemantics(name),
            image: true,
            child: avatar,
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(child: headline),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        0,
      ),
      child: body,
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.name, required this.titleCount});

  final String name;
  final int titleCount;

  @override
  Widget build(BuildContext context) {
    final isPhone = context.isPhone;
    final l = context.l10n;
    return Column(
      crossAxisAlignment: isPhone
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: isPhone ? TextAlign.center : TextAlign.start,
          style: AppTypography.display(
            size: isPhone ? 30 : 36,
            weight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l.personPageTitleCount(l.personPageRole, titleCount),
          textAlign: isPhone ? TextAlign.center : TextAlign.start,
          style: AppTypography.eyebrow(color: AppColors.onSurfaceMuted),
        ),
      ],
    );
  }
}
