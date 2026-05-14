import 'package:flutter/material.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/seerr/models.dart';
import '../../../shared/widgets/widgets.dart';

/// Poster card for an item that isn't in the Jellyfin library yet but is
/// available on Seerr. Reuses [JfPosterCard] dimmed, with an overlay badge
/// whose icon/colour depend on the Seerr [availability]:
///   - `unknown`  → primary-tinted cloud icon (requestable).
///   - `pending`/`processing` → muted schedule icon (already requested).
///
/// Tapping the card is the caller's responsibility — typically it opens
/// `showSeerrRequestSheet` so the user sees the poster, overview and the
/// season picker before submitting.
class MissingPosterCard extends StatelessWidget {
  const MissingPosterCard({
    required this.title,
    this.imageUrl,
    this.subtitle,
    this.availability = SeerrAvailability.unknown,
    this.onTap,
    super.key,
  });

  final String title;
  final String? imageUrl;
  final String? subtitle;
  final SeerrAvailability availability;
  final VoidCallback? onTap;

  bool get _pending =>
      availability == SeerrAvailability.pending ||
      availability == SeerrAvailability.processing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = _pending ? scheme.tertiary : scheme.primary;
    final fg = _pending ? scheme.onTertiary : scheme.onPrimary;
    final icon = _pending ? Icons.schedule : Icons.cloud_download_outlined;
    return JfPosterCard(
      title: title,
      imageUrl: imageUrl,
      subtitle: subtitle,
      onTap: onTap,
      dimmed: true,
      overlay: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: fg),
      ),
    );
  }
}
