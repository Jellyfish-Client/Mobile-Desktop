import '../../core/jellyfin/models/jellyfin_item.dart';
import '../../core/seerr/models.dart';

/// One item eligible for the home hero carousel — unified across the two
/// data sources so the carousel widget stays agnostic.
sealed class HeroFeaturedItem {
  const HeroFeaturedItem();

  String get id;
  String get title;
  String? get overview;
}

final class HeroJellyfinItem extends HeroFeaturedItem {
  const HeroJellyfinItem(this.item);

  final JellyfinItem item;

  @override
  String get id => 'jf_${item.id}';

  @override
  String get title => item.name ?? '';

  @override
  String? get overview => item.overview;
}

final class HeroSeerrItem extends HeroFeaturedItem {
  const HeroSeerrItem(this.media);

  final SeerrMedia media;

  @override
  String get id => 'seer_${media.tmdbId}_${media.type.name}';

  @override
  String get title => media.title;

  @override
  String? get overview => media.overview;
}
