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

  /// No description provided for @aboutUpdateSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mises à jour'**
  String get aboutUpdateSectionTitle;

  /// No description provided for @aboutUpdateAutoToggle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier automatiquement'**
  String get aboutUpdateAutoToggle;

  /// No description provided for @aboutUpdateAutoToggleSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Télécharge en arrière-plan dès qu\'une nouvelle version est disponible'**
  String get aboutUpdateAutoToggleSubtitle;

  /// No description provided for @aboutUpdateCheckNow.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier maintenant'**
  String get aboutUpdateCheckNow;

  /// No description provided for @aboutUpdateChecking.
  ///
  /// In fr, this message translates to:
  /// **'Vérification en cours…'**
  String get aboutUpdateChecking;

  /// No description provided for @aboutUpdateUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'Vous utilisez la dernière version.'**
  String get aboutUpdateUpToDate;

  /// No description provided for @aboutUpdateDownloading.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement de v{version}…'**
  String aboutUpdateDownloading(String version);

  /// No description provided for @aboutUpdateReadyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour prête : v{version}'**
  String aboutUpdateReadyTitle(String version);

  /// No description provided for @aboutUpdateReadyBody.
  ///
  /// In fr, this message translates to:
  /// **'L\'app va redémarrer pour appliquer l\'installation.'**
  String get aboutUpdateReadyBody;

  /// No description provided for @aboutUpdateInstall.
  ///
  /// In fr, this message translates to:
  /// **'Installer et redémarrer'**
  String get aboutUpdateInstall;

  /// No description provided for @aboutUpdateInstalling.
  ///
  /// In fr, this message translates to:
  /// **'Installation en cours…'**
  String get aboutUpdateInstalling;

  /// No description provided for @aboutUpdateReleaseNotes.
  ///
  /// In fr, this message translates to:
  /// **'Voir les notes de version'**
  String get aboutUpdateReleaseNotes;

  /// No description provided for @aboutUpdateCheckFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de vérifier les mises à jour.'**
  String get aboutUpdateCheckFailed;

  /// No description provided for @aboutUpdateDownloadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec du téléchargement de la mise à jour.'**
  String get aboutUpdateDownloadFailed;

  /// No description provided for @aboutUpdateInstallFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec du lancement de l\'installation.'**
  String get aboutUpdateInstallFailed;

  /// No description provided for @aboutUpdateUnsupportedPlatform.
  ///
  /// In fr, this message translates to:
  /// **'Les mises à jour in-app sont indisponibles sur cette plateforme.'**
  String get aboutUpdateUnsupportedPlatform;

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

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settingsLanguageSystem;

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

  /// No description provided for @settingsSectionApp.
  ///
  /// In fr, this message translates to:
  /// **'APPLICATION'**
  String get settingsSectionApp;

  /// No description provided for @settingsSectionContent.
  ///
  /// In fr, this message translates to:
  /// **'CONTENU'**
  String get settingsSectionContent;

  /// No description provided for @settingsSectionServerInfo.
  ///
  /// In fr, this message translates to:
  /// **'INFOS SERVEUR'**
  String get settingsSectionServerInfo;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get navLibrary;

  /// No description provided for @navSearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche'**
  String get navSearch;

  /// No description provided for @navCalendar.
  ///
  /// In fr, this message translates to:
  /// **'Calendrier'**
  String get navCalendar;

  /// No description provided for @navDownloads.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargements'**
  String get navDownloads;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get navSettings;

  /// No description provided for @navMenuTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Menu'**
  String get navMenuTooltip;

  /// No description provided for @syncFlushedSnack.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{{count} action synchronisée avec Jellyfin} other{{count} actions synchronisées avec Jellyfin}}'**
  String syncFlushedSnack(int count);

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

  /// No description provided for @detailsReadMore.
  ///
  /// In fr, this message translates to:
  /// **'Plus'**
  String get detailsReadMore;

  /// No description provided for @detailsReadLess.
  ///
  /// In fr, this message translates to:
  /// **'Réduire'**
  String get detailsReadLess;

  /// No description provided for @detailsAddToList.
  ///
  /// In fr, this message translates to:
  /// **'Ma liste'**
  String get detailsAddToList;

  /// No description provided for @detailsRemoveFromList.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get detailsRemoveFromList;

  /// No description provided for @detailsMarkWatched.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme vu'**
  String get detailsMarkWatched;

  /// No description provided for @detailsMarkUnwatched.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme non vu'**
  String get detailsMarkUnwatched;

  /// No description provided for @detailsTrailer.
  ///
  /// In fr, this message translates to:
  /// **'Bande-annonce'**
  String get detailsTrailer;

  /// No description provided for @detailsContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get detailsContinue;

  /// No description provided for @detailsNextUp.
  ///
  /// In fr, this message translates to:
  /// **'Prochain'**
  String get detailsNextUp;

  /// No description provided for @detailsEpisodeOverline.
  ///
  /// In fr, this message translates to:
  /// **'ÉPISODE {number}'**
  String detailsEpisodeOverline(String number);

  /// No description provided for @detailsBackToSeries.
  ///
  /// In fr, this message translates to:
  /// **'Retour à {series}'**
  String detailsBackToSeries(String series);

  /// No description provided for @detailsStudios.
  ///
  /// In fr, this message translates to:
  /// **'Studios'**
  String get detailsStudios;

  /// No description provided for @detailsReleaseDate.
  ///
  /// In fr, this message translates to:
  /// **'Sortie'**
  String get detailsReleaseDate;

  /// No description provided for @detailsOfficialRating.
  ///
  /// In fr, this message translates to:
  /// **'Classification'**
  String get detailsOfficialRating;

  /// No description provided for @detailsGenres.
  ///
  /// In fr, this message translates to:
  /// **'Genres'**
  String get detailsGenres;

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

  /// No description provided for @playerPipUnavailableIos.
  ///
  /// In fr, this message translates to:
  /// **'Picture-in-Picture non disponible sur iOS pour cette version'**
  String get playerPipUnavailableIos;

  /// No description provided for @playerFullscreen.
  ///
  /// In fr, this message translates to:
  /// **'Plein écran'**
  String get playerFullscreen;

  /// No description provided for @playerExitFullscreen.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le plein écran'**
  String get playerExitFullscreen;

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

  /// No description provided for @homeRailContinueWatching.
  ///
  /// In fr, this message translates to:
  /// **'Continuer à regarder'**
  String get homeRailContinueWatching;

  /// No description provided for @homeRailNextUp.
  ///
  /// In fr, this message translates to:
  /// **'À finir'**
  String get homeRailNextUp;

  /// No description provided for @homeHeaderJellyfin.
  ///
  /// In fr, this message translates to:
  /// **'Vos contenus'**
  String get homeHeaderJellyfin;

  /// No description provided for @homeRailLatest.
  ///
  /// In fr, this message translates to:
  /// **'Nouveautés'**
  String get homeRailLatest;

  /// No description provided for @homeRailLatestSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouts récents'**
  String get homeRailLatestSubtitle;

  /// No description provided for @homeRailForYou.
  ///
  /// In fr, this message translates to:
  /// **'Pour vous'**
  String get homeRailForYou;

  /// No description provided for @homeRailGems.
  ///
  /// In fr, this message translates to:
  /// **'Pépites'**
  String get homeRailGems;

  /// No description provided for @homeRailQuickPicks.
  ///
  /// In fr, this message translates to:
  /// **'Vite vu'**
  String get homeRailQuickPicks;

  /// No description provided for @homeRailBecauseYouLiked.
  ///
  /// In fr, this message translates to:
  /// **'Parce que vous avez aimé…'**
  String get homeRailBecauseYouLiked;

  /// No description provided for @homeRailUpcomingMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films à venir'**
  String get homeRailUpcomingMovies;

  /// No description provided for @homeRailUpcomingEpisodes.
  ///
  /// In fr, this message translates to:
  /// **'Épisodes à venir'**
  String get homeRailUpcomingEpisodes;

  /// No description provided for @homeHeaderSeer.
  ///
  /// In fr, this message translates to:
  /// **'À découvrir'**
  String get homeHeaderSeer;

  /// No description provided for @homeRailWatchProvidersMovies.
  ///
  /// In fr, this message translates to:
  /// **'Disponible sur…'**
  String get homeRailWatchProvidersMovies;

  /// No description provided for @homeRailTrending.
  ///
  /// In fr, this message translates to:
  /// **'Tendance aujourd\'hui'**
  String get homeRailTrending;

  /// No description provided for @homeRailPopularSeries.
  ///
  /// In fr, this message translates to:
  /// **'Séries qui cartonnent'**
  String get homeRailPopularSeries;

  /// No description provided for @homeRailWatchlist.
  ///
  /// In fr, this message translates to:
  /// **'Votre watchlist'**
  String get homeRailWatchlist;

  /// No description provided for @homeRailGenreSliderMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films par genre'**
  String get homeRailGenreSliderMovies;

  /// No description provided for @homeRailGenreSliderTv.
  ///
  /// In fr, this message translates to:
  /// **'Séries par genre'**
  String get homeRailGenreSliderTv;

  /// No description provided for @homeRailWatchProvidersTv.
  ///
  /// In fr, this message translates to:
  /// **'Séries par service'**
  String get homeRailWatchProvidersTv;

  /// No description provided for @homeRailBecauseYouWatched.
  ///
  /// In fr, this message translates to:
  /// **'Parce que vous avez regardé {title}'**
  String homeRailBecauseYouWatched(String title);

  /// No description provided for @homeRailSimilarTo.
  ///
  /// In fr, this message translates to:
  /// **'Comme {title}'**
  String homeRailSimilarTo(String title);

  /// No description provided for @homeMoodComedy.
  ///
  /// In fr, this message translates to:
  /// **'Pour rire un bon coup'**
  String get homeMoodComedy;

  /// No description provided for @homeMoodThrills.
  ///
  /// In fr, this message translates to:
  /// **'Pour frissonner ce soir'**
  String get homeMoodThrills;

  /// No description provided for @homeMoodTearjerker.
  ///
  /// In fr, this message translates to:
  /// **'Pour pleurer un bon coup'**
  String get homeMoodTearjerker;

  /// No description provided for @homeMoodEscape.
  ///
  /// In fr, this message translates to:
  /// **'Pour s\'évader'**
  String get homeMoodEscape;

  /// No description provided for @homeMoodAcclaimed.
  ///
  /// In fr, this message translates to:
  /// **'Acclamés par la critique'**
  String get homeMoodAcclaimed;

  /// No description provided for @libraryRailNewMovies.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux films'**
  String get libraryRailNewMovies;

  /// No description provided for @libraryRailNewEpisodes.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux épisodes'**
  String get libraryRailNewEpisodes;

  /// No description provided for @libraryRailNewSeries.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles séries'**
  String get libraryRailNewSeries;

  /// No description provided for @libraryRailNewBoxsets.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux coffrets'**
  String get libraryRailNewBoxsets;

  /// No description provided for @libraryRailNewAlbums.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux albums'**
  String get libraryRailNewAlbums;

  /// No description provided for @libraryRailNewMusicVideos.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux clips'**
  String get libraryRailNewMusicVideos;

  /// No description provided for @libraryRailNewBooks.
  ///
  /// In fr, this message translates to:
  /// **'Nouveaux livres'**
  String get libraryRailNewBooks;

  /// No description provided for @libraryRailNewVideos.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles vidéos'**
  String get libraryRailNewVideos;

  /// No description provided for @libraryRailNewPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles photos'**
  String get libraryRailNewPhotos;

  /// No description provided for @libraryRailNewTrailers.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles bandes-annonces'**
  String get libraryRailNewTrailers;

  /// No description provided for @adminSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions actives'**
  String get adminSessions;

  /// No description provided for @adminSessionsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Clients en lecture'**
  String get adminSessionsSubtitle;

  /// No description provided for @adminSessionsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune session active'**
  String get adminSessionsEmpty;

  /// No description provided for @adminSessionsIdle.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get adminSessionsIdle;

  /// No description provided for @adminSessionsPlaying.
  ///
  /// In fr, this message translates to:
  /// **'En lecture : {title}'**
  String adminSessionsPlaying(String title);

  /// No description provided for @adminSessionsBadgeActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get adminSessionsBadgeActive;

  /// No description provided for @adminSessionsSendMessage.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un message'**
  String get adminSessionsSendMessage;

  /// No description provided for @adminSessionsStopPlayback.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la lecture'**
  String get adminSessionsStopPlayback;

  /// No description provided for @adminSessionsMessageDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un message'**
  String get adminSessionsMessageDialogTitle;

  /// No description provided for @adminSessionsMessageDialogLabel.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get adminSessionsMessageDialogLabel;

  /// No description provided for @adminSessionsMessageDialogHint.
  ///
  /// In fr, this message translates to:
  /// **'S\'affichera sur l\'écran de l\'utilisateur'**
  String get adminSessionsMessageDialogHint;

  /// No description provided for @adminSessionsMessageDialogSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get adminSessionsMessageDialogSend;

  /// No description provided for @adminSessionsMessageSent.
  ///
  /// In fr, this message translates to:
  /// **'Message envoyé'**
  String get adminSessionsMessageSent;

  /// No description provided for @adminSessionsStopConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la lecture ?'**
  String get adminSessionsStopConfirmTitle;

  /// No description provided for @adminSessionsStopConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'La lecture en cours de l\'utilisateur sera interrompue.'**
  String get adminSessionsStopConfirmMessage;

  /// No description provided for @adminSessionsStopSnack.
  ///
  /// In fr, this message translates to:
  /// **'Lecture arrêtée'**
  String get adminSessionsStopSnack;

  /// No description provided for @adminDevices.
  ///
  /// In fr, this message translates to:
  /// **'Appareils enregistrés'**
  String get adminDevices;

  /// No description provided for @adminDevicesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Clients connectés à ce serveur'**
  String get adminDevicesSubtitle;

  /// No description provided for @adminDevicesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil enregistré'**
  String get adminDevicesEmpty;

  /// No description provided for @adminDevicesRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get adminDevicesRename;

  /// No description provided for @adminDevicesDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get adminDevicesDelete;

  /// No description provided for @adminDevicesRenameDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renommer l\'appareil'**
  String get adminDevicesRenameDialogTitle;

  /// No description provided for @adminDevicesRenameDialogLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom personnalisé'**
  String get adminDevicesRenameDialogLabel;

  /// No description provided for @adminDevicesRenameDialogSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get adminDevicesRenameDialogSave;

  /// No description provided for @adminDevicesRenameSnack.
  ///
  /// In fr, this message translates to:
  /// **'Appareil renommé'**
  String get adminDevicesRenameSnack;

  /// No description provided for @adminDevicesDeleteConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cet appareil ?'**
  String get adminDevicesDeleteConfirmTitle;

  /// No description provided for @adminDevicesDeleteConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'L\'utilisateur devra se reconnecter sur cet appareil.'**
  String get adminDevicesDeleteConfirmMessage;

  /// No description provided for @adminDevicesDeleteSnack.
  ///
  /// In fr, this message translates to:
  /// **'Appareil supprimé'**
  String get adminDevicesDeleteSnack;

  /// No description provided for @adminActivityLog.
  ///
  /// In fr, this message translates to:
  /// **'Journal d\'activité'**
  String get adminActivityLog;

  /// No description provided for @adminActivityLogSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des événements serveur'**
  String get adminActivityLogSubtitle;

  /// No description provided for @adminActivityEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activité à afficher'**
  String get adminActivityEmpty;

  /// No description provided for @adminActivityFiltersTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get adminActivityFiltersTooltip;

  /// No description provided for @adminActivityFiltersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get adminActivityFiltersTitle;

  /// No description provided for @adminActivityFilterLast7Days.
  ///
  /// In fr, this message translates to:
  /// **'7 derniers jours uniquement'**
  String get adminActivityFilterLast7Days;

  /// No description provided for @adminActivityFilterUserOnly.
  ///
  /// In fr, this message translates to:
  /// **'Actions utilisateur uniquement'**
  String get adminActivityFilterUserOnly;

  /// No description provided for @adminServerLogs.
  ///
  /// In fr, this message translates to:
  /// **'Logs du serveur'**
  String get adminServerLogs;

  /// No description provided for @adminServerLogsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Consulter les fichiers de log'**
  String get adminServerLogsSubtitle;

  /// No description provided for @adminServerLogsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun fichier de log disponible'**
  String get adminServerLogsEmpty;

  /// No description provided for @adminLogViewerCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get adminLogViewerCopy;

  /// No description provided for @adminLogViewerCopied.
  ///
  /// In fr, this message translates to:
  /// **'Log copié dans le presse-papiers'**
  String get adminLogViewerCopied;

  /// No description provided for @adminLogViewerEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier de log est vide'**
  String get adminLogViewerEmpty;

  /// No description provided for @adminPlugins.
  ///
  /// In fr, this message translates to:
  /// **'Plugins'**
  String get adminPlugins;

  /// No description provided for @adminPluginsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les plugins du serveur'**
  String get adminPluginsSubtitle;

  /// No description provided for @adminPluginsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun plugin n\'est installé sur ce serveur.'**
  String get adminPluginsEmpty;

  /// No description provided for @adminPluginsUninstall.
  ///
  /// In fr, this message translates to:
  /// **'Désinstaller'**
  String get adminPluginsUninstall;

  /// No description provided for @adminPluginsUninstallConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Désinstaller le plugin ?'**
  String get adminPluginsUninstallConfirmTitle;

  /// No description provided for @adminPluginsUninstallConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'Le plugin « {name} » sera supprimé définitivement. Le serveur devra peut-être redémarrer pour que le changement prenne effet.'**
  String adminPluginsUninstallConfirmMessage(String name);

  /// No description provided for @adminPluginsUninstallConfirmLabel.
  ///
  /// In fr, this message translates to:
  /// **'Désinstaller'**
  String get adminPluginsUninstallConfirmLabel;

  /// No description provided for @adminPluginsStatusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get adminPluginsStatusActive;

  /// No description provided for @adminPluginsStatusDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get adminPluginsStatusDisabled;

  /// No description provided for @adminPluginsStatusRestart.
  ///
  /// In fr, this message translates to:
  /// **'Redémarrage requis'**
  String get adminPluginsStatusRestart;

  /// No description provided for @adminPluginsStatusMalfunctioned.
  ///
  /// In fr, this message translates to:
  /// **'Défaillant'**
  String get adminPluginsStatusMalfunctioned;

  /// No description provided for @adminPluginsStatusNotSupported.
  ///
  /// In fr, this message translates to:
  /// **'Non supporté'**
  String get adminPluginsStatusNotSupported;

  /// No description provided for @adminPluginsStatusDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Supprimé'**
  String get adminPluginsStatusDeleted;

  /// No description provided for @adminPluginsStatusSuperseded.
  ///
  /// In fr, this message translates to:
  /// **'Remplacé'**
  String get adminPluginsStatusSuperseded;

  /// No description provided for @adminPluginsVersionLabel.
  ///
  /// In fr, this message translates to:
  /// **'v{version}'**
  String adminPluginsVersionLabel(String version);

  /// No description provided for @adminPluginsEnableTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Activer le plugin'**
  String get adminPluginsEnableTooltip;

  /// No description provided for @adminPluginsDisableTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver le plugin'**
  String get adminPluginsDisableTooltip;

  /// No description provided for @adminApiKeys.
  ///
  /// In fr, this message translates to:
  /// **'Clés API'**
  String get adminApiKeys;

  /// No description provided for @adminApiKeysSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les jetons applicatifs'**
  String get adminApiKeysSubtitle;

  /// No description provided for @adminApiKeysEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune clé API n\'a encore été créée.'**
  String get adminApiKeysEmpty;

  /// No description provided for @adminApiKeysCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get adminApiKeysCreate;

  /// No description provided for @adminApiKeysCreateDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle clé API'**
  String get adminApiKeysCreateDialogTitle;

  /// No description provided for @adminApiKeysAppNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'application'**
  String get adminApiKeysAppNameLabel;

  /// No description provided for @adminApiKeysAppNameHelper.
  ///
  /// In fr, this message translates to:
  /// **'Aide à identifier l\'intégration qui utilise cette clé.'**
  String get adminApiKeysAppNameHelper;

  /// No description provided for @adminApiKeysAppNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom de l\'application est requis.'**
  String get adminApiKeysAppNameRequired;

  /// No description provided for @adminApiKeysCreateButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer la clé'**
  String get adminApiKeysCreateButton;

  /// No description provided for @adminApiKeysCreateSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Clé API créée. Elle est désormais visible dans la liste.'**
  String get adminApiKeysCreateSuccess;

  /// No description provided for @adminApiKeysCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get adminApiKeysCancel;

  /// No description provided for @adminApiKeysCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier le jeton'**
  String get adminApiKeysCopy;

  /// No description provided for @adminApiKeysCopied.
  ///
  /// In fr, this message translates to:
  /// **'Jeton copié dans le presse-papiers.'**
  String get adminApiKeysCopied;

  /// No description provided for @adminApiKeysRevoke.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer'**
  String get adminApiKeysRevoke;

  /// No description provided for @adminApiKeysRevokeConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer la clé API ?'**
  String get adminApiKeysRevokeConfirmTitle;

  /// No description provided for @adminApiKeysRevokeConfirmMessage.
  ///
  /// In fr, this message translates to:
  /// **'La clé pour « {app} » sera révoquée immédiatement. Tout client qui l\'utilise sera déconnecté.'**
  String adminApiKeysRevokeConfirmMessage(String app);

  /// No description provided for @adminApiKeysRevokeConfirmLabel.
  ///
  /// In fr, this message translates to:
  /// **'Révoquer'**
  String get adminApiKeysRevokeConfirmLabel;

  /// No description provided for @adminApiKeysCreatedAt.
  ///
  /// In fr, this message translates to:
  /// **'Créée le {date}'**
  String adminApiKeysCreatedAt(String date);

  /// No description provided for @adminLibrariesAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une bibliothèque'**
  String get adminLibrariesAdd;

  /// No description provided for @adminLibrariesActionsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get adminLibrariesActionsTooltip;

  /// No description provided for @adminLibrariesMenuScan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get adminLibrariesMenuScan;

  /// No description provided for @adminLibrariesMenuRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get adminLibrariesMenuRename;

  /// No description provided for @adminLibrariesMenuAddPath.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un chemin'**
  String get adminLibrariesMenuAddPath;

  /// No description provided for @adminLibrariesMenuManagePaths.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les chemins'**
  String get adminLibrariesMenuManagePaths;

  /// No description provided for @adminLibrariesMenuDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get adminLibrariesMenuDelete;

  /// No description provided for @adminLibraryEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle bibliothèque'**
  String get adminLibraryEditTitle;

  /// No description provided for @adminLibraryNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get adminLibraryNameLabel;

  /// No description provided for @adminLibraryNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est requis'**
  String get adminLibraryNameRequired;

  /// No description provided for @adminLibraryTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Type de collection'**
  String get adminLibraryTypeLabel;

  /// No description provided for @adminLibraryPathsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers'**
  String get adminLibraryPathsLabel;

  /// No description provided for @adminLibraryNoPaths.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dossier ajouté.'**
  String get adminLibraryNoPaths;

  /// No description provided for @adminLibraryAddPath.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un chemin'**
  String get adminLibraryAddPath;

  /// No description provided for @adminLibraryRemovePath.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le chemin'**
  String get adminLibraryRemovePath;

  /// No description provided for @adminLibraryRefreshAfter.
  ///
  /// In fr, this message translates to:
  /// **'Scanner la bibliothèque après création'**
  String get adminLibraryRefreshAfter;

  /// No description provided for @adminLibraryRefreshAfterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Lance un scan initial une fois la bibliothèque créée.'**
  String get adminLibraryRefreshAfterSubtitle;

  /// No description provided for @adminLibraryCreateButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer la bibliothèque'**
  String get adminLibraryCreateButton;

  /// No description provided for @adminLibraryPathsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins un dossier avant de créer la bibliothèque.'**
  String get adminLibraryPathsRequired;

  /// No description provided for @adminLibraryCreatedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque créée.'**
  String get adminLibraryCreatedSnack;

  /// No description provided for @adminLibraryTypeMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films'**
  String get adminLibraryTypeMovies;

  /// No description provided for @adminLibraryTypeTvshows.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get adminLibraryTypeTvshows;

  /// No description provided for @adminLibraryTypeMusic.
  ///
  /// In fr, this message translates to:
  /// **'Musique'**
  String get adminLibraryTypeMusic;

  /// No description provided for @adminLibraryTypeMusicvideos.
  ///
  /// In fr, this message translates to:
  /// **'Clips musicaux'**
  String get adminLibraryTypeMusicvideos;

  /// No description provided for @adminLibraryTypeHomevideos.
  ///
  /// In fr, this message translates to:
  /// **'Vidéos personnelles'**
  String get adminLibraryTypeHomevideos;

  /// No description provided for @adminLibraryTypeBoxsets.
  ///
  /// In fr, this message translates to:
  /// **'Collections'**
  String get adminLibraryTypeBoxsets;

  /// No description provided for @adminLibraryTypeBooks.
  ///
  /// In fr, this message translates to:
  /// **'Livres'**
  String get adminLibraryTypeBooks;

  /// No description provided for @adminLibraryTypeMixed.
  ///
  /// In fr, this message translates to:
  /// **'Mixte'**
  String get adminLibraryTypeMixed;

  /// No description provided for @adminLibraryRenameTitle.
  ///
  /// In fr, this message translates to:
  /// **'Renommer la bibliothèque'**
  String get adminLibraryRenameTitle;

  /// No description provided for @adminLibraryRenameCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get adminLibraryRenameCancel;

  /// No description provided for @adminLibraryRenameConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get adminLibraryRenameConfirm;

  /// No description provided for @adminLibraryRenamedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque renommée en {name}.'**
  String adminLibraryRenamedSnack(String name);

  /// No description provided for @adminLibraryDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la bibliothèque'**
  String get adminLibraryDeleteTitle;

  /// No description provided for @adminLibraryDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer définitivement la bibliothèque « {name} » ? Les fichiers sur le disque sont conservés.'**
  String adminLibraryDeleteMessage(String name);

  /// No description provided for @adminLibraryDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get adminLibraryDeleteConfirm;

  /// No description provided for @adminLibraryDeletedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque « {name} » supprimée.'**
  String adminLibraryDeletedSnack(String name);

  /// No description provided for @adminLibraryPathAddedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Chemin ajouté : {path}'**
  String adminLibraryPathAddedSnack(String path);

  /// No description provided for @adminLibraryPathRemovedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Chemin retiré : {path}'**
  String adminLibraryPathRemovedSnack(String path);

  /// No description provided for @adminLibraryManagePathsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Chemins de « {name} »'**
  String adminLibraryManagePathsTitle(String name);

  /// No description provided for @adminLibraryRemovePathTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer le chemin'**
  String get adminLibraryRemovePathTitle;

  /// No description provided for @adminLibraryRemovePathMessage.
  ///
  /// In fr, this message translates to:
  /// **'Retirer « {path} » de cette bibliothèque ? Les fichiers sur le disque sont conservés.'**
  String adminLibraryRemovePathMessage(String path);

  /// No description provided for @adminLibraryRemovePathConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get adminLibraryRemovePathConfirm;

  /// No description provided for @adminLibraryPathPickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un dossier'**
  String get adminLibraryPathPickerTitle;

  /// No description provided for @adminLibraryPathPickerClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get adminLibraryPathPickerClose;

  /// No description provided for @adminLibraryPathPickerUp.
  ///
  /// In fr, this message translates to:
  /// **'Remonter'**
  String get adminLibraryPathPickerUp;

  /// No description provided for @adminLibraryPathPickerRoot.
  ///
  /// In fr, this message translates to:
  /// **'Disques'**
  String get adminLibraryPathPickerRoot;

  /// No description provided for @adminLibraryPathPickerValidate.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ce dossier'**
  String get adminLibraryPathPickerValidate;

  /// No description provided for @adminLibraryPathPickerEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ce dossier est vide.'**
  String get adminLibraryPathPickerEmpty;

  /// No description provided for @adminLibraryPathPickerSelect.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner'**
  String get adminLibraryPathPickerSelect;

  /// No description provided for @adminLibraryPathValidationWarning.
  ///
  /// In fr, this message translates to:
  /// **'Avertissement de validation : {error}'**
  String adminLibraryPathValidationWarning(String error);

  /// No description provided for @adminServerConfig.
  ///
  /// In fr, this message translates to:
  /// **'Configuration serveur'**
  String get adminServerConfig;

  /// No description provided for @adminServerConfigSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Identité, chemins, comportement'**
  String get adminServerConfigSubtitle;

  /// No description provided for @adminServerConfigIdentitySection.
  ///
  /// In fr, this message translates to:
  /// **'IDENTITÉ'**
  String get adminServerConfigIdentitySection;

  /// No description provided for @adminServerConfigServerName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du serveur'**
  String get adminServerConfigServerName;

  /// No description provided for @adminServerConfigUiCulture.
  ///
  /// In fr, this message translates to:
  /// **'Langue de l\'interface serveur'**
  String get adminServerConfigUiCulture;

  /// No description provided for @adminServerConfigPathsSection.
  ///
  /// In fr, this message translates to:
  /// **'CHEMINS'**
  String get adminServerConfigPathsSection;

  /// No description provided for @adminServerConfigCachePath.
  ///
  /// In fr, this message translates to:
  /// **'Chemin du cache'**
  String get adminServerConfigCachePath;

  /// No description provided for @adminServerConfigMetadataPath.
  ///
  /// In fr, this message translates to:
  /// **'Chemin des métadonnées'**
  String get adminServerConfigMetadataPath;

  /// No description provided for @adminServerConfigStartupWizard.
  ///
  /// In fr, this message translates to:
  /// **'Assistant d\'installation'**
  String get adminServerConfigStartupWizard;

  /// No description provided for @adminServerConfigStartupWizardDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminé'**
  String get adminServerConfigStartupWizardDone;

  /// No description provided for @adminServerConfigStartupWizardPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get adminServerConfigStartupWizardPending;

  /// No description provided for @adminServerConfigBehaviorSection.
  ///
  /// In fr, this message translates to:
  /// **'COMPORTEMENT'**
  String get adminServerConfigBehaviorSection;

  /// No description provided for @adminServerConfigQuickConnect.
  ///
  /// In fr, this message translates to:
  /// **'Quick Connect'**
  String get adminServerConfigQuickConnect;

  /// No description provided for @adminServerConfigEnableMetrics.
  ///
  /// In fr, this message translates to:
  /// **'Métriques Prometheus'**
  String get adminServerConfigEnableMetrics;

  /// No description provided for @adminServerConfigEnableMetricsHint.
  ///
  /// In fr, this message translates to:
  /// **'Expose les métriques sur /metrics'**
  String get adminServerConfigEnableMetricsHint;

  /// No description provided for @adminServerConfigNormalizedIds.
  ///
  /// In fr, this message translates to:
  /// **'IDs normalisés (item-by-name)'**
  String get adminServerConfigNormalizedIds;

  /// No description provided for @adminServerConfigNormalizedIdsHint.
  ///
  /// In fr, this message translates to:
  /// **'Recommandé sur les nouveaux serveurs'**
  String get adminServerConfigNormalizedIdsHint;

  /// No description provided for @adminServerConfigDiagnosticsSection.
  ///
  /// In fr, this message translates to:
  /// **'DIAGNOSTICS'**
  String get adminServerConfigDiagnosticsSection;

  /// No description provided for @adminServerConfigLogRetention.
  ///
  /// In fr, this message translates to:
  /// **'Rétention des logs (jours)'**
  String get adminServerConfigLogRetention;

  /// No description provided for @adminServerConfigSlowResponse.
  ///
  /// In fr, this message translates to:
  /// **'Avertir si réponse lente'**
  String get adminServerConfigSlowResponse;

  /// No description provided for @adminServerConfigSlowResponseThreshold.
  ///
  /// In fr, this message translates to:
  /// **'Seuil de réponse lente (ms)'**
  String get adminServerConfigSlowResponseThreshold;

  /// No description provided for @adminServerConfigCorsSection.
  ///
  /// In fr, this message translates to:
  /// **'CORS'**
  String get adminServerConfigCorsSection;

  /// No description provided for @adminServerConfigCorsHint.
  ///
  /// In fr, this message translates to:
  /// **'Hôtes autorisés à appeler l\'API depuis le navigateur. Utilisez * pour tout autoriser.'**
  String get adminServerConfigCorsHint;

  /// No description provided for @adminServerConfigCorsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun hôte CORS configuré.'**
  String get adminServerConfigCorsEmpty;

  /// No description provided for @adminServerConfigCorsAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un hôte'**
  String get adminServerConfigCorsAdd;

  /// No description provided for @adminServerConfigCorsAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un hôte CORS'**
  String get adminServerConfigCorsAddTitle;

  /// No description provided for @adminServerConfigCorsAddHint.
  ///
  /// In fr, this message translates to:
  /// **'https://exemple.com'**
  String get adminServerConfigCorsAddHint;

  /// No description provided for @adminServerConfigCorsAddCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get adminServerConfigCorsAddCancel;

  /// No description provided for @adminServerConfigCorsAddConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get adminServerConfigCorsAddConfirm;

  /// No description provided for @adminServerConfigSaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer la configuration'**
  String get adminServerConfigSaveButton;

  /// No description provided for @adminServerConfigSaveSnack.
  ///
  /// In fr, this message translates to:
  /// **'Configuration enregistrée'**
  String get adminServerConfigSaveSnack;

  /// No description provided for @adminBranding.
  ///
  /// In fr, this message translates to:
  /// **'Identité visuelle'**
  String get adminBranding;

  /// No description provided for @adminBrandingSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mention de connexion, CSS personnalisé, splashscreen'**
  String get adminBrandingSubtitle;

  /// No description provided for @adminBrandingMessagesSection.
  ///
  /// In fr, this message translates to:
  /// **'MESSAGES'**
  String get adminBrandingMessagesSection;

  /// No description provided for @adminBrandingLoginDisclaimer.
  ///
  /// In fr, this message translates to:
  /// **'Mention de connexion'**
  String get adminBrandingLoginDisclaimer;

  /// No description provided for @adminBrandingLoginDisclaimerHint.
  ///
  /// In fr, this message translates to:
  /// **'Affichée sur l\'écran de connexion'**
  String get adminBrandingLoginDisclaimerHint;

  /// No description provided for @adminBrandingAppearanceSection.
  ///
  /// In fr, this message translates to:
  /// **'APPARENCE'**
  String get adminBrandingAppearanceSection;

  /// No description provided for @adminBrandingSplashscreenEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Activer l\'écran de démarrage'**
  String get adminBrandingSplashscreenEnabled;

  /// No description provided for @adminBrandingSplashscreenEnabledHint.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser un écran de démarrage personnalisé sur les clients compatibles'**
  String get adminBrandingSplashscreenEnabledHint;

  /// No description provided for @adminBrandingCustomCss.
  ///
  /// In fr, this message translates to:
  /// **'CSS personnalisé'**
  String get adminBrandingCustomCss;

  /// No description provided for @adminBrandingCustomCssHint.
  ///
  /// In fr, this message translates to:
  /// **'Injecté dans le client web'**
  String get adminBrandingCustomCssHint;

  /// No description provided for @adminBrandingSaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer l\'identité'**
  String get adminBrandingSaveButton;

  /// No description provided for @adminBrandingSaveSnack.
  ///
  /// In fr, this message translates to:
  /// **'Identité enregistrée'**
  String get adminBrandingSaveSnack;

  /// No description provided for @adminBackup.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde & restauration'**
  String get adminBackup;

  /// No description provided for @adminBackupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer et restaurer les sauvegardes du serveur'**
  String get adminBackupSubtitle;

  /// No description provided for @adminBackupListSection.
  ///
  /// In fr, this message translates to:
  /// **'SAUVEGARDES DISPONIBLES'**
  String get adminBackupListSection;

  /// No description provided for @adminBackupEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune sauvegarde trouvée.'**
  String get adminBackupEmpty;

  /// No description provided for @adminBackupCreateSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer une sauvegarde'**
  String get adminBackupCreateSectionTitle;

  /// No description provided for @adminBackupCreateHint.
  ///
  /// In fr, this message translates to:
  /// **'Archive la base du serveur et les contenus sélectionnés. L\'opération peut prendre plusieurs minutes.'**
  String get adminBackupCreateHint;

  /// No description provided for @adminBackupCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer une sauvegarde maintenant'**
  String get adminBackupCreate;

  /// No description provided for @adminBackupCreating.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde en cours…'**
  String get adminBackupCreating;

  /// No description provided for @adminBackupCreateSnack.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde créée'**
  String get adminBackupCreateSnack;

  /// No description provided for @adminBackupVersionPrefix.
  ///
  /// In fr, this message translates to:
  /// **'Serveur v{version}'**
  String adminBackupVersionPrefix(String version);

  /// No description provided for @adminBackupContentMetadata.
  ///
  /// In fr, this message translates to:
  /// **'Métadonnées'**
  String get adminBackupContentMetadata;

  /// No description provided for @adminBackupContentDatabase.
  ///
  /// In fr, this message translates to:
  /// **'Base de données'**
  String get adminBackupContentDatabase;

  /// No description provided for @adminBackupContentSubtitles.
  ///
  /// In fr, this message translates to:
  /// **'Sous-titres'**
  String get adminBackupContentSubtitles;

  /// No description provided for @adminBackupContentTrickplay.
  ///
  /// In fr, this message translates to:
  /// **'Trickplay'**
  String get adminBackupContentTrickplay;

  /// No description provided for @adminBackupRestoreTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer cette sauvegarde'**
  String get adminBackupRestoreTooltip;

  /// No description provided for @adminBackupRestoreConfirm1Title.
  ///
  /// In fr, this message translates to:
  /// **'Restaurer cette sauvegarde ?'**
  String get adminBackupRestoreConfirm1Title;

  /// No description provided for @adminBackupRestoreConfirm1Message.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur va redémarrer et revenir à la sauvegarde sélectionnée. Toutes les modifications depuis cette sauvegarde seront perdues.'**
  String get adminBackupRestoreConfirm1Message;

  /// No description provided for @adminBackupRestoreConfirm1Confirm.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get adminBackupRestoreConfirm1Confirm;

  /// No description provided for @adminBackupRestoreConfirm2Title.
  ///
  /// In fr, this message translates to:
  /// **'Vraiment confirmer ?'**
  String get adminBackupRestoreConfirm2Title;

  /// No description provided for @adminBackupRestoreConfirm2Message.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible. Le serveur sera indisponible pendant quelques minutes.'**
  String get adminBackupRestoreConfirm2Message;

  /// No description provided for @adminBackupRestoreConfirm2Confirm.
  ///
  /// In fr, this message translates to:
  /// **'Oui, restaurer'**
  String get adminBackupRestoreConfirm2Confirm;

  /// No description provided for @adminBackupRestoreSnack.
  ///
  /// In fr, this message translates to:
  /// **'Restauration lancée ; le serveur redémarre…'**
  String get adminBackupRestoreSnack;

  /// No description provided for @castButton.
  ///
  /// In fr, this message translates to:
  /// **'Diffuser'**
  String get castButton;

  /// No description provided for @castSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Diffuser vers'**
  String get castSheetTitle;

  /// No description provided for @castSheetSearching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche d\'appareils…'**
  String get castSheetSearching;

  /// No description provided for @castSheetEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun appareil Chromecast trouvé sur votre réseau.'**
  String get castSheetEmpty;

  /// No description provided for @castSheetConnectedTo.
  ///
  /// In fr, this message translates to:
  /// **'Connecté à {device}'**
  String castSheetConnectedTo(String device);

  /// No description provided for @castSheetDisconnect.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter'**
  String get castSheetDisconnect;

  /// No description provided for @castConnecting.
  ///
  /// In fr, this message translates to:
  /// **'Connexion à {device}…'**
  String castConnecting(String device);

  /// No description provided for @castConnectionFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de se connecter à {device}'**
  String castConnectionFailed(String device);

  /// No description provided for @castMiniPlayerStop.
  ///
  /// In fr, this message translates to:
  /// **'Arrêter la diffusion'**
  String get castMiniPlayerStop;

  /// No description provided for @castNowPlayingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Diffusion en cours'**
  String get castNowPlayingTitle;

  /// No description provided for @castNowPlayingVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume du récepteur'**
  String get castNowPlayingVolume;

  /// No description provided for @castOfflineUnsupported.
  ///
  /// In fr, this message translates to:
  /// **'Diffusion indisponible pour les fichiers téléchargés'**
  String get castOfflineUnsupported;

  /// No description provided for @castStartedSnack.
  ///
  /// In fr, this message translates to:
  /// **'Diffusion sur {device}'**
  String castStartedSnack(String device);

  /// No description provided for @playerUnlockControls.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouiller les commandes'**
  String get playerUnlockControls;

  /// No description provided for @playerBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get playerBack;

  /// No description provided for @playerPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get playerPlay;

  /// No description provided for @playerPause.
  ///
  /// In fr, this message translates to:
  /// **'Pause'**
  String get playerPause;

  /// No description provided for @playerSeekBack.
  ///
  /// In fr, this message translates to:
  /// **'Reculer de 10 secondes'**
  String get playerSeekBack;

  /// No description provided for @playerSeekForward.
  ///
  /// In fr, this message translates to:
  /// **'Avancer de 10 secondes'**
  String get playerSeekForward;

  /// No description provided for @commonPlay.
  ///
  /// In fr, this message translates to:
  /// **'Lecture'**
  String get commonPlay;

  /// No description provided for @commonErrorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue'**
  String get commonErrorTitle;

  /// No description provided for @commonErrorRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonErrorRetry;

  /// No description provided for @commonEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien à afficher'**
  String get commonEmptyTitle;

  /// No description provided for @drawerExpandTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Étendre le menu'**
  String get drawerExpandTooltip;

  /// No description provided for @drawerCollapseTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Réduire le menu'**
  String get drawerCollapseTooltip;

  /// No description provided for @drawerHideAction.
  ///
  /// In fr, this message translates to:
  /// **'Masquer la navigation'**
  String get drawerHideAction;

  /// No description provided for @drawerShowTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Afficher la navigation'**
  String get drawerShowTooltip;

  /// No description provided for @syncPlayTabLabel.
  ///
  /// In fr, this message translates to:
  /// **'Visionnage groupé'**
  String get syncPlayTabLabel;

  /// No description provided for @syncPlayCreateButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer un groupe'**
  String get syncPlayCreateButton;

  /// No description provided for @syncPlayCreateDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau groupe'**
  String get syncPlayCreateDialogTitle;

  /// No description provided for @syncPlayCreateGroupNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du groupe'**
  String get syncPlayCreateGroupNameLabel;

  /// No description provided for @syncPlayCreateGroupNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : Soirée ciné'**
  String get syncPlayCreateGroupNameHint;

  /// No description provided for @syncPlayCreateGroupNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire (1–50 caractères)'**
  String get syncPlayCreateGroupNameRequired;

  /// No description provided for @syncPlayMembersCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 membre} other{{count} membres}}'**
  String syncPlayMembersCount(int count);

  /// No description provided for @syncPlayLeaveButton.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le groupe'**
  String get syncPlayLeaveButton;

  /// No description provided for @syncPlayLeaveConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le groupe ?'**
  String get syncPlayLeaveConfirmTitle;

  /// No description provided for @syncPlayLeaveConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous serez déconnecté de la session de visionnage groupé.'**
  String get syncPlayLeaveConfirmBody;

  /// No description provided for @syncPlayJoinButton.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get syncPlayJoinButton;

  /// No description provided for @syncPlayJoinError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de rejoindre le groupe'**
  String get syncPlayJoinError;

  /// No description provided for @syncPlayCreateError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer le groupe'**
  String get syncPlayCreateError;

  /// No description provided for @syncPlayErrLibraryDenied.
  ///
  /// In fr, this message translates to:
  /// **'Accès à la bibliothèque refusé par le groupe'**
  String get syncPlayErrLibraryDenied;

  /// No description provided for @syncPlayErrGroupGone.
  ///
  /// In fr, this message translates to:
  /// **'Ce groupe n\'existe plus'**
  String get syncPlayErrGroupGone;

  /// No description provided for @syncPlayErrNotInGroup.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'êtes plus membre d\'un groupe'**
  String get syncPlayErrNotInGroup;

  /// No description provided for @syncPlayErrTransport.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de connexion — réessayez'**
  String get syncPlayErrTransport;

  /// No description provided for @syncPlayIndicatorTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Visionnage groupé actif'**
  String get syncPlayIndicatorTooltip;

  /// No description provided for @syncPlayCastConflictTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Quittez Cast pour utiliser le visionnage groupé'**
  String get syncPlayCastConflictTooltip;

  /// No description provided for @syncPlayPanelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Groupe'**
  String get syncPlayPanelTitle;

  /// No description provided for @syncPlayPanelMembersHeading.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get syncPlayPanelMembersHeading;

  /// No description provided for @syncPlayPanelQueueHeading.
  ///
  /// In fr, this message translates to:
  /// **'File d\'attente'**
  String get syncPlayPanelQueueHeading;

  /// No description provided for @syncPlayPanelControlsRepeat.
  ///
  /// In fr, this message translates to:
  /// **'Répétition'**
  String get syncPlayPanelControlsRepeat;

  /// No description provided for @syncPlayPanelControlsShuffle.
  ///
  /// In fr, this message translates to:
  /// **'Aléatoire'**
  String get syncPlayPanelControlsShuffle;

  /// No description provided for @syncPlayStateIdle.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get syncPlayStateIdle;

  /// No description provided for @syncPlayStatePaused.
  ///
  /// In fr, this message translates to:
  /// **'En pause'**
  String get syncPlayStatePaused;

  /// No description provided for @syncPlayStatePlaying.
  ///
  /// In fr, this message translates to:
  /// **'En lecture'**
  String get syncPlayStatePlaying;

  /// No description provided for @syncPlayStateWaiting.
  ///
  /// In fr, this message translates to:
  /// **'Chargement…'**
  String get syncPlayStateWaiting;

  /// No description provided for @syncPlayJoinDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre un groupe'**
  String get syncPlayJoinDialogTitle;

  /// No description provided for @syncPlayCreateGroupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créer un nouveau groupe'**
  String get syncPlayCreateGroupSubtitle;

  /// No description provided for @personPageRole.
  ///
  /// In fr, this message translates to:
  /// **'Acteur'**
  String get personPageRole;

  /// No description provided for @personPageTitleCount.
  ///
  /// In fr, this message translates to:
  /// **'{role} · {count, plural, one{1 titre} other{{count} titres}}'**
  String personPageTitleCount(String role, int count);

  /// No description provided for @personFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get personFilterAll;

  /// No description provided for @personFilterMovies.
  ///
  /// In fr, this message translates to:
  /// **'Films'**
  String get personFilterMovies;

  /// No description provided for @personFilterSeries.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get personFilterSeries;

  /// No description provided for @personFilterAllSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par tout'**
  String get personFilterAllSemantics;

  /// No description provided for @personFilterMoviesSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par films'**
  String get personFilterMoviesSemantics;

  /// No description provided for @personFilterSeriesSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par séries'**
  String get personFilterSeriesSemantics;

  /// No description provided for @personFilmographyEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun titre disponible'**
  String get personFilmographyEmptyTitle;

  /// No description provided for @personFilmographyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Nous n\'avons trouvé aucun film ou série associé à cet artiste.'**
  String get personFilmographyEmpty;

  /// No description provided for @personPhotoSemantics.
  ///
  /// In fr, this message translates to:
  /// **'Photo de {name}'**
  String personPhotoSemantics(String name);

  /// No description provided for @searchPersonsSection.
  ///
  /// In fr, this message translates to:
  /// **'Personnes'**
  String get searchPersonsSection;

  /// No description provided for @searchPersonsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Acteurs et équipe'**
  String get searchPersonsTitle;
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
