# Plan v1 — 6 items urgents

**Total estimé : ~10 demi-journées (~2 semaines plein temps)**, parallélisable en 3 phases.

Ancré dans le repo : Riverpod 2 manuel (pas de codegen), Drift pour downloads + sync queue, `flutter_secure_storage` + `shared_preferences`, lints `very_good_analysis` strict (`avoid_positional_boolean_parameters` → setters bool en `({required bool value})`), FR-only (pas d'`.arb`).

---

## Phase 1 — indépendants, parallélisables (3.5 j)

### 1. Favoris + Mark watched/unwatched — 1.5 j

**État existant :**
- `JellyfinClient.markPlayed/markUnplayed/markFavorite/unmarkFavorite` déjà en place (`lib/core/jellyfin/jellyfin_client.dart:339-365`)
- `SyncOperation` Drift gère déjà le rejeu offline (`addFavorite`, `removeFavorite`, `markPlayed`, `markUnplayed` dans `lib/core/sync/sync_service.dart:120-128`)
- `OfflineDetailScreen` a déjà ces boutons ; les écrans online (`MovieDetailView`, `SeriesDetailView`, `EpisodeDetailView`) ne les ont pas

**Fichiers à créer / modifier :**
- **Créer** `lib/features/details/widgets/user_data_actions.dart`
  - `ConsumerStatefulWidget(BaseItemDto)` rendant deux `IconButton` (♥, ✓)
  - Optimistic update + appel client + enqueue `SyncOperation` si offline
  - Invalidation cascade : `itemProvider(id)`, `resumeItemsProvider`, `nextUpItemsProvider`, `latestItemsProvider`, `recommendationRailsProvider`, `favoriteItemsProvider`
- **Modifier** `lib/features/details/movie_detail_screen.dart` (insérer après `JfButton.primary`, ~ligne 145)
- **Modifier** `lib/features/details/series_detail_screen.dart` (insérer sous `_NextUpCta`, ~ligne 135)
- **Modifier** `lib/features/details/episode_detail_screen.dart` (remplacer chip "Watched" statique ~ligne 115-120)
- **Créer** `lib/features/home/widgets/favorites_rail_section.dart`
- **Modifier** `lib/features/home/home_section.dart` : ajouter `final class HomeFavoritesRail extends HomeSection`
- **Modifier** `lib/features/home/home_catalog.dart` : insérer `HomeFavoritesRail(id: 'favoris', title: 'Mes favoris')` dans `kHomeQueue` (après `pepites`)
- **Modifier** `lib/features/home/home_providers.dart` : `favoriteItemsProvider` via `_CachedListNotifier<BaseItemDto>` (cacheKey `'favorites_v1'`)
- **Modifier** `lib/core/jellyfin/jellyfin_client.dart` : `favoriteItems({int limit = 60})` → `getItems(userId, isFavorite: true, includeItemTypes: [movie, series, episode], sortBy: [datePlayed/sortName], recursive: true)`
- **Modifier** `lib/features/home/home_screen.dart` : ajouter `ref.invalidate(favoriteItemsProvider)` au `onRefresh`
- **Modifier** `lib/features/library/library_screen.dart` + `library_providers.dart` : chip "Favoris" qui force `isFavorite: true`

**Long-press sheet partagé :**
- **Créer** `lib/shared/widgets/jf_item_context_menu.dart` : `showItemContextMenu(...)` → `showModalBottomSheet` listant "Lire / Marquer vu / Favoris / Télécharger"
- **Modifier** `lib/shared/widgets/jf_poster_card.dart`, `jf_landscape_card.dart`, `jf_episode_tile.dart` : `onLongPress` optionnel
- **Modifier** `lib/features/home/widgets/jellyfin_rail.dart` (`RailShell` / `LandscapeRow` / `PosterRow`) pour câbler le callback

**Endpoints SDK :**
- `playstateApi.markPlayedItem` / `markUnplayedItem` (wrappés)
- `userLibraryApi.markFavoriteItem` / `unmarkFavoriteItem` (wrappés)
- `itemsApi.getItems(isFavorite: true)`

**Décisions à arbitrer :**
- Favori sur série : on toggle la série elle-même, pas les épisodes (Jellyfin ne cascade pas)
- Mark-watched sur série : exposer "Marquer toute la série vue" depuis long-press uniquement ?
- Long-press depuis Home rails : on / off ?

**Risque clé :** lister exhaustivement les `ref.invalidate` post-mutation pour éviter UI désynchronisée.

---

### 3. Playback settings — 1.5 j

**État existant :**
- `PlaybackSettingsScreen` est un stub ("Aucune option pour l'instant")
- Pattern à suivre : `DownloadSettingsController` (`lib/core/downloads/download_settings.dart` + `lib/features/settings/downloads_settings_screen.dart:31-56`)

**Fichiers à créer / modifier :**
- **Créer** `lib/core/playback/playback_preferences.dart`
  - Modèle immutable : `autoPlayNext: bool`, `autoSkipIntro: bool`, `autoSkipOutro: bool`, `preferredAudioLang: String?`, `preferredSubtitleLang: String?` (codes ISO-639-2/B 3 lettres : `fre`, `eng`)
  - `static const defaults` (autoPlayNext: true, skips: false, langs: null)
  - `copyWith`, équality
  - `PlaybackPreferencesController extends AsyncNotifier<PlaybackPreferences>` lisant/écrivant `SharedPreferences` (clés `playback.autoPlayNext`, etc.)
  - Setters : `setAutoPlayNext({required bool value})`, etc.
- **Créer** `lib/core/playback/iso_languages.dart` : liste statique (FR, EN, ES, DE, IT, PT, JA, KO, ZH, RU, NL, AR, SV, NO, DA, FI, PL, TR + "Aucune préférence")
- **Réécrire** `lib/features/settings/playback_settings_screen.dart`
  - `ConsumerWidget` qui watch `playbackPreferencesProvider`
  - Sections "Lecture auto" (SwitchListTile autoPlayNext), "Sauts auto" (intro/outro), "Langues préférées" (2 `ListTile` ouvrant un `showDialog` de sélection radio)
- **Modifier** `lib/features/player/player_screen.dart`
  - Dans `_initialize()` après `backend.open(...)` : lire prefs et appliquer `_applyPreferredTracks(backend, prefs)` (match case-insensitive sur `track.language` avec map de normalisation 2→3 lettres)
  - Dans `_onPosition` / `_updateSkipSegment` : auto-seek si `prefs.autoSkipIntro` et segment intro actif (idem outro)
  - Dans `_completedSub` / `_maybeTriggerNextUp` : si `prefs.autoPlayNext`, lancer un timer 5s annulable qui déclenche `_playNextUp()`

**Providers :**
```dart
final playbackPreferencesProvider =
    AsyncNotifierProvider<PlaybackPreferencesController, PlaybackPreferences>(
  PlaybackPreferencesController.new,
);
```

**Décisions à arbitrer :**
- Format codes ISO : 3 lettres + normalisation 2→3 via map (mpv expose souvent 3 lettres mais pas toujours)
- Auto-play next : countdown 5s annulable (conserve NextUpOverlay actuel) vs immédiat
- Auto-skip s'applique aux Jellyfin Media Segments uniquement, pas de détection silence/black-frame

---

### 4. Sous-titres delay/offset — 0.5 j

**État existant :**
- `MediaKitPlayerBackend` et `PlayerBackend` (abstract) n'exposent rien pour le delay
- media_kit 1.2.6 → on passe par `_player.platform.setProperty('sub-delay', seconds)` (mpv property)
- Sheet existant `subtitle_audio_sheet.dart` ne gère que la sélection

**Fichiers à modifier :**
- **Modifier** `lib/core/playback/player_backend.dart` : ajouter `Future<void> setSubtitleDelay(Duration)` + getter `Duration get subtitleDelay` (impl par défaut no-op pour backends non-MediaKit futurs)
- **Modifier** `lib/core/playback/media_kit_player_backend.dart`
  ```dart
  @override
  Future<void> setSubtitleDelay(Duration delay) async {
    _subtitleDelay = delay;
    final seconds = delay.inMicroseconds / 1e6;
    try {
      final platform = (_player as dynamic).platform;
      await platform?.setProperty('sub-delay', seconds.toStringAsFixed(3));
    } catch (e, st) {
      _log.warning('setSubtitleDelay failed', e, st);
    }
  }
  ```
  - Réappliquer l'offset si on change de piste sous-titre
- **Modifier** `lib/features/player/widgets/subtitle_audio_sheet.dart`
  - Nouveau `_SubtitleDelayPanel` : `Slider` -10s → +10s pas 0.1s, boutons `−0.1s / Reset / +0.1s`, debounce 100ms
  - Caché si `backend.currentSubtitleIndex < 0`

**Décisions à arbitrer :**
- Persistance par item : **non v1**, reset à chaque `backend.open`
- Range slider : ±10s par défaut, étendre si feedback

**Risques :**
- `Player.platform.setProperty` est marqué "use only if you know what you are doing" — `try/catch` + log
- Backend web : `_player.platform` peut être null → garde nullable

---

## Phase 2 — après Phase 1 (2.5 j)

### 2. Filtres + tris Library — 1.5 j

**État existant :**
- `LibraryNotifier.fetch()` appelle `queryItems(...)` mais ne passe **pas** `genres`, `years`, `isFavorite`, `isPlayed`, `minCommunityRating`
- `JellyfinClient.queryItems` accepte `sortBy: String` / `sortOrder: String` simplement
- Enum `ItemSortBy` dispo : `sortName`, `dateCreated`, `premiereDate`, `communityRating`, `random`, `productionYear`, `runtime` (`packages/jellyfin_api/lib/src/model/item_sort_by.dart`)
- L'API `getItems` SDK supporte tous les filtres souhaités

**Fichiers à créer / modifier :**
- **Créer** `lib/features/library/library_filters.dart` (Freezed, déjà en dep)
  - `LibraryFilters { bool? isFavorite, bool? isUnplayed, Set<String> genres, int? yearMin, int? yearMax, double? minRating }`
  - `LibrarySort { ItemSortBy by, SortOrder order }`
  - `LibrarySort.defaults` = (sortName, ascending)
  - Helper `toQueryParams()`
- **Modifier** `lib/features/library/library_providers.dart`
  - Étendre `LibraryState` avec `filters: LibraryFilters` + `sort: LibrarySort`
  - Méthodes `setFilters`, `setSort`, `clearFilters` qui bump `_gen` et relancent `fetch()`
  - Ajouter `availableGenresProvider = FutureProvider.autoDispose.family<List<String>, String?>` (parentId)
- **Modifier** `lib/core/jellyfin/jellyfin_client.dart` : enrichir `queryItems` avec params filtres + `sortBy: List<ItemSortBy>?` + `sortOrder: SortOrder?`
- **Créer** `lib/features/library/widgets/library_filter_sheet.dart`
  - `showModalBottomSheet` (isScrollControlled)
  - Section Tris : `RadioListTile` par `ItemSortBy` + toggle ASC/DESC
  - Section Filtres : `SwitchListTile` Favoris / Non-vus
  - Section Genres : `Wrap` de `FilterChip` peuplés depuis `availableGenresProvider`
  - Section Année : `RangeSlider` 1900–année courante
  - Section Note min : `Slider` 0–10 pas 0.5
  - Boutons "Réinitialiser" / "Appliquer"
- **Modifier** `lib/features/library/library_screen.dart`
  - `IconButton(Icons.tune)` dans `SliverAppBar.actions`
  - Rangée d'indicateurs de filtres actifs (chips removables) sous la barre

**Endpoints SDK :**
- `itemsApi.getItems(genres, years, isFavorite, isPlayed, minCommunityRating, sortBy: BuiltList<ItemSortBy>, sortOrder: BuiltList<SortOrder>)`
- `genresApi.getGenres(userId, parentId, includeItemTypes)`

**Décisions à arbitrer :**
- Persistance par section (clé `library.filters.{viewId}` SharedPrefs) **vs** in-memory only
- Reset des filtres au changement de view : oui (recommandé)

**Risques :**
- `LibraryFilters` immutable → Freezed (déjà en dep)

---

### 5. Page personne — 1 j

**État existant :**
- Aucune route `/person/:id` dans `lib/app/router.dart`
- `_CastTile` dans `lib/features/details/widgets/cast_row.dart` n'a aucun `onTap` (mais `BaseItemPerson.id` est dispo)
- `userLibraryApi.getItem(userId, itemId: personId)` retourne le `BaseItemDto` personne (Primary image + overview = bio)
- `ItemsApi.getItems(personIds: [...])` retourne la filmographie

**Fichiers à créer / modifier :**
- **Créer** `lib/features/person/person_screen.dart`
  - `CustomScrollView` avec hero portrait 220×320, nom, bio (Text full v1), date+lieu naissance
  - Section "Films" + Section "Séries" en grilles séparées
  - Tap poster → `context.push('/items/${item.id}')`
- **Créer** `lib/features/person/person_providers.dart`
  ```dart
  final personItemProvider = FutureProvider.autoDispose.family<BaseItemDto, String>(
    (ref, id) => ref.watch(jellyfinClientProvider).item(id),
  );

  final personFilmographyProvider = FutureProvider.autoDispose
      .family<({List<BaseItemDto> movies, List<BaseItemDto> series}), String>(
    (ref, id) => ref.watch(jellyfinClientProvider).personFilmography(id),
  );
  ```
- **Modifier** `lib/core/jellyfin/jellyfin_client.dart` : `personFilmography(String personId)` qui split par `BaseItemKind`
- **Modifier** `lib/app/router.dart` : `GoRoute(path: '/person/:id', builder: ...)` (hors IndexedStack, comme `/items/:id`)
- **Modifier** `lib/features/details/widgets/cast_row.dart` : `_CastTile` dans un `InkWell` (`onTap` conditionnel sur `person.id != null` et `!offline`)

**Endpoints SDK :**
- `userLibraryApi.getItem(userId, itemId: personId)`
- `itemsApi.getItems(personIds: [id], includeItemTypes: [movie, series], recursive: true, fields: [overview, productionYear], sortBy: [premiereDate], sortOrder: [descending])`

**Décisions à arbitrer :**
- Bio longue : v1 = `Text` full sans expand/collapse
- Tri filmographie : DESC sur `premiereDate` (récent d'abord)
- Comportement offline : désactiver le tap (`offlineModeProvider`)

**Risques :**
- Personne sans bio ni image → empty state
- `getItems(personIds:)` retourne aussi les épisodes → filtrer par `includeItemTypes` côté query

---

## Phase 3 — isolé, à finir en dernier (2 j)

### 6. MediaSession Android / NowPlaying iOS — 2 j

**État existant :**
- **Absent du repo**. Pas d'`audio_service` dans pubspec
- media_kit ne déclare pas de `MediaSessionCompat` Android ni `MPNowPlayingInfoCenter` iOS

**Stratégie :** intégrer `audio_service: ^0.18.x` (couche pure-Dart neutre vis-à-vis du backend de lecture).

**Fichiers à modifier / créer :**
- **Modifier** `pubspec.yaml` : `audio_service: ^0.18.16`
- **Modifier** `android/app/src/main/AndroidManifest.xml`
  - Déclarer `<service android:name="com.ryanheise.audioservice.AudioService" ...>`
  - Permissions `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (Android 14+)
- **Modifier** `ios/Runner/Info.plist` : confirmer `UIBackgroundModes → audio` (déjà présent vu PiP)
- **Créer** `lib/core/playback/media_session_service.dart`
  - `JellyfishAudioHandler extends BaseAudioHandler`
  - Écoute `backend.positionStream`, `stateStream`, `completedStream` → met à jour `playbackState`
  - Implémente `play / pause / seek / skipToNext / skipToPrevious / stop` qui délèguent au backend (skipNext via `playerNextUpProvider`)
  - Push `MediaItem(id, title, artist: seriesName, artUri: posterUrl, duration)` à chaque changement
- **Modifier** `lib/main.dart` : `await AudioService.init(builder: () => JellyfishAudioHandler(...), config: ...)` au boot, expose via `Provider<JellyfishAudioHandler>` overridé
- **Modifier** `lib/features/player/player_screen.dart`
  - Dans `_initialize()` après `backend.open()` : push `MediaItem` au handler
  - Sur `dispose` : handler `stop()` pour clear la notification système

**Providers :**
```dart
final audioHandlerProvider = Provider<JellyfishAudioHandler>((ref) {
  throw UnimplementedError('Set via override in main()');
});
```

**Décisions à arbitrer :**
- CarPlay / Android Auto : **out-of-scope v1**
- PiP × MediaSession : ne pas pousser de notification quand `_inPip == true` (PiP fournit déjà les contrôles)
- Headphone media keys : vérifier non-collision avec `volume_controller` / `_initMuteSubtitleSync`

**Risques :**
- `BaseAudioHandler` à vie globale **vs** `autoDispose` du `playerBackendProvider` → le handler garde une ref au backend courant via setter ; PlayerScreen pousse au mount, retire au dispose
- Android 14 (API 34) : test obligatoire sur Pixel 7+
- Compat media_kit + audio_service : sanity-test casque BT (déclencheur connu de bugs)

---

## Ordre & dépendances

```
Phase 1 (parallèle)      Phase 2 (suit Phase 1)        Phase 3 (en queue)
├─ Item 1 (1.5j) ────────┬─ Item 2 (1.5j)               Item 6 (2j)
├─ Item 3 (1.5j) ─┐      └─ Item 5 (1j)
└─ Item 4 (0.5j) ─┴──────────────────────────────────── (touche PlayerScreen,
                                                          mieux en dernier)
```

- Phase 1 = 3.5j (1.5 + 1.5 + 0.5 en parallèle, ou 3.5 en séquentiel)
- Phase 2 = 2.5j
- Phase 3 = 2j
- **Séquentiel 1 dev** : ~10 demi-journées (~2 semaines)
- **3 devs en parallèle phase 1** : ~5 jours

## Décisions globales à arbitrer avant de partir

1. **Favori sur série** : toggle la série, pas les épisodes (confirmer)
2. **Persistance filtres Library** : par section vs global, reset au changement de view
3. **Auto-play next** : countdown 5s annulable vs immédiat
4. **CarPlay / Android Auto** : repoussé v1.1 ?
5. **Long-press depuis Home rails** : oui / non

## Risques transverses

1. **Lints `very_good_analysis`** : tous les bool en params via `({required bool value})`
2. **Invalidation cascade Riverpod** : items 1 et 2 mutent `userData` côté serveur → bien lister tous les `ref.invalidate(...)` post-mutation
3. **Mode offline** : actions favoris/watched passent par `SyncOperation` (existant). Filtres Library + Page Personne désactivés en offline
4. **SWR cache** : si sérialisation `BaseItemDto` change, bumper `*_v1` → `*_v2`
5. **PlayerBackend abstraction** : `setSubtitleDelay` doit avoir une no-op safe pour backends futurs
6. **media_kit volatile** : `Player.platform.setProperty` marqué "use with caution" → `try/catch` + lock sur version pubspec
