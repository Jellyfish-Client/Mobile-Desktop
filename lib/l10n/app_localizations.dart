import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Jellyfish'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'COMPTE'**
  String get settingsAccount;

  /// No description provided for @settingsMyProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get settingsMyProfile;

  /// No description provided for @settingsMyProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'affichage, mot de passe, photo'**
  String get settingsMyProfileSubtitle;

  /// No description provided for @settingsServer.
  ///
  /// In fr, this message translates to:
  /// **'Serveur'**
  String get settingsServer;

  /// No description provided for @settingsUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get settingsUser;

  /// No description provided for @settingsSwitchAccount.
  ///
  /// In fr, this message translates to:
  /// **'Changer de compte'**
  String get settingsSwitchAccount;

  /// No description provided for @settingsSwitchAccountSubtitleSingle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un compte ou un serveur'**
  String get settingsSwitchAccountSubtitleSingle;

  /// No description provided for @settingsSwitchAccountSubtitleMultiple.
  ///
  /// In fr, this message translates to:
  /// **'{count} comptes enregistrés'**
  String settingsSwitchAccountSubtitleMultiple(int count);

  /// No description provided for @settingsLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter de ce compte'**
  String get settingsLogout;

  /// No description provided for @settingsDownloads.
  ///
  /// In fr, this message translates to:
  /// **'TÉLÉCHARGEMENTS'**
  String get settingsDownloads;

  /// No description provided for @settingsDownloadsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargements'**
  String get settingsDownloadsTitle;

  /// No description provided for @settingsDownloadsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi only, arrière-plan, stockage'**
  String get settingsDownloadsSubtitle;

  /// No description provided for @settingsDiscovery.
  ///
  /// In fr, this message translates to:
  /// **'DÉCOUVERTE'**
  String get settingsDiscovery;

  /// No description provided for @settingsRequests.
  ///
  /// In fr, this message translates to:
  /// **'Mes demandes'**
  String get settingsRequests;

  /// No description provided for @settingsRequestsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivi des films et séries demandés via Jellyseerr.'**
  String get settingsRequestsSubtitle;

  /// No description provided for @settingsPlayback.
  ///
  /// In fr, this message translates to:
  /// **'LECTURE'**
  String get settingsPlayback;

  /// No description provided for @settingsPlaybackTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get settingsPlaybackTitle;

  /// No description provided for @settingsAdmin.
  ///
  /// In fr, this message translates to:
  /// **'ADMINISTRATION'**
  String get settingsAdmin;

  /// No description provided for @settingsAdminTitle.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get settingsAdminTitle;

  /// No description provided for @settingsAdminSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Serveur, utilisateurs, bibliothèques, tâches'**
  String get settingsAdminSubtitle;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À PROPOS'**
  String get settingsAbout;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAboutTitle;

  /// No description provided for @playbackLanguages.
  ///
  /// In fr, this message translates to:
  /// **'LANGUES'**
  String get playbackLanguages;

  /// No description provided for @playbackAudioLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue audio préférée'**
  String get playbackAudioLanguage;

  /// No description provided for @playbackSubtitleLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue des sous-titres préférée'**
  String get playbackSubtitleLanguage;

  /// No description provided for @playbackSubtitleMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sous-titres'**
  String get playbackSubtitleMode;

  /// No description provided for @playbackBehavior.
  ///
  /// In fr, this message translates to:
  /// **'COMPORTEMENT'**
  String get playbackBehavior;

  /// No description provided for @playbackAutoNextEpisode.
  ///
  /// In fr, this message translates to:
  /// **'Lecture auto de l\'épisode suivant'**
  String get playbackAutoNextEpisode;

  /// No description provided for @playbackDefaultAudioTrack.
  ///
  /// In fr, this message translates to:
  /// **'Lire la piste audio par défaut'**
  String get playbackDefaultAudioTrack;

  /// No description provided for @playbackDefaultAudioTrackDescription.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionne automatiquement la piste audio par défaut du fichier au lieu de votre langue préférée.'**
  String get playbackDefaultAudioTrackDescription;

  /// No description provided for @playbackRememberAudioSelections.
  ///
  /// In fr, this message translates to:
  /// **'Mémoriser les choix audio'**
  String get playbackRememberAudioSelections;

  /// No description provided for @playbackRememberSubtitleSelections.
  ///
  /// In fr, this message translates to:
  /// **'Mémoriser les choix de sous-titres'**
  String get playbackRememberSubtitleSelections;

  /// No description provided for @playbackShowMissingEpisodes.
  ///
  /// In fr, this message translates to:
  /// **'Afficher les épisodes manquants'**
  String get playbackShowMissingEpisodes;

  /// No description provided for @playbackAudioLanguageUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Langue audio mise à jour.'**
  String get playbackAudioLanguageUpdated;

  /// No description provided for @playbackSubtitleLanguageUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Langue des sous-titres mise à jour.'**
  String get playbackSubtitleLanguageUpdated;

  /// No description provided for @playbackSubtitleModeUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Mode sous-titres mis à jour.'**
  String get playbackSubtitleModeUpdated;

  /// No description provided for @playbackAutoPlayEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Lecture auto activée.'**
  String get playbackAutoPlayEnabled;

  /// No description provided for @playbackAutoPlayDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Lecture auto désactivée.'**
  String get playbackAutoPlayDisabled;

  /// No description provided for @playbackPreferenceSaved.
  ///
  /// In fr, this message translates to:
  /// **'Préférence enregistrée.'**
  String get playbackPreferenceSaved;

  /// No description provided for @playbackLanguageNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get playbackLanguageNone;

  /// No description provided for @playbackLanguageSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une langue'**
  String get playbackLanguageSearch;

  /// No description provided for @playbackSubtitleModeDefault.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get playbackSubtitleModeDefault;

  /// No description provided for @playbackSubtitleModeDefaultDescription.
  ///
  /// In fr, this message translates to:
  /// **'Suit le réglage du fichier'**
  String get playbackSubtitleModeDefaultDescription;

  /// No description provided for @playbackSubtitleModeAlways.
  ///
  /// In fr, this message translates to:
  /// **'Toujours'**
  String get playbackSubtitleModeAlways;

  /// No description provided for @playbackSubtitleModeAlwaysDescription.
  ///
  /// In fr, this message translates to:
  /// **'Afficher dès qu\'une piste correspond à la langue préférée'**
  String get playbackSubtitleModeAlwaysDescription;

  /// No description provided for @playbackSubtitleModeOnlyForced.
  ///
  /// In fr, this message translates to:
  /// **'Uniquement forcés'**
  String get playbackSubtitleModeOnlyForced;

  /// No description provided for @playbackSubtitleModeOnlyForcedDescription.
  ///
  /// In fr, this message translates to:
  /// **'Seulement les sous-titres forcés'**
  String get playbackSubtitleModeOnlyForcedDescription;

  /// No description provided for @playbackSubtitleModeSmart.
  ///
  /// In fr, this message translates to:
  /// **'Intelligent'**
  String get playbackSubtitleModeSmart;

  /// No description provided for @playbackSubtitleModeSmartDescription.
  ///
  /// In fr, this message translates to:
  /// **'Quand l\'audio n\'est pas dans votre langue préférée'**
  String get playbackSubtitleModeSmartDescription;

  /// No description provided for @playbackSubtitleModeNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucun'**
  String get playbackSubtitleModeNone;

  /// No description provided for @playbackSubtitleModeNoneDescription.
  ///
  /// In fr, this message translates to:
  /// **'Ne jamais afficher'**
  String get playbackSubtitleModeNoneDescription;

  /// No description provided for @downloadsSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargements'**
  String get downloadsSettingsTitle;

  /// No description provided for @downloadsOptions.
  ///
  /// In fr, this message translates to:
  /// **'OPTIONS'**
  String get downloadsOptions;

  /// No description provided for @downloadsBackgroundEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargements en arrière-plan'**
  String get downloadsBackgroundEnabled;

  /// No description provided for @downloadsBackgroundEnabledDescription.
  ///
  /// In fr, this message translates to:
  /// **'Continue les téléchargements quand l\'app est fermée.'**
  String get downloadsBackgroundEnabledDescription;

  /// No description provided for @downloadsWifiOnly.
  ///
  /// In fr, this message translates to:
  /// **'Wi-Fi uniquement'**
  String get downloadsWifiOnly;

  /// No description provided for @downloadsWifiOnlyDescription.
  ///
  /// In fr, this message translates to:
  /// **'Bloque les nouveaux téléchargements sur le réseau mobile.'**
  String get downloadsWifiOnlyDescription;

  /// No description provided for @downloadsAutoDeleteWatched.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer après visionnage'**
  String get downloadsAutoDeleteWatched;

  /// No description provided for @downloadsAutoDeleteWatchedDescription.
  ///
  /// In fr, this message translates to:
  /// **'Retire les épisodes téléchargés une fois la lecture terminée.'**
  String get downloadsAutoDeleteWatchedDescription;

  /// No description provided for @downloadsStorage.
  ///
  /// In fr, this message translates to:
  /// **'STOCKAGE'**
  String get downloadsStorage;

  /// No description provided for @downloadsStorageUsed.
  ///
  /// In fr, this message translates to:
  /// **'Espace utilisé'**
  String get downloadsStorageUsed;

  /// No description provided for @downloadsDeleteAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer'**
  String get downloadsDeleteAll;

  /// No description provided for @downloadsDeleteAllConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer tous les téléchargements ?'**
  String get downloadsDeleteAllConfirm;

  /// No description provided for @downloadsDeleteAllConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tous les fichiers téléchargés et leurs images locales seront supprimés. Cette action est irréversible.'**
  String get downloadsDeleteAllConfirmMessage;

  /// No description provided for @aboutAppName.
  ///
  /// In fr, this message translates to:
  /// **'Jellyfish'**
  String get aboutAppName;

  /// No description provided for @aboutAppSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Client Jellyfin + Seerr'**
  String get aboutAppSubtitle;

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutLicenses.
  ///
  /// In fr, this message translates to:
  /// **'Licences open-source'**
  String get aboutLicenses;

  /// No description provided for @profileDisplayName.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'affichage'**
  String get profileDisplayName;

  /// No description provided for @profileChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get profileChangePassword;

  /// No description provided for @profileChangePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Changer la photo'**
  String get profileChangePhoto;

  /// No description provided for @profileDeletePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get profileDeletePhoto;

  /// No description provided for @profileDisplayNameUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'affichage mis à jour.'**
  String get profileDisplayNameUpdated;

  /// No description provided for @profilePasswordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié.'**
  String get profilePasswordChanged;

  /// No description provided for @profilePasswordIncorrect.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel incorrect.'**
  String get profilePasswordIncorrect;

  /// No description provided for @profilePhotoUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil mise à jour.'**
  String get profilePhotoUpdated;

  /// No description provided for @profilePhotoDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Photo de profil supprimée.'**
  String get profilePhotoDeleted;

  /// No description provided for @homeNoMoreContent.
  ///
  /// In fr, this message translates to:
  /// **'Tu as tout vu'**
  String get homeNoMoreContent;

  /// No description provided for @homeSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get homeSearch;

  /// No description provided for @homeOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors ligne'**
  String get homeOffline;

  /// No description provided for @homeOfflineNoDownloads.
  ///
  /// In fr, this message translates to:
  /// **'Aucun téléchargement'**
  String get homeOfflineNoDownloads;

  /// No description provided for @homeOfflineNoDownloadsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes hors ligne et aucun élément n\'est disponible sur cet appareil.'**
  String get homeOfflineNoDownloadsMessage;

  /// No description provided for @homeOfflineBanner.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors ligne — votre bibliothèque locale'**
  String get homeOfflineBanner;

  /// No description provided for @homeOfflineSeriesDownloaded.
  ///
  /// In fr, this message translates to:
  /// **'Séries téléchargées'**
  String get homeOfflineSeriesDownloaded;

  /// No description provided for @homeOfflineMoviesDownloaded.
  ///
  /// In fr, this message translates to:
  /// **'Films téléchargés'**
  String get homeOfflineMoviesDownloaded;

  /// No description provided for @homeOfflineEpisodeCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 épisode} other{{count} épisodes}}'**
  String homeOfflineEpisodeCount(int count);

  /// No description provided for @homePluginMissing.
  ///
  /// In fr, this message translates to:
  /// **'Le plugin Jellyfish.Bridge n\'est pas installé sur ton serveur Jellyfin. Discover, Demandes et Calendrier resteront vides. Demande à ton admin de l\'installer.'**
  String get homePluginMissing;

  /// No description provided for @homeNoJellyseerrAccount.
  ///
  /// In fr, this message translates to:
  /// **'Ton compte Seerr n\'a pas été activé. Demande à ton admin d\'ouvrir Seerr → Settings → Users → Import Jellyfin Users.'**
  String get homeNoJellyseerrAccount;

  /// No description provided for @homeJellyseerrNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Jellyseerr n\'est pas configuré dans le plugin Jellyfish.Bridge.'**
  String get homeJellyseerrNotConfigured;

  /// No description provided for @homeRadarrNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Radarr n\'est pas configuré dans le plugin Jellyfish.Bridge.'**
  String get homeRadarrNotConfigured;

  /// No description provided for @homeSonarrNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Sonarr n\'est pas configuré dans le plugin Jellyfish.Bridge.'**
  String get homeSonarrNotConfigured;

  /// No description provided for @homeUpstreamUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Le service externe est injoignable. Réessaie dans quelques instants.'**
  String get homeUpstreamUnreachable;

  /// No description provided for @homeUpstreamTimeout.
  ///
  /// In fr, this message translates to:
  /// **'Le service externe n\'a pas répondu à temps.'**
  String get homeUpstreamTimeout;

  /// No description provided for @homePluginMissingError.
  ///
  /// In fr, this message translates to:
  /// **'Le plugin Jellyfish.Bridge n\'est pas installé sur ton serveur.'**
  String get homePluginMissingError;

  /// No description provided for @homeOtherError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue (HTTP {statusCode}).'**
  String homeOtherError(int statusCode);

  /// No description provided for @libraryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @librarySearch.
  ///
  /// In fr, this message translates to:
  /// **'Search library…'**
  String get librarySearch;

  /// No description provided for @libraryAll.
  ///
  /// In fr, this message translates to:
  /// **'All'**
  String get libraryAll;

  /// No description provided for @searchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un film, une série…'**
  String get searchTitle;

  /// No description provided for @searchClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get searchClear;

  /// No description provided for @searchIntroTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cherche un titre'**
  String get searchIntroTitle;

  /// No description provided for @searchIntroWithSeerr.
  ///
  /// In fr, this message translates to:
  /// **'La recherche couvre ta bibliothèque Jellyfin et te permet de demander de nouveaux titres via Seerr.'**
  String get searchIntroWithSeerr;

  /// No description provided for @searchIntroWithoutSeerr.
  ///
  /// In fr, this message translates to:
  /// **'La recherche couvre ta bibliothèque Jellyfin.'**
  String get searchIntroWithoutSeerr;

  /// No description provided for @searchIntroJellyfin.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque Jellyfin'**
  String get searchIntroJellyfin;

  /// No description provided for @searchIntroJellyfinDescription.
  ///
  /// In fr, this message translates to:
  /// **'Films et séries déjà disponibles chez toi.'**
  String get searchIntroJellyfinDescription;

  /// No description provided for @searchIntroSeerr.
  ///
  /// In fr, this message translates to:
  /// **'Demander via Seerr'**
  String get searchIntroSeerr;

  /// No description provided for @searchIntroSeerrDescription.
  ///
  /// In fr, this message translates to:
  /// **'Trouve un nouveau titre et envoie une demande à Seerr.'**
  String get searchIntroSeerrDescription;

  /// No description provided for @searchNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get searchNoResults;

  /// No description provided for @searchNoResultsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun titre ne correspond à « {query} ».'**
  String searchNoResultsMessage(String query);

  /// No description provided for @searchJellyfinSection.
  ///
  /// In fr, this message translates to:
  /// **'01 ── BIBLIOTHÈQUE'**
  String get searchJellyfinSection;

  /// No description provided for @searchJellyfinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Dans ta bibliothèque'**
  String get searchJellyfinTitle;

  /// No description provided for @searchJellyfinLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger Jellyfin'**
  String get searchJellyfinLoadError;

  /// No description provided for @searchJellyfinEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien ne correspond ici.'**
  String get searchJellyfinEmpty;

  /// No description provided for @searchSeerrSection.
  ///
  /// In fr, this message translates to:
  /// **'02 ── SEERR'**
  String get searchSeerrSection;

  /// No description provided for @searchSeerrTitle.
  ///
  /// In fr, this message translates to:
  /// **'Demander via Seerr'**
  String get searchSeerrTitle;

  /// No description provided for @searchSeerrLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre Seerr'**
  String get searchSeerrLoadError;

  /// No description provided for @searchSeerrEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien à demander pour cette requête.'**
  String get searchSeerrEmpty;

  /// No description provided for @searchSeerrCollection.
  ///
  /// In fr, this message translates to:
  /// **'COLLECTION'**
  String get searchSeerrCollection;

  /// No description provided for @offlineSearchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher (hors ligne)'**
  String get offlineSearchTitle;

  /// No description provided for @offlineSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer les téléchargements…'**
  String get offlineSearchHint;

  /// No description provided for @offlineSearchNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get offlineSearchNoResults;

  /// No description provided for @offlineSearchNoDownloads.
  ///
  /// In fr, this message translates to:
  /// **'Aucun téléchargement'**
  String get offlineSearchNoDownloads;

  /// No description provided for @offlineSearchNoDownloadsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargez des films ou séries pour les retrouver hors ligne.'**
  String get offlineSearchNoDownloadsMessage;

  /// No description provided for @offlineSearchNoResultsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun téléchargement ne correspond à « {query} ».'**
  String offlineSearchNoResultsMessage(String query);

  /// No description provided for @downloadsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// No description provided for @downloadsSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de téléchargement'**
  String get downloadsSettings;

  /// No description provided for @downloadsNoDownloads.
  ///
  /// In fr, this message translates to:
  /// **'No downloads'**
  String get downloadsNoDownloads;

  /// No description provided for @downloadsNoDownloadsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Items you download for offline playback will appear here.'**
  String get downloadsNoDownloadsMessage;

  /// No description provided for @downloadsInProgress.
  ///
  /// In fr, this message translates to:
  /// **'In progress'**
  String get downloadsInProgress;

  /// No description provided for @downloadsDownloaded.
  ///
  /// In fr, this message translates to:
  /// **'Downloaded'**
  String get downloadsDownloaded;

  /// No description provided for @downloadsFailedOrCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Failed / cancelled'**
  String get downloadsFailedOrCancelled;

  /// No description provided for @downloadsSeriesName.
  ///
  /// In fr, this message translates to:
  /// **'Series'**
  String get downloadsSeriesName;

  /// No description provided for @onboardingConnect.
  ///
  /// In fr, this message translates to:
  /// **'Connect to your Jellyfin server'**
  String get onboardingConnect;

  /// No description provided for @onboardingServerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Server URL'**
  String get onboardingServerLabel;

  /// No description provided for @onboardingServerHint.
  ///
  /// In fr, this message translates to:
  /// **'https://jellyfin.example.com'**
  String get onboardingServerHint;

  /// No description provided for @onboardingServerRequired.
  ///
  /// In fr, this message translates to:
  /// **'Required'**
  String get onboardingServerRequired;

  /// No description provided for @onboardingServerTip.
  ///
  /// In fr, this message translates to:
  /// **'Tip: https://server.example.com or LAN https://192.168.x.x:8096'**
  String get onboardingServerTip;

  /// No description provided for @onboardingContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingCancel.
  ///
  /// In fr, this message translates to:
  /// **'Cancel'**
  String get onboardingCancel;

  /// No description provided for @onboardingWelcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Welcome back'**
  String get onboardingWelcomeBack;

  /// No description provided for @onboardingSignInSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sign in to your Jellyfin account'**
  String get onboardingSignInSubtitle;

  /// No description provided for @onboardingSessionExpired.
  ///
  /// In fr, this message translates to:
  /// **'Session expired'**
  String get onboardingSessionExpired;

  /// No description provided for @onboardingSessionExpiredSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sign in again to keep using this account'**
  String get onboardingSessionExpiredSubtitle;

  /// No description provided for @onboardingChange.
  ///
  /// In fr, this message translates to:
  /// **'Change'**
  String get onboardingChange;

  /// No description provided for @onboardingUsername.
  ///
  /// In fr, this message translates to:
  /// **'Username'**
  String get onboardingUsername;

  /// No description provided for @onboardingUsernameHint.
  ///
  /// In fr, this message translates to:
  /// **'Your Jellyfin username'**
  String get onboardingUsernameHint;

  /// No description provided for @onboardingPassword.
  ///
  /// In fr, this message translates to:
  /// **'Password'**
  String get onboardingPassword;

  /// No description provided for @onboardingSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Sign in'**
  String get onboardingSignIn;

  /// No description provided for @onboardingQuickConnect.
  ///
  /// In fr, this message translates to:
  /// **'Use a Quick Connect code'**
  String get onboardingQuickConnect;

  /// No description provided for @onboardingChangeServer.
  ///
  /// In fr, this message translates to:
  /// **'Change server'**
  String get onboardingChangeServer;

  /// No description provided for @onboardingErrorWrongCredentials.
  ///
  /// In fr, this message translates to:
  /// **'Wrong username or password'**
  String get onboardingErrorWrongCredentials;

  /// No description provided for @onboardingErrorWrongCredentialsHint.
  ///
  /// In fr, this message translates to:
  /// **'Double-check your credentials and try again.'**
  String get onboardingErrorWrongCredentialsHint;

  /// No description provided for @onboardingErrorReverseProxy.
  ///
  /// In fr, this message translates to:
  /// **'Reverse proxy rejected your credentials'**
  String get onboardingErrorReverseProxy;

  /// No description provided for @onboardingErrorReverseProxyHint.
  ///
  /// In fr, this message translates to:
  /// **'Include proxy credentials in the URL:\nhttps://user:pass@host'**
  String get onboardingErrorReverseProxyHint;

  /// No description provided for @onboardingErrorAuthRequired.
  ///
  /// In fr, this message translates to:
  /// **'Authentication required'**
  String get onboardingErrorAuthRequired;

  /// No description provided for @onboardingErrorServerNotResponding.
  ///
  /// In fr, this message translates to:
  /// **'Server did not respond'**
  String get onboardingErrorServerNotResponding;

  /// No description provided for @onboardingErrorServerNotRespondingHint.
  ///
  /// In fr, this message translates to:
  /// **'Check that the server is running and reachable.'**
  String get onboardingErrorServerNotRespondingHint;

  /// No description provided for @onboardingErrorServerUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Could not reach the server'**
  String get onboardingErrorServerUnreachable;

  /// No description provided for @onboardingErrorServerUnreachableHint.
  ///
  /// In fr, this message translates to:
  /// **'Check the URL and your network connection.'**
  String get onboardingErrorServerUnreachableHint;

  /// No description provided for @onboardingErrorServerUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Server unavailable'**
  String get onboardingErrorServerUnavailable;

  /// No description provided for @onboardingErrorServerUnavailableHint.
  ///
  /// In fr, this message translates to:
  /// **'The server returned a gateway error. Try again shortly.'**
  String get onboardingErrorServerUnavailableHint;

  /// No description provided for @onboardingErrorServerError.
  ///
  /// In fr, this message translates to:
  /// **'Server returned an error'**
  String get onboardingErrorServerError;

  /// No description provided for @onboardingErrorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Something went wrong'**
  String get onboardingErrorGeneric;

  /// No description provided for @quickConnectTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quick Connect'**
  String get quickConnectTitle;

  /// No description provided for @quickConnectEnterCode.
  ///
  /// In fr, this message translates to:
  /// **'Enter this code'**
  String get quickConnectEnterCode;

  /// No description provided for @quickConnectApproved.
  ///
  /// In fr, this message translates to:
  /// **'Approved'**
  String get quickConnectApproved;

  /// No description provided for @quickConnectDone.
  ///
  /// In fr, this message translates to:
  /// **'Signed in'**
  String get quickConnectDone;

  /// No description provided for @quickConnectFailed.
  ///
  /// In fr, this message translates to:
  /// **'Quick Connect failed'**
  String get quickConnectFailed;

  /// No description provided for @quickConnectExpired.
  ///
  /// In fr, this message translates to:
  /// **'Quick Connect expired'**
  String get quickConnectExpired;

  /// No description provided for @quickConnectGenerating.
  ///
  /// In fr, this message translates to:
  /// **'Generating…'**
  String get quickConnectGenerating;

  /// No description provided for @quickConnectSigningIn.
  ///
  /// In fr, this message translates to:
  /// **'Signing in…'**
  String get quickConnectSigningIn;

  /// No description provided for @quickConnectInstruction.
  ///
  /// In fr, this message translates to:
  /// **'On any device already signed in to {server}, open the user menu → Quick Connect, then enter the code above.'**
  String quickConnectInstruction(String server);

  /// No description provided for @quickConnectWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Waiting for approval…'**
  String get quickConnectWaiting;

  /// No description provided for @quickConnectCodeCopied.
  ///
  /// In fr, this message translates to:
  /// **'Code copied'**
  String get quickConnectCodeCopied;

  /// No description provided for @quickConnectCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copy'**
  String get quickConnectCopy;

  /// No description provided for @quickConnectExpiredMessage.
  ///
  /// In fr, this message translates to:
  /// **'The code expired before it was approved. Generate a new one to try again.'**
  String get quickConnectExpiredMessage;

  /// No description provided for @quickConnectClose.
  ///
  /// In fr, this message translates to:
  /// **'Close'**
  String get quickConnectClose;

  /// No description provided for @accountsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comptes'**
  String get accountsTitle;

  /// No description provided for @accountsMyServer.
  ///
  /// In fr, this message translates to:
  /// **'MON SERVEUR'**
  String get accountsMyServer;

  /// No description provided for @accountsMyServers.
  ///
  /// In fr, this message translates to:
  /// **'MES SERVEURS · {count}'**
  String accountsMyServers(int count);

  /// No description provided for @accountsAddUser.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un utilisateur sur ce serveur'**
  String get accountsAddUser;

  /// No description provided for @accountsOtherServer.
  ///
  /// In fr, this message translates to:
  /// **'AUTRE SERVEUR'**
  String get accountsOtherServer;

  /// No description provided for @accountsAddServer.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un serveur Jellyfin'**
  String get accountsAddServer;

  /// No description provided for @accountsHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur un compte pour basculer. Appui long pour supprimer.'**
  String get accountsHint;

  /// No description provided for @accountsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte enregistré'**
  String get accountsEmpty;

  /// No description provided for @accountsEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez un serveur Jellyfin pour commencer.'**
  String get accountsEmptyMessage;

  /// No description provided for @accountsForgetServer.
  ///
  /// In fr, this message translates to:
  /// **'Oublier ce serveur'**
  String get accountsForgetServer;

  /// No description provided for @accountsRemove.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get accountsRemove;

  /// No description provided for @accountsActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get accountsActive;

  /// No description provided for @accountsForgetServerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Oublier {serverName} ?'**
  String accountsForgetServerTitle(String serverName);

  /// No description provided for @accountsForgetServerMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les {count} compte(s) associé(s) seront retirés de cet appareil.'**
  String accountsForgetServerMessage(int count);

  /// No description provided for @accountsForget.
  ///
  /// In fr, this message translates to:
  /// **'Oublier'**
  String get accountsForget;

  /// No description provided for @accountsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce compte ?'**
  String get accountsDeleteTitle;

  /// No description provided for @accountsDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'{userName} sur {serverName} sera retiré de cet appareil.'**
  String accountsDeleteMessage(String userName, String serverName);

  /// No description provided for @accountsDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get accountsDelete;

  /// No description provided for @calendarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get calendarTitle;

  /// No description provided for @calendarAllTypes.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get calendarAllTypes;

  /// No description provided for @calendarMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films'**
  String get calendarMovies;

  /// No description provided for @calendarEpisodes.
  ///
  /// In fr, this message translates to:
  /// **'Épisodes'**
  String get calendarEpisodes;

  /// No description provided for @calendar30Days.
  ///
  /// In fr, this message translates to:
  /// **'30 jours'**
  String get calendar30Days;

  /// No description provided for @calendar90Days.
  ///
  /// In fr, this message translates to:
  /// **'3 mois'**
  String get calendar90Days;

  /// No description provided for @calendar365Days.
  ///
  /// In fr, this message translates to:
  /// **'1 an'**
  String get calendar365Days;

  /// No description provided for @calendarMissing.
  ///
  /// In fr, this message translates to:
  /// **'Manquants'**
  String get calendarMissing;

  /// No description provided for @calendarNoData.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur.'**
  String get calendarNoData;

  /// No description provided for @calendarNoPlugin.
  ///
  /// In fr, this message translates to:
  /// **'Le plugin Jellyfish.Bridge n\'est pas installé sur ton serveur Jellyfin. Demande à ton admin de l\'installer.'**
  String get calendarNoPlugin;

  /// No description provided for @calendarNoServices.
  ///
  /// In fr, this message translates to:
  /// **'Ni Radarr ni Sonarr ne sont configurés sur le plugin. Demande à ton admin de connecter au moins l\'un des deux.'**
  String get calendarNoServices;

  /// No description provided for @calendarLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger le calendrier.'**
  String get calendarLoadError;

  /// No description provided for @calendarNoItems.
  ///
  /// In fr, this message translates to:
  /// **'Rien à l\'horizon sur la période sélectionnée.'**
  String get calendarNoItems;

  /// No description provided for @requestsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Requests'**
  String get requestsTitle;

  /// No description provided for @requestsSort.
  ///
  /// In fr, this message translates to:
  /// **'Sort requests'**
  String get requestsSort;

  /// No description provided for @requestsSortRecent.
  ///
  /// In fr, this message translates to:
  /// **'Most recent'**
  String get requestsSortRecent;

  /// No description provided for @requestsSortOldest.
  ///
  /// In fr, this message translates to:
  /// **'Oldest'**
  String get requestsSortOldest;

  /// No description provided for @requestsSortStatus.
  ///
  /// In fr, this message translates to:
  /// **'Status'**
  String get requestsSortStatus;

  /// No description provided for @requestsSortTitle.
  ///
  /// In fr, this message translates to:
  /// **'Title (A–Z)'**
  String get requestsSortTitle;

  /// No description provided for @requestsAll.
  ///
  /// In fr, this message translates to:
  /// **'All'**
  String get requestsAll;

  /// No description provided for @requestsPending.
  ///
  /// In fr, this message translates to:
  /// **'Pending'**
  String get requestsPending;

  /// No description provided for @requestsProcessing.
  ///
  /// In fr, this message translates to:
  /// **'Processing'**
  String get requestsProcessing;

  /// No description provided for @requestsAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Available'**
  String get requestsAvailable;

  /// No description provided for @requestsOfflineUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible hors ligne'**
  String get requestsOfflineUnavailable;

  /// No description provided for @requestsOfflineUnavailableMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les requêtes Seerr nécessitent une connexion réseau active.'**
  String get requestsOfflineUnavailableMessage;

  /// No description provided for @requestsNoRequests.
  ///
  /// In fr, this message translates to:
  /// **'No requests yet'**
  String get requestsNoRequests;

  /// No description provided for @requestsNoRequestsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Browse and tap Request on something you\'d like to add.'**
  String get requestsNoRequestsMessage;

  /// No description provided for @requestsNoMatching.
  ///
  /// In fr, this message translates to:
  /// **'No matching requests'**
  String get requestsNoMatching;

  /// No description provided for @requestsNoMatchingMessage.
  ///
  /// In fr, this message translates to:
  /// **'No results for \"{filterLabel}\".'**
  String requestsNoMatchingMessage(String filterLabel);

  /// No description provided for @requestsStatusAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Available'**
  String get requestsStatusAvailable;

  /// No description provided for @requestsStatusDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Downloading'**
  String get requestsStatusDownloading;

  /// No description provided for @requestsStatusPartial.
  ///
  /// In fr, this message translates to:
  /// **'Partial'**
  String get requestsStatusPartial;

  /// No description provided for @requestsStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'Pending'**
  String get requestsStatusPending;

  /// No description provided for @requestsStatusUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Unknown'**
  String get requestsStatusUnknown;

  /// No description provided for @requestsTypeMovie.
  ///
  /// In fr, this message translates to:
  /// **'Movie'**
  String get requestsTypeMovie;

  /// No description provided for @requestsTypeShow.
  ///
  /// In fr, this message translates to:
  /// **'Show'**
  String get requestsTypeShow;

  /// No description provided for @requestsJustNow.
  ///
  /// In fr, this message translates to:
  /// **'Just now'**
  String get requestsJustNow;

  /// No description provided for @requestsMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String requestsMinutesAgo(int count);

  /// No description provided for @requestsHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String requestsHoursAgo(int count);

  /// No description provided for @requestsYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Yesterday'**
  String get requestsYesterday;

  /// No description provided for @requestsDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count} days ago'**
  String requestsDaysAgo(int count);

  /// No description provided for @requestsLastWeek.
  ///
  /// In fr, this message translates to:
  /// **'Last week'**
  String get requestsLastWeek;

  /// No description provided for @requestsWeeksAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count} weeks ago'**
  String requestsWeeksAgo(int count);

  /// No description provided for @requestsMonthsAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String requestsMonthsAgo(int count);

  /// No description provided for @requestsYearsAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String requestsYearsAgo(int count);

  /// No description provided for @adminTitle.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get adminTitle;

  /// No description provided for @adminServer.
  ///
  /// In fr, this message translates to:
  /// **'SERVEUR'**
  String get adminServer;

  /// No description provided for @adminDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord'**
  String get adminDashboard;

  /// No description provided for @adminDashboardSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Version, OS, redémarrer / arrêter'**
  String get adminDashboardSubtitle;

  /// No description provided for @adminContent.
  ///
  /// In fr, this message translates to:
  /// **'CONTENU'**
  String get adminContent;

  /// No description provided for @adminLibraries.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèques'**
  String get adminLibraries;

  /// No description provided for @adminLibrariesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Lister et lancer un scan'**
  String get adminLibrariesSubtitle;

  /// No description provided for @adminTasks.
  ///
  /// In fr, this message translates to:
  /// **'Tâches planifiées'**
  String get adminTasks;

  /// No description provided for @adminTasksSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Voir et déclencher les tâches du serveur'**
  String get adminTasksSubtitle;

  /// No description provided for @adminAccounts.
  ///
  /// In fr, this message translates to:
  /// **'COMPTES'**
  String get adminAccounts;

  /// No description provided for @adminUsers.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get adminUsers;

  /// No description provided for @adminUsersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer, éditer, supprimer'**
  String get adminUsersSubtitle;

  /// No description provided for @playerChapters.
  ///
  /// In fr, this message translates to:
  /// **'Chapitres'**
  String get playerChapters;

  /// No description provided for @playerSubtitlesAudio.
  ///
  /// In fr, this message translates to:
  /// **'Sous-titres et audio'**
  String get playerSubtitlesAudio;

  /// No description provided for @playerSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse'**
  String get playerSpeed;

  /// No description provided for @playerNextUp.
  ///
  /// In fr, this message translates to:
  /// **'Épisode suivant'**
  String get playerNextUp;

  /// No description provided for @playerLocked.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillé'**
  String get playerLocked;

  /// No description provided for @playerUnlocked.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouillé'**
  String get playerUnlocked;

  /// No description provided for @playerAudioTrack.
  ///
  /// In fr, this message translates to:
  /// **'Piste audio'**
  String get playerAudioTrack;

  /// No description provided for @playerSubtitles.
  ///
  /// In fr, this message translates to:
  /// **'Sous-titres'**
  String get playerSubtitles;

  /// No description provided for @playerSubtitlesOff.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get playerSubtitlesOff;

  /// No description provided for @playerSpeedNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get playerSpeedNormal;

  /// No description provided for @playerError.
  ///
  /// In fr, this message translates to:
  /// **'Playback error: {error}'**
  String playerError(String error);

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {message}'**
  String errorGeneric(String message);

  /// No description provided for @errorFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec : {message}'**
  String errorFailed(String message);

  /// No description provided for @selectionCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Sélection annulée : {message}'**
  String selectionCancelled(String message);

  /// No description provided for @successSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get successSaved;

  /// No description provided for @cancelButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancelButton;

  /// No description provided for @deleteButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteButton;

  /// No description provided for @deleteAllButton.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer'**
  String get deleteAllButton;

  /// No description provided for @retryButton.
  ///
  /// In fr, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @profileDisplayNameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'affichage'**
  String get profileDisplayNameTitle;

  /// No description provided for @profileChangePasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get profileChangePasswordTitle;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get profileCurrentPassword;

  /// No description provided for @profileNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get profileNewPassword;

  /// No description provided for @profileConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le nouveau mot de passe'**
  String get profileConfirmPassword;

  /// No description provided for @profilePasswordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get profilePasswordsDoNotMatch;

  /// No description provided for @profileRequired.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get profileRequired;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In fr, this message translates to:
  /// **'LANGUE'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get settingsLanguageFrench;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'Anglais'**
  String get settingsLanguageEnglish;

  /// No description provided for @seerrAvailabilityAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Disponible'**
  String get seerrAvailabilityAvailable;

  /// No description provided for @seerrAvailabilityPartial.
  ///
  /// In fr, this message translates to:
  /// **'Partiel'**
  String get seerrAvailabilityPartial;

  /// No description provided for @seerrAvailabilityProcessing.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get seerrAvailabilityProcessing;

  /// No description provided for @seerrAvailabilityPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get seerrAvailabilityPending;

  /// No description provided for @seerrAvailabilityUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Non disponible'**
  String get seerrAvailabilityUnavailable;

  /// No description provided for @upcomingViewAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get upcomingViewAll;

  /// No description provided for @libraryFailedToLoad.
  ///
  /// In fr, this message translates to:
  /// **'Échec du chargement'**
  String get libraryFailedToLoad;

  /// No description provided for @libraryNoResults.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get libraryNoResults;

  /// No description provided for @libraryNoResultsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre terme ou filtre.'**
  String get libraryNoResultsMessage;

  /// No description provided for @detailsFailedToLoad.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger'**
  String get detailsFailedToLoad;

  /// No description provided for @detailsItemInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Cet élément est invalide.'**
  String get detailsItemInvalid;

  /// No description provided for @detailsRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get detailsRetry;

  /// No description provided for @detailsUnsupportedItem.
  ///
  /// In fr, this message translates to:
  /// **'Type non supporté'**
  String get detailsUnsupportedItem;

  /// No description provided for @detailsUnsupportedItemMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ce type d\'élément n\'est pas encore pris en charge.'**
  String get detailsUnsupportedItemMessage;

  /// No description provided for @detailsPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get detailsPlay;

  /// No description provided for @detailsResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get detailsResume;

  /// No description provided for @detailsNoEpisodes.
  ///
  /// In fr, this message translates to:
  /// **'Aucun épisode disponible'**
  String get detailsNoEpisodes;

  /// No description provided for @detailsResumeFrom.
  ///
  /// In fr, this message translates to:
  /// **'depuis {time}'**
  String detailsResumeFrom(String time);

  /// No description provided for @detailsEpisodes.
  ///
  /// In fr, this message translates to:
  /// **'Épisodes'**
  String get detailsEpisodes;

  /// No description provided for @detailsDownloadSeason.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger la saison'**
  String get detailsDownloadSeason;

  /// No description provided for @detailsSeason.
  ///
  /// In fr, this message translates to:
  /// **'Saison {number}'**
  String detailsSeason(int number);

  /// No description provided for @detailsNoEpisodesInSeason.
  ///
  /// In fr, this message translates to:
  /// **'Aucun épisode dans cette saison.'**
  String get detailsNoEpisodesInSeason;

  /// No description provided for @detailsWatched.
  ///
  /// In fr, this message translates to:
  /// **'Vu'**
  String get detailsWatched;

  /// No description provided for @detailsPreviousEpisode.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get detailsPreviousEpisode;

  /// No description provided for @detailsNextEpisode.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get detailsNextEpisode;

  /// No description provided for @detailsMissingSeasons.
  ///
  /// In fr, this message translates to:
  /// **'Saisons manquantes'**
  String get detailsMissingSeasons;

  /// No description provided for @detailsMissingSeason.
  ///
  /// In fr, this message translates to:
  /// **'Saison {number}'**
  String detailsMissingSeason(int number);

  /// No description provided for @detailsBoxSetFailedToLoad.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les éléments'**
  String get detailsBoxSetFailedToLoad;

  /// No description provided for @detailsBoxSetEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Collection vide'**
  String get detailsBoxSetEmpty;

  /// No description provided for @detailsBoxSetEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette collection ne contient pas encore d\'éléments.'**
  String get detailsBoxSetEmptyMessage;

  /// No description provided for @castSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Distribution'**
  String get castSectionTitle;

  /// No description provided for @seerrDiscoverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Découvrir sur Seerr'**
  String get seerrDiscoverTitle;

  /// No description provided for @seerrDiscoverSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour demander — ajouté à votre bibliothèque Jellyfin une fois approuvé'**
  String get seerrDiscoverSubtitle;

  /// No description provided for @seerrRequestSent.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée : {title}'**
  String seerrRequestSent(String title);

  /// No description provided for @seerrRequestError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'envoyer la demande. {error}'**
  String seerrRequestError(String error);

  /// No description provided for @seerrRequestSentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Demande envoyée'**
  String get seerrRequestSentLabel;

  /// No description provided for @seerrAlreadyAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Déjà disponible'**
  String get seerrAlreadyAvailable;

  /// No description provided for @seerrAlreadyRequested.
  ///
  /// In fr, this message translates to:
  /// **'Déjà demandé'**
  String get seerrAlreadyRequested;

  /// No description provided for @seerrRequestSeasons.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Demander 1 saison} other{Demander {count} saisons}}'**
  String seerrRequestSeasons(int count);

  /// No description provided for @seerrRequest.
  ///
  /// In fr, this message translates to:
  /// **'Demander'**
  String get seerrRequest;

  /// No description provided for @seerrTypeMovie.
  ///
  /// In fr, this message translates to:
  /// **'Film'**
  String get seerrTypeMovie;

  /// No description provided for @seerrTypeSeries.
  ///
  /// In fr, this message translates to:
  /// **'Série'**
  String get seerrTypeSeries;

  /// No description provided for @seerrSeasonsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisons'**
  String get seerrSeasonsTitle;

  /// No description provided for @seerrSelectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélectionner'**
  String get seerrSelectAll;

  /// No description provided for @seerrDeselectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout désélectionner'**
  String get seerrDeselectAll;

  /// No description provided for @seerrBonus.
  ///
  /// In fr, this message translates to:
  /// **'Bonus'**
  String get seerrBonus;

  /// No description provided for @seerrSeasonNumber.
  ///
  /// In fr, this message translates to:
  /// **'Saison {number}'**
  String seerrSeasonNumber(int number);

  /// No description provided for @seerrCollectionMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films de la collection'**
  String get seerrCollectionMovies;

  /// No description provided for @seerrCollectionSelectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout sélect.'**
  String get seerrCollectionSelectAll;

  /// No description provided for @seerrCollectionDeselectAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout déselect.'**
  String get seerrCollectionDeselectAll;

  /// No description provided for @seerrCollectionSelectAtLeastOne.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionne au moins un film'**
  String get seerrCollectionSelectAtLeastOne;

  /// No description provided for @seerrCollectionRequested.
  ///
  /// In fr, this message translates to:
  /// **'Demandé'**
  String get seerrCollectionRequested;

  /// No description provided for @seerrCollectionRequestMovies.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Demander 1 film} other{Demander {count} films}}'**
  String seerrCollectionRequestMovies(int count);

  /// No description provided for @seerrCollectionChip.
  ///
  /// In fr, this message translates to:
  /// **'Collection'**
  String get seerrCollectionChip;

  /// No description provided for @seerrPendingLabel.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get seerrPendingLabel;

  /// No description provided for @seerrProcessingLabel.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get seerrProcessingLabel;

  /// No description provided for @seerrPartialLabel.
  ///
  /// In fr, this message translates to:
  /// **'Partiel'**
  String get seerrPartialLabel;

  /// No description provided for @offlineUnavailableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Indisponible hors ligne'**
  String get offlineUnavailableTitle;

  /// No description provided for @offlineUnavailableMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cet élément n\'a pas été téléchargé. Reconnectez-vous pour y accéder.'**
  String get offlineUnavailableMessage;

  /// No description provided for @offlinePlay.
  ///
  /// In fr, this message translates to:
  /// **'Lire'**
  String get offlinePlay;

  /// No description provided for @offlineMarkPlayed.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme vu'**
  String get offlineMarkPlayed;

  /// No description provided for @offlineAddFavorite.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get offlineAddFavorite;

  /// No description provided for @offlineDeleteDownload.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le téléchargement'**
  String get offlineDeleteDownload;

  /// No description provided for @offlineSynopsis.
  ///
  /// In fr, this message translates to:
  /// **'Synopsis'**
  String get offlineSynopsis;

  /// No description provided for @offlineMarkPlayedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Marqué comme vu — synchronisation à la reconnexion'**
  String get offlineMarkPlayedSnack;

  /// No description provided for @offlineAddFavoriteSnack.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté aux favoris — synchronisation à la reconnexion'**
  String get offlineAddFavoriteSnack;

  /// No description provided for @offlineDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le téléchargement ?'**
  String get offlineDeleteTitle;

  /// No description provided for @offlineDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier et ses images locales seront supprimés.'**
  String get offlineDeleteMessage;

  /// No description provided for @offlineDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get offlineDeleteConfirm;

  /// No description provided for @offlineSeriesNoEpisodesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun épisode'**
  String get offlineSeriesNoEpisodesTitle;

  /// No description provided for @offlineSeriesNoEpisodesMessage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun épisode de cette série n\'est téléchargé.'**
  String get offlineSeriesNoEpisodesMessage;

  /// No description provided for @offlineSeasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Saison {number}'**
  String offlineSeasonLabel(int number);

  /// No description provided for @offlineSeasonUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Saison ?'**
  String get offlineSeasonUnknown;

  /// No description provided for @downloadButtonDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get downloadButtonDownload;

  /// No description provided for @downloadButtonQueued.
  ///
  /// In fr, this message translates to:
  /// **'En attente — appuyer pour annuler'**
  String get downloadButtonQueued;

  /// No description provided for @downloadButtonDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement {percent}% — appuyer pour pause'**
  String downloadButtonDownloading(String percent);

  /// No description provided for @downloadButtonPaused.
  ///
  /// In fr, this message translates to:
  /// **'Pause {percent}% — appuyer pour reprendre'**
  String downloadButtonPaused(String percent);

  /// No description provided for @downloadButtonDownloaded.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargé — appui long pour supprimer'**
  String get downloadButtonDownloaded;

  /// No description provided for @downloadButtonFailedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Échec du téléchargement : {error}'**
  String downloadButtonFailedSnack(String error);

  /// No description provided for @downloadButtonDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le téléchargement ?'**
  String get downloadButtonDeleteTitle;

  /// No description provided for @downloadButtonDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le fichier local sera supprimé. Vous pouvez le retélécharger ultérieurement.'**
  String get downloadButtonDeleteMessage;

  /// No description provided for @downloadButtonDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get downloadButtonDeleteConfirm;

  /// No description provided for @downloadButtonDeleteCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get downloadButtonDeleteCancel;

  /// No description provided for @downloadButtonDeleteFailedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la suppression : {error}'**
  String downloadButtonDeleteFailedSnack(String error);

  /// No description provided for @downloadTileQueued.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get downloadTileQueued;

  /// No description provided for @downloadTileDownloaded.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargé'**
  String get downloadTileDownloaded;

  /// No description provided for @downloadTileFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get downloadTileFailed;

  /// No description provided for @downloadTileCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulé'**
  String get downloadTileCancelled;

  /// No description provided for @downloadTilePaused.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get downloadTilePaused;

  /// No description provided for @downloadTileTooltipDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get downloadTileTooltipDelete;

  /// No description provided for @downloadTileTooltipResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get downloadTileTooltipResume;

  /// No description provided for @downloadTileTooltipCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get downloadTileTooltipCancel;

  /// No description provided for @downloadTileTooltipPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get downloadTileTooltipPause;

  /// No description provided for @downloadTileTooltipRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get downloadTileTooltipRemove;

  /// No description provided for @playerResumeFrom.
  ///
  /// In fr, this message translates to:
  /// **'Reprise depuis {time}'**
  String playerResumeFrom(String time);

  /// No description provided for @playerNoChapters.
  ///
  /// In fr, this message translates to:
  /// **'Aucun chapitre disponible'**
  String get playerNoChapters;

  /// No description provided for @playerChapterNumber.
  ///
  /// In fr, this message translates to:
  /// **'Chapitre {number}'**
  String playerChapterNumber(int number);

  /// No description provided for @playerLockControls.
  ///
  /// In fr, this message translates to:
  /// **'Verrouiller les commandes'**
  String get playerLockControls;

  /// No description provided for @playerPictureInPicture.
  ///
  /// In fr, this message translates to:
  /// **'Picture-in-Picture'**
  String get playerPictureInPicture;

  /// No description provided for @playerDismiss.
  ///
  /// In fr, this message translates to:
  /// **'Ignorer'**
  String get playerDismiss;

  /// No description provided for @playerPlayNow.
  ///
  /// In fr, this message translates to:
  /// **'Lire maintenant'**
  String get playerPlayNow;

  /// No description provided for @adminServerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du serveur'**
  String get adminServerName;

  /// No description provided for @adminVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version'**
  String get adminVersion;

  /// No description provided for @adminProduct.
  ///
  /// In fr, this message translates to:
  /// **'Produit'**
  String get adminProduct;

  /// No description provided for @adminServerId.
  ///
  /// In fr, this message translates to:
  /// **'ID serveur'**
  String get adminServerId;

  /// No description provided for @adminLocalAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse locale'**
  String get adminLocalAddress;

  /// No description provided for @adminRestartPending.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrage en attente'**
  String get adminRestartPending;

  /// No description provided for @adminRestartPendingMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur a une mise à jour ou un changement de configuration nécessitant un redémarrage.'**
  String get adminRestartPendingMessage;

  /// No description provided for @adminShuttingDown.
  ///
  /// In fr, this message translates to:
  /// **'Arrêt en cours'**
  String get adminShuttingDown;

  /// No description provided for @adminInfoSection.
  ///
  /// In fr, this message translates to:
  /// **'INFORMATIONS'**
  String get adminInfoSection;

  /// No description provided for @adminRestartButton.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrer le serveur'**
  String get adminRestartButton;

  /// No description provided for @adminShutdownButton.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter le serveur'**
  String get adminShutdownButton;

  /// No description provided for @adminRestartConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrer le serveur ?'**
  String get adminRestartConfirmTitle;

  /// No description provided for @adminRestartConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les lectures en cours seront interrompues. Le serveur sera indisponible pendant quelques secondes.'**
  String get adminRestartConfirmMessage;

  /// No description provided for @adminRestartConfirmLabel.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrer'**
  String get adminRestartConfirmLabel;

  /// No description provided for @adminRestartSnack.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrage demandé.'**
  String get adminRestartSnack;

  /// No description provided for @adminShutdownConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter le serveur ?'**
  String get adminShutdownConfirmTitle;

  /// No description provided for @adminShutdownConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur Jellyfin sera arrêté. Il faudra le redémarrer manuellement (machine, conteneur, service systemd).'**
  String get adminShutdownConfirmMessage;

  /// No description provided for @adminShutdownConfirmLabel.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter'**
  String get adminShutdownConfirmLabel;

  /// No description provided for @adminShutdownSnack.
  ///
  /// In fr, this message translates to:
  /// **'Arrêt demandé.'**
  String get adminShutdownSnack;

  /// No description provided for @adminErrorPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String adminErrorPrefix(String error);

  /// No description provided for @adminFailurePrefix.
  ///
  /// In fr, this message translates to:
  /// **'Échec : {error}'**
  String adminFailurePrefix(String error);

  /// No description provided for @adminLibrariesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune bibliothèque configurée.'**
  String get adminLibrariesEmpty;

  /// No description provided for @adminLibrariesScanAll.
  ///
  /// In fr, this message translates to:
  /// **'Lancer un scan complet'**
  String get adminLibrariesScanAll;

  /// No description provided for @adminLibrariesScanAllTitle.
  ///
  /// In fr, this message translates to:
  /// **'Lancer un scan complet ?'**
  String get adminLibrariesScanAllTitle;

  /// No description provided for @adminLibrariesScanAllMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur va analyser toutes les bibliothèques en arrière-plan. Cela peut prendre plusieurs minutes selon la taille de la médiathèque.'**
  String get adminLibrariesScanAllMessage;

  /// No description provided for @adminLibrariesScanAllConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Lancer'**
  String get adminLibrariesScanAllConfirm;

  /// No description provided for @adminLibrariesScanSnack.
  ///
  /// In fr, this message translates to:
  /// **'Scan lancé.'**
  String get adminLibrariesScanSnack;

  /// No description provided for @adminLibrariesScanOneSnack.
  ///
  /// In fr, this message translates to:
  /// **'Scan lancé pour « {name} ».'**
  String adminLibrariesScanOneSnack(String name);

  /// No description provided for @adminLibrariesTooltipScan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner cette bibliothèque'**
  String get adminLibrariesTooltipScan;

  /// No description provided for @adminTasksNoTasks.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche.'**
  String get adminTasksNoTasks;

  /// No description provided for @adminTasksRunning.
  ///
  /// In fr, this message translates to:
  /// **'En cours…'**
  String get adminTasksRunning;

  /// No description provided for @adminTasksRunningPercent.
  ///
  /// In fr, this message translates to:
  /// **'En cours… {percent}%'**
  String adminTasksRunningPercent(String percent);

  /// No description provided for @adminTasksCancelling.
  ///
  /// In fr, this message translates to:
  /// **'Annulation…'**
  String get adminTasksCancelling;

  /// No description provided for @adminTasksNeverRun.
  ///
  /// In fr, this message translates to:
  /// **'Jamais exécutée'**
  String get adminTasksNeverRun;

  /// No description provided for @adminTasksCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminée {ago}'**
  String adminTasksCompleted(String ago);

  /// No description provided for @adminTasksFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec {ago}'**
  String adminTasksFailed(String ago);

  /// No description provided for @adminTasksTooltipStop.
  ///
  /// In fr, this message translates to:
  /// **'Interrompre'**
  String get adminTasksTooltipStop;

  /// No description provided for @adminTasksTooltipStart.
  ///
  /// In fr, this message translates to:
  /// **'Lancer'**
  String get adminTasksTooltipStart;

  /// No description provided for @adminTasksLastRunStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get adminTasksLastRunStatus;

  /// No description provided for @adminTasksLastRunStart.
  ///
  /// In fr, this message translates to:
  /// **'Début'**
  String get adminTasksLastRunStart;

  /// No description provided for @adminTasksLastRunEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get adminTasksLastRunEnd;

  /// No description provided for @adminTasksLastRunDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get adminTasksLastRunDuration;

  /// No description provided for @adminTasksLastRunError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get adminTasksLastRunError;

  /// No description provided for @adminUsersAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get adminUsersAdd;

  /// No description provided for @adminUsersEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur.'**
  String get adminUsersEmpty;

  /// No description provided for @adminUsersNeverConnected.
  ///
  /// In fr, this message translates to:
  /// **'Jamais connecté'**
  String get adminUsersNeverConnected;

  /// No description provided for @adminUsersSeenAt.
  ///
  /// In fr, this message translates to:
  /// **'Vu {when}'**
  String adminUsersSeenAt(String when);

  /// No description provided for @adminUsersBadgeAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get adminUsersBadgeAdmin;

  /// No description provided for @adminUsersBadgeDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get adminUsersBadgeDisabled;

  /// No description provided for @adminUserCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel utilisateur'**
  String get adminUserCreateTitle;

  /// No description provided for @adminUserCreateName.
  ///
  /// In fr, this message translates to:
  /// **'Nom d\'utilisateur'**
  String get adminUserCreateName;

  /// No description provided for @adminUserCreatePassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get adminUserCreatePassword;

  /// No description provided for @adminUserCreatePasswordHelper.
  ///
  /// In fr, this message translates to:
  /// **'Laissez vide pour aucun mot de passe initial.'**
  String get adminUserCreatePasswordHelper;

  /// No description provided for @adminUserCreateIsAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get adminUserCreateIsAdmin;

  /// No description provided for @adminUserCreateIsAdminSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Donne tous les droits sur le serveur Jellyfin.'**
  String get adminUserCreateIsAdminSubtitle;

  /// No description provided for @adminUserCreateRequired.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get adminUserCreateRequired;

  /// No description provided for @adminUserCreateButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer le compte'**
  String get adminUserCreateButton;

  /// No description provided for @adminUserEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get adminUserEditTitle;

  /// No description provided for @adminUserEditIdentitySection.
  ///
  /// In fr, this message translates to:
  /// **'IDENTITÉ'**
  String get adminUserEditIdentitySection;

  /// No description provided for @adminUserEditLastLogin.
  ///
  /// In fr, this message translates to:
  /// **'Dernière connexion'**
  String get adminUserEditLastLogin;

  /// No description provided for @adminUserEditRightsSection.
  ///
  /// In fr, this message translates to:
  /// **'DROITS'**
  String get adminUserEditRightsSection;

  /// No description provided for @adminUserEditIsAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get adminUserEditIsAdmin;

  /// No description provided for @adminUserEditIsAdminSelfHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez pas retirer vos propres droits.'**
  String get adminUserEditIsAdminSelfHint;

  /// No description provided for @adminUserEditIsDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Compte désactivé'**
  String get adminUserEditIsDisabled;

  /// No description provided for @adminUserEditIsDisabledSelfHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez pas vous désactiver vous-même.'**
  String get adminUserEditIsDisabledSelfHint;

  /// No description provided for @adminUserEditLibrariesSection.
  ///
  /// In fr, this message translates to:
  /// **'BIBLIOTHÈQUES'**
  String get adminUserEditLibrariesSection;

  /// No description provided for @adminUserEditAllFolders.
  ///
  /// In fr, this message translates to:
  /// **'Accès à toutes les bibliothèques'**
  String get adminUserEditAllFolders;

  /// No description provided for @adminUserEditSaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get adminUserEditSaveButton;

  /// No description provided for @adminUserEditSaveSnack.
  ///
  /// In fr, this message translates to:
  /// **'Modifications enregistrées.'**
  String get adminUserEditSaveSnack;

  /// No description provided for @adminUserEditResetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get adminUserEditResetPassword;

  /// No description provided for @adminUserEditNewPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get adminUserEditNewPasswordTitle;

  /// No description provided for @adminUserEditNewPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get adminUserEditNewPasswordHint;

  /// No description provided for @adminUserEditResetPasswordCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get adminUserEditResetPasswordCancel;

  /// No description provided for @adminUserEditResetPasswordConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get adminUserEditResetPasswordConfirm;

  /// No description provided for @adminUserEditResetPasswordSnack.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe réinitialisé.'**
  String get adminUserEditResetPasswordSnack;

  /// No description provided for @adminUserEditDeleteButton.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce compte'**
  String get adminUserEditDeleteButton;

  /// No description provided for @adminUserEditDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer « {name} » ?'**
  String adminUserEditDeleteTitle(String name);

  /// No description provided for @adminUserEditDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Le compte, ses préférences et son historique de lecture seront supprimés du serveur.'**
  String get adminUserEditDeleteMessage;

  /// No description provided for @adminUserEditDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get adminUserEditDeleteConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
