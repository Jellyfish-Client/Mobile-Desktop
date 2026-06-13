// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Jellyfish';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAccount => 'COMPTE';

  @override
  String get settingsMyProfile => 'Mon profil';

  @override
  String get settingsMyProfileSubtitle =>
      'Nom d\'affichage, mot de passe, photo';

  @override
  String get settingsServer => 'Serveur';

  @override
  String get settingsUser => 'Utilisateur';

  @override
  String get settingsSwitchAccount => 'Changer de compte';

  @override
  String get settingsSwitchAccountSubtitleSingle =>
      'Ajouter un compte ou un serveur';

  @override
  String settingsSwitchAccountSubtitleMultiple(int count) {
    return '$count comptes enregistrés';
  }

  @override
  String get settingsLogout => 'Se déconnecter de ce compte';

  @override
  String get settingsDownloads => 'TÉLÉCHARGEMENTS';

  @override
  String get settingsDownloadsTitle => 'Téléchargements';

  @override
  String get settingsDownloadsSubtitle => 'Wi-Fi only, arrière-plan, stockage';

  @override
  String get settingsDiscovery => 'DÉCOUVERTE';

  @override
  String get settingsRequests => 'Mes demandes';

  @override
  String get settingsRequestsSubtitle =>
      'Suivi des films et séries demandés via Jellyseerr.';

  @override
  String get settingsPlayback => 'LECTURE';

  @override
  String get settingsPlaybackTitle => 'Lecture';

  @override
  String get settingsAdmin => 'ADMINISTRATION';

  @override
  String get settingsAdminTitle => 'Administration';

  @override
  String get settingsAdminSubtitle =>
      'Serveur, utilisateurs, bibliothèques, tâches';

  @override
  String get settingsAbout => 'À PROPOS';

  @override
  String get settingsAboutTitle => 'À propos';

  @override
  String get playbackLanguages => 'LANGUES';

  @override
  String get playbackAudioLanguage => 'Langue audio préférée';

  @override
  String get playbackSubtitleLanguage => 'Langue des sous-titres préférée';

  @override
  String get playbackSubtitleMode => 'Mode sous-titres';

  @override
  String get playbackBehavior => 'COMPORTEMENT';

  @override
  String get playbackAutoNextEpisode => 'Lecture auto de l\'épisode suivant';

  @override
  String get playbackDefaultAudioTrack => 'Lire la piste audio par défaut';

  @override
  String get playbackDefaultAudioTrackDescription =>
      'Sélectionne automatiquement la piste audio par défaut du fichier au lieu de votre langue préférée.';

  @override
  String get playbackRememberAudioSelections => 'Mémoriser les choix audio';

  @override
  String get playbackRememberSubtitleSelections =>
      'Mémoriser les choix de sous-titres';

  @override
  String get playbackShowMissingEpisodes => 'Afficher les épisodes manquants';

  @override
  String get playbackAudioLanguageUpdated => 'Langue audio mise à jour.';

  @override
  String get playbackSubtitleLanguageUpdated =>
      'Langue des sous-titres mise à jour.';

  @override
  String get playbackSubtitleModeUpdated => 'Mode sous-titres mis à jour.';

  @override
  String get playbackAutoPlayEnabled => 'Lecture auto activée.';

  @override
  String get playbackAutoPlayDisabled => 'Lecture auto désactivée.';

  @override
  String get playbackPreferenceSaved => 'Préférence enregistrée.';

  @override
  String get playbackLanguageNone => 'Aucune';

  @override
  String get playbackLanguageSearch => 'Rechercher une langue';

  @override
  String get playbackSubtitleModeDefault => 'Par défaut';

  @override
  String get playbackSubtitleModeDefaultDescription =>
      'Suit le réglage du fichier';

  @override
  String get playbackSubtitleModeAlways => 'Toujours';

  @override
  String get playbackSubtitleModeAlwaysDescription =>
      'Afficher dès qu\'une piste correspond à la langue préférée';

  @override
  String get playbackSubtitleModeOnlyForced => 'Uniquement forcés';

  @override
  String get playbackSubtitleModeOnlyForcedDescription =>
      'Seulement les sous-titres forcés';

  @override
  String get playbackSubtitleModeSmart => 'Intelligent';

  @override
  String get playbackSubtitleModeSmartDescription =>
      'Quand l\'audio n\'est pas dans votre langue préférée';

  @override
  String get playbackSubtitleModeNone => 'Aucun';

  @override
  String get playbackSubtitleModeNoneDescription => 'Ne jamais afficher';

  @override
  String get downloadsSettingsTitle => 'Téléchargements';

  @override
  String get downloadsOptions => 'OPTIONS';

  @override
  String get downloadsBackgroundEnabled => 'Téléchargements en arrière-plan';

  @override
  String get downloadsBackgroundEnabledDescription =>
      'Continue les téléchargements quand l\'app est fermée.';

  @override
  String get downloadsWifiOnly => 'Wi-Fi uniquement';

  @override
  String get downloadsWifiOnlyDescription =>
      'Bloque les nouveaux téléchargements sur le réseau mobile.';

  @override
  String get downloadsAutoDeleteWatched => 'Supprimer après visionnage';

  @override
  String get downloadsAutoDeleteWatchedDescription =>
      'Retire les épisodes téléchargés une fois la lecture terminée.';

  @override
  String get downloadsStorage => 'STOCKAGE';

  @override
  String get downloadsStorageUsed => 'Espace utilisé';

  @override
  String get downloadsDeleteAll => 'Tout supprimer';

  @override
  String get downloadsDeleteAllConfirm =>
      'Supprimer tous les téléchargements ?';

  @override
  String get downloadsDeleteAllConfirmMessage =>
      'Tous les fichiers téléchargés et leurs images locales seront supprimés. Cette action est irréversible.';

  @override
  String get aboutAppName => 'Jellyfish';

  @override
  String get aboutAppSubtitle => 'Client Jellyfin + Seerr';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Licences open-source';

  @override
  String get aboutUpdateSectionTitle => 'Mises à jour';

  @override
  String get aboutUpdateAutoToggle => 'Vérifier automatiquement';

  @override
  String get aboutUpdateAutoToggleSubtitle =>
      'Télécharge en arrière-plan dès qu\'une nouvelle version est disponible';

  @override
  String get aboutUpdateCheckNow => 'Vérifier maintenant';

  @override
  String get aboutUpdateChecking => 'Vérification en cours…';

  @override
  String get aboutUpdateUpToDate => 'Vous utilisez la dernière version.';

  @override
  String aboutUpdateDownloading(String version) {
    return 'Téléchargement de v$version…';
  }

  @override
  String aboutUpdateReadyTitle(String version) {
    return 'Mise à jour prête : v$version';
  }

  @override
  String get aboutUpdateReadyBody =>
      'L\'app va redémarrer pour appliquer l\'installation.';

  @override
  String get aboutUpdateInstall => 'Installer et redémarrer';

  @override
  String get aboutUpdateInstalling => 'Installation en cours…';

  @override
  String get aboutUpdateReleaseNotes => 'Voir les notes de version';

  @override
  String get aboutUpdateCheckFailed =>
      'Impossible de vérifier les mises à jour.';

  @override
  String get aboutUpdateDownloadFailed =>
      'Échec du téléchargement de la mise à jour.';

  @override
  String get aboutUpdateInstallFailed =>
      'Échec du lancement de l\'installation.';

  @override
  String get aboutUpdateUnsupportedPlatform =>
      'Les mises à jour in-app sont indisponibles sur cette plateforme.';

  @override
  String get profileDisplayName => 'Nom d\'affichage';

  @override
  String get profileChangePassword => 'Changer le mot de passe';

  @override
  String get profileChangePhoto => 'Changer la photo';

  @override
  String get profileDeletePhoto => 'Supprimer';

  @override
  String get profileDisplayNameUpdated => 'Nom d\'affichage mis à jour.';

  @override
  String get profilePasswordChanged => 'Mot de passe modifié.';

  @override
  String get profilePasswordIncorrect => 'Mot de passe actuel incorrect.';

  @override
  String get profilePhotoUpdated => 'Photo de profil mise à jour.';

  @override
  String get profilePhotoDeleted => 'Photo de profil supprimée.';

  @override
  String get homeNoMoreContent => 'Tu as tout vu';

  @override
  String get homeSearch => 'Rechercher';

  @override
  String get homeOffline => 'Hors ligne';

  @override
  String get homeOfflineNoDownloads => 'Aucun téléchargement';

  @override
  String get homeOfflineNoDownloadsMessage =>
      'Vous êtes hors ligne et aucun élément n\'est disponible sur cet appareil.';

  @override
  String get homeOfflineBanner => 'Mode hors ligne — votre bibliothèque locale';

  @override
  String get homeOfflineSeriesDownloaded => 'Séries téléchargées';

  @override
  String get homeOfflineMoviesDownloaded => 'Films téléchargés';

  @override
  String homeOfflineEpisodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes',
      one: '1 épisode',
    );
    return '$_temp0';
  }

  @override
  String get homePluginMissing =>
      'Le plugin Jellyfish.Bridge n\'est pas installé sur ton serveur Jellyfin. Discover, Demandes et Calendrier resteront vides. Demande à ton admin de l\'installer.';

  @override
  String get homeNoJellyseerrAccount =>
      'Ton compte Seerr n\'a pas été activé. Demande à ton admin d\'ouvrir Seerr → Settings → Users → Import Jellyfin Users.';

  @override
  String get homeJellyseerrNotConfigured =>
      'Jellyseerr n\'est pas configuré dans le plugin Jellyfish.Bridge.';

  @override
  String get homeRadarrNotConfigured =>
      'Radarr n\'est pas configuré dans le plugin Jellyfish.Bridge.';

  @override
  String get homeSonarrNotConfigured =>
      'Sonarr n\'est pas configuré dans le plugin Jellyfish.Bridge.';

  @override
  String get homeUpstreamUnreachable =>
      'Le service externe est injoignable. Réessaie dans quelques instants.';

  @override
  String get homeUpstreamTimeout =>
      'Le service externe n\'a pas répondu à temps.';

  @override
  String get homePluginMissingError =>
      'Le plugin Jellyfish.Bridge n\'est pas installé sur ton serveur.';

  @override
  String homeOtherError(int statusCode) {
    return 'Une erreur est survenue (HTTP $statusCode).';
  }

  @override
  String get libraryTitle => 'Library';

  @override
  String get librarySearch => 'Search library…';

  @override
  String get libraryAll => 'All';

  @override
  String get searchTitle => 'Rechercher un film, une série…';

  @override
  String get searchClear => 'Effacer';

  @override
  String get searchIntroTitle => 'Cherche un titre';

  @override
  String get searchIntroWithSeerr =>
      'La recherche couvre ta bibliothèque Jellyfin et te permet de demander de nouveaux titres via Seerr.';

  @override
  String get searchIntroWithoutSeerr =>
      'La recherche couvre ta bibliothèque Jellyfin.';

  @override
  String get searchIntroJellyfin => 'Bibliothèque Jellyfin';

  @override
  String get searchIntroJellyfinDescription =>
      'Films et séries déjà disponibles chez toi.';

  @override
  String get searchIntroSeerr => 'Demander via Seerr';

  @override
  String get searchIntroSeerrDescription =>
      'Trouve un nouveau titre et envoie une demande à Seerr.';

  @override
  String get searchNoResults => 'Aucun résultat';

  @override
  String searchNoResultsMessage(String query) {
    return 'Aucun titre ne correspond à « $query ».';
  }

  @override
  String get searchJellyfinSection => '01 ── BIBLIOTHÈQUE';

  @override
  String get searchJellyfinTitle => 'Dans ta bibliothèque';

  @override
  String get searchJellyfinLoadError => 'Impossible de charger Jellyfin';

  @override
  String get searchJellyfinEmpty => 'Rien ne correspond ici.';

  @override
  String get searchSeerrSection => '02 ── SEERR';

  @override
  String get searchSeerrTitle => 'Demander via Seerr';

  @override
  String get searchSeerrLoadError => 'Impossible de joindre Seerr';

  @override
  String get searchSeerrEmpty => 'Rien à demander pour cette requête.';

  @override
  String get searchSeerrCollection => 'COLLECTION';

  @override
  String get offlineSearchTitle => 'Rechercher (hors ligne)';

  @override
  String get offlineSearchHint => 'Filtrer les téléchargements…';

  @override
  String get offlineSearchNoResults => 'Aucun résultat';

  @override
  String get offlineSearchNoDownloads => 'Aucun téléchargement';

  @override
  String get offlineSearchNoDownloadsMessage =>
      'Téléchargez des films ou séries pour les retrouver hors ligne.';

  @override
  String offlineSearchNoResultsMessage(String query) {
    return 'Aucun téléchargement ne correspond à « $query ».';
  }

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadsSettings => 'Paramètres de téléchargement';

  @override
  String get downloadsNoDownloads => 'No downloads';

  @override
  String get downloadsNoDownloadsMessage =>
      'Items you download for offline playback will appear here.';

  @override
  String get downloadsInProgress => 'In progress';

  @override
  String get downloadsDownloaded => 'Downloaded';

  @override
  String get downloadsFailedOrCancelled => 'Failed / cancelled';

  @override
  String get downloadsSeriesName => 'Series';

  @override
  String get onboardingConnect => 'Connect to your Jellyfin server';

  @override
  String get onboardingServerLabel => 'Server URL';

  @override
  String get onboardingServerHint => 'https://jellyfin.example.com';

  @override
  String get onboardingServerRequired => 'Required';

  @override
  String get onboardingServerTip =>
      'Tip: https://server.example.com or LAN https://192.168.x.x:8096';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingCancel => 'Cancel';

  @override
  String get onboardingWelcomeBack => 'Welcome back';

  @override
  String get onboardingSignInSubtitle => 'Sign in to your Jellyfin account';

  @override
  String get onboardingSessionExpired => 'Session expired';

  @override
  String get onboardingSessionExpiredSubtitle =>
      'Sign in again to keep using this account';

  @override
  String get onboardingChange => 'Change';

  @override
  String get onboardingUsername => 'Username';

  @override
  String get onboardingUsernameHint => 'Your Jellyfin username';

  @override
  String get onboardingPassword => 'Password';

  @override
  String get onboardingSignIn => 'Sign in';

  @override
  String get onboardingQuickConnect => 'Use a Quick Connect code';

  @override
  String get onboardingChangeServer => 'Change server';

  @override
  String get onboardingErrorWrongCredentials => 'Wrong username or password';

  @override
  String get onboardingErrorWrongCredentialsHint =>
      'Double-check your credentials and try again.';

  @override
  String get onboardingErrorReverseProxy =>
      'Reverse proxy rejected your credentials';

  @override
  String get onboardingErrorReverseProxyHint =>
      'Include proxy credentials in the URL:\nhttps://user:pass@host';

  @override
  String get onboardingErrorAuthRequired => 'Authentication required';

  @override
  String get onboardingErrorServerNotResponding => 'Server did not respond';

  @override
  String get onboardingErrorServerNotRespondingHint =>
      'Check that the server is running and reachable.';

  @override
  String get onboardingErrorServerUnreachable => 'Could not reach the server';

  @override
  String get onboardingErrorServerUnreachableHint =>
      'Check the URL and your network connection.';

  @override
  String get onboardingErrorServerUnavailable => 'Server unavailable';

  @override
  String get onboardingErrorServerUnavailableHint =>
      'The server returned a gateway error. Try again shortly.';

  @override
  String get onboardingErrorServerError => 'Server returned an error';

  @override
  String get onboardingErrorGeneric => 'Something went wrong';

  @override
  String get quickConnectTitle => 'Quick Connect';

  @override
  String get quickConnectEnterCode => 'Enter this code';

  @override
  String get quickConnectApproved => 'Approved';

  @override
  String get quickConnectDone => 'Signed in';

  @override
  String get quickConnectFailed => 'Quick Connect failed';

  @override
  String get quickConnectExpired => 'Quick Connect expired';

  @override
  String get quickConnectGenerating => 'Generating…';

  @override
  String get quickConnectSigningIn => 'Signing in…';

  @override
  String quickConnectInstruction(String server) {
    return 'On any device already signed in to $server, open the user menu → Quick Connect, then enter the code above.';
  }

  @override
  String get quickConnectWaiting => 'Waiting for approval…';

  @override
  String get quickConnectCodeCopied => 'Code copied';

  @override
  String get quickConnectCopy => 'Copy';

  @override
  String get quickConnectExpiredMessage =>
      'The code expired before it was approved. Generate a new one to try again.';

  @override
  String get quickConnectClose => 'Close';

  @override
  String get accountsTitle => 'Comptes';

  @override
  String get accountsMyServer => 'MON SERVEUR';

  @override
  String accountsMyServers(int count) {
    return 'MES SERVEURS · $count';
  }

  @override
  String get accountsAddUser => 'Ajouter un utilisateur sur ce serveur';

  @override
  String get accountsOtherServer => 'AUTRE SERVEUR';

  @override
  String get accountsAddServer => 'Ajouter un serveur Jellyfin';

  @override
  String get accountsHint =>
      'Appuyez sur un compte pour basculer. Appui long pour supprimer.';

  @override
  String get accountsEmpty => 'Aucun compte enregistré';

  @override
  String get accountsEmptyMessage =>
      'Ajoutez un serveur Jellyfin pour commencer.';

  @override
  String get accountsForgetServer => 'Oublier ce serveur';

  @override
  String get accountsRemove => 'Supprimer';

  @override
  String get accountsActive => 'Actif';

  @override
  String accountsForgetServerTitle(String serverName) {
    return 'Oublier $serverName ?';
  }

  @override
  String accountsForgetServerMessage(int count) {
    return 'Les $count compte(s) associé(s) seront retirés de cet appareil.';
  }

  @override
  String get accountsForget => 'Oublier';

  @override
  String get accountsDeleteTitle => 'Supprimer ce compte ?';

  @override
  String accountsDeleteMessage(String userName, String serverName) {
    return '$userName sur $serverName sera retiré de cet appareil.';
  }

  @override
  String get accountsDelete => 'Supprimer';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get calendarAllTypes => 'Tout';

  @override
  String get calendarMovies => 'Films';

  @override
  String get calendarEpisodes => 'Épisodes';

  @override
  String get calendar30Days => '30 jours';

  @override
  String get calendar90Days => '3 mois';

  @override
  String get calendar365Days => '1 an';

  @override
  String get calendarMissing => 'Manquants';

  @override
  String get calendarNoData => 'Impossible de joindre le serveur.';

  @override
  String get calendarNoPlugin =>
      'Le plugin Jellyfish.Bridge n\'est pas installé sur ton serveur Jellyfin. Demande à ton admin de l\'installer.';

  @override
  String get calendarNoServices =>
      'Ni Radarr ni Sonarr ne sont configurés sur le plugin. Demande à ton admin de connecter au moins l\'un des deux.';

  @override
  String get calendarLoadError => 'Impossible de charger le calendrier.';

  @override
  String get calendarNoItems =>
      'Rien à l\'horizon sur la période sélectionnée.';

  @override
  String get requestsTitle => 'Requests';

  @override
  String get requestsSort => 'Sort requests';

  @override
  String get requestsSortRecent => 'Most recent';

  @override
  String get requestsSortOldest => 'Oldest';

  @override
  String get requestsSortStatus => 'Status';

  @override
  String get requestsSortTitle => 'Title (A–Z)';

  @override
  String get requestsAll => 'All';

  @override
  String get requestsPending => 'Pending';

  @override
  String get requestsProcessing => 'Processing';

  @override
  String get requestsAvailable => 'Available';

  @override
  String get requestsOfflineUnavailable => 'Indisponible hors ligne';

  @override
  String get requestsOfflineUnavailableMessage =>
      'Les requêtes Seerr nécessitent une connexion réseau active.';

  @override
  String get requestsNoRequests => 'No requests yet';

  @override
  String get requestsNoRequestsMessage =>
      'Browse and tap Request on something you\'d like to add.';

  @override
  String get requestsNoMatching => 'No matching requests';

  @override
  String requestsNoMatchingMessage(String filterLabel) {
    return 'No results for \"$filterLabel\".';
  }

  @override
  String get requestsStatusAvailable => 'Available';

  @override
  String get requestsStatusDownloading => 'Downloading';

  @override
  String get requestsStatusPartial => 'Partial';

  @override
  String get requestsStatusPending => 'Pending';

  @override
  String get requestsStatusUnknown => 'Unknown';

  @override
  String get requestsTypeMovie => 'Movie';

  @override
  String get requestsTypeShow => 'Show';

  @override
  String get requestsJustNow => 'Just now';

  @override
  String requestsMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String requestsHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get requestsYesterday => 'Yesterday';

  @override
  String requestsDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get requestsLastWeek => 'Last week';

  @override
  String requestsWeeksAgo(int count) {
    return '$count weeks ago';
  }

  @override
  String requestsMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String requestsYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get adminTitle => 'Administration';

  @override
  String get adminServer => 'SERVEUR';

  @override
  String get adminDashboard => 'Tableau de bord';

  @override
  String get adminDashboardSubtitle => 'Version, OS, redémarrer / arrêter';

  @override
  String get adminContent => 'CONTENU';

  @override
  String get adminLibraries => 'Bibliothèques';

  @override
  String get adminLibrariesSubtitle => 'Lister et lancer un scan';

  @override
  String get adminTasks => 'Tâches planifiées';

  @override
  String get adminTasksSubtitle => 'Voir et déclencher les tâches du serveur';

  @override
  String get adminAccounts => 'COMPTES';

  @override
  String get adminUsers => 'Utilisateurs';

  @override
  String get adminUsersSubtitle => 'Créer, éditer, supprimer';

  @override
  String get playerChapters => 'Chapitres';

  @override
  String get playerSubtitlesAudio => 'Sous-titres et audio';

  @override
  String get playerSpeed => 'Vitesse';

  @override
  String get playerNextUp => 'Épisode suivant';

  @override
  String get playerLocked => 'Verrouillé';

  @override
  String get playerUnlocked => 'Déverrouillé';

  @override
  String get playerAudioTrack => 'Piste audio';

  @override
  String get playerSubtitles => 'Sous-titres';

  @override
  String get playerSubtitlesOff => 'Désactiver';

  @override
  String get playerSpeedNormal => 'Normal';

  @override
  String playerError(String error) {
    return 'Playback error: $error';
  }

  @override
  String errorGeneric(String message) {
    return 'Erreur : $message';
  }

  @override
  String errorFailed(String message) {
    return 'Échec : $message';
  }

  @override
  String selectionCancelled(String message) {
    return 'Sélection annulée : $message';
  }

  @override
  String get successSaved => 'Enregistrer';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get deleteAllButton => 'Tout supprimer';

  @override
  String get retryButton => 'Retry';

  @override
  String get profileDisplayNameTitle => 'Nom d\'affichage';

  @override
  String get profileChangePasswordTitle => 'Changer le mot de passe';

  @override
  String get profileCurrentPassword => 'Mot de passe actuel';

  @override
  String get profileNewPassword => 'Nouveau mot de passe';

  @override
  String get profileConfirmPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get profilePasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get profileRequired => 'Requis';

  @override
  String get settingsLanguageSection => 'LANGUE';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Système';

  @override
  String get settingsLanguageFrench => 'Français';

  @override
  String get settingsLanguageEnglish => 'Anglais';

  @override
  String get settingsSectionApp => 'APPLICATION';

  @override
  String get settingsSectionContent => 'CONTENU';

  @override
  String get settingsSectionServerInfo => 'INFOS SERVEUR';

  @override
  String get navHome => 'Accueil';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navSearch => 'Recherche';

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navDownloads => 'Téléchargements';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navMenuTooltip => 'Menu';

  @override
  String syncFlushedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions synchronisées avec Jellyfin',
      one: '$count action synchronisée avec Jellyfin',
    );
    return '$_temp0';
  }

  @override
  String get seerrAvailabilityAvailable => 'Disponible';

  @override
  String get seerrAvailabilityPartial => 'Partiel';

  @override
  String get seerrAvailabilityProcessing => 'En cours';

  @override
  String get seerrAvailabilityPending => 'En attente';

  @override
  String get seerrAvailabilityUnavailable => 'Non disponible';

  @override
  String get upcomingViewAll => 'Voir tout';

  @override
  String get libraryFailedToLoad => 'Échec du chargement';

  @override
  String get libraryNoResults => 'Aucun résultat';

  @override
  String get libraryNoResultsMessage => 'Essayez un autre terme ou filtre.';

  @override
  String get detailsFailedToLoad => 'Impossible de charger';

  @override
  String get detailsItemInvalid => 'Cet élément est invalide.';

  @override
  String get detailsRetry => 'Réessayer';

  @override
  String get detailsUnsupportedItem => 'Type non supporté';

  @override
  String get detailsUnsupportedItemMessage =>
      'Ce type d\'élément n\'est pas encore pris en charge.';

  @override
  String get detailsPlay => 'Lire';

  @override
  String get detailsResume => 'Reprendre';

  @override
  String get detailsNoEpisodes => 'Aucun épisode disponible';

  @override
  String detailsResumeFrom(String time) {
    return 'depuis $time';
  }

  @override
  String get detailsEpisodes => 'Épisodes';

  @override
  String get detailsDownloadSeason => 'Télécharger la saison';

  @override
  String detailsSeason(int number) {
    return 'Saison $number';
  }

  @override
  String get detailsNoEpisodesInSeason => 'Aucun épisode dans cette saison.';

  @override
  String get detailsWatched => 'Vu';

  @override
  String get detailsPreviousEpisode => 'Précédent';

  @override
  String get detailsNextEpisode => 'Suivant';

  @override
  String get detailsMissingSeasons => 'Saisons manquantes';

  @override
  String detailsMissingSeason(int number) {
    return 'Saison $number';
  }

  @override
  String get detailsBoxSetFailedToLoad => 'Impossible de charger les éléments';

  @override
  String get detailsBoxSetEmpty => 'Collection vide';

  @override
  String get detailsBoxSetEmptyMessage =>
      'Cette collection ne contient pas encore d\'éléments.';

  @override
  String get detailsReadMore => 'Plus';

  @override
  String get detailsReadLess => 'Réduire';

  @override
  String get detailsAddToList => 'Ma liste';

  @override
  String get detailsRemoveFromList => 'Retirer';

  @override
  String get detailsMarkWatched => 'Marquer comme vu';

  @override
  String get detailsMarkUnwatched => 'Marquer comme non vu';

  @override
  String get detailsTrailer => 'Bande-annonce';

  @override
  String get detailsContinue => 'Continuer';

  @override
  String get detailsNextUp => 'Prochain';

  @override
  String detailsEpisodeOverline(String number) {
    return 'ÉPISODE $number';
  }

  @override
  String detailsBackToSeries(String series) {
    return 'Retour à $series';
  }

  @override
  String get detailsStudios => 'Studios';

  @override
  String get detailsReleaseDate => 'Sortie';

  @override
  String get detailsOfficialRating => 'Classification';

  @override
  String get detailsGenres => 'Genres';

  @override
  String get castSectionTitle => 'Distribution';

  @override
  String get seerrDiscoverTitle => 'Découvrir sur Seerr';

  @override
  String get seerrDiscoverSubtitle =>
      'Appuyez pour demander — ajouté à votre bibliothèque Jellyfin une fois approuvé';

  @override
  String seerrRequestSent(String title) {
    return 'Demande envoyée : $title';
  }

  @override
  String seerrRequestError(String error) {
    return 'Impossible d\'envoyer la demande. $error';
  }

  @override
  String get seerrRequestSentLabel => 'Demande envoyée';

  @override
  String get seerrAlreadyAvailable => 'Déjà disponible';

  @override
  String get seerrAlreadyRequested => 'Déjà demandé';

  @override
  String seerrRequestSeasons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Demander $count saisons',
      one: 'Demander 1 saison',
    );
    return '$_temp0';
  }

  @override
  String get seerrRequest => 'Demander';

  @override
  String get seerrTypeMovie => 'Film';

  @override
  String get seerrTypeSeries => 'Série';

  @override
  String get seerrSeasonsTitle => 'Saisons';

  @override
  String get seerrSelectAll => 'Tout sélectionner';

  @override
  String get seerrDeselectAll => 'Tout désélectionner';

  @override
  String get seerrBonus => 'Bonus';

  @override
  String seerrSeasonNumber(int number) {
    return 'Saison $number';
  }

  @override
  String get seerrCollectionMovies => 'Films de la collection';

  @override
  String get seerrCollectionSelectAll => 'Tout sélect.';

  @override
  String get seerrCollectionDeselectAll => 'Tout déselect.';

  @override
  String get seerrCollectionSelectAtLeastOne => 'Sélectionne au moins un film';

  @override
  String get seerrCollectionRequested => 'Demandé';

  @override
  String seerrCollectionRequestMovies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Demander $count films',
      one: 'Demander 1 film',
    );
    return '$_temp0';
  }

  @override
  String get seerrCollectionChip => 'Collection';

  @override
  String get seerrPendingLabel => 'En attente';

  @override
  String get seerrProcessingLabel => 'En cours';

  @override
  String get seerrPartialLabel => 'Partiel';

  @override
  String get offlineUnavailableTitle => 'Indisponible hors ligne';

  @override
  String get offlineUnavailableMessage =>
      'Cet élément n\'a pas été téléchargé. Reconnectez-vous pour y accéder.';

  @override
  String get offlinePlay => 'Lire';

  @override
  String get offlineMarkPlayed => 'Marquer comme vu';

  @override
  String get offlineAddFavorite => 'Ajouter aux favoris';

  @override
  String get offlineDeleteDownload => 'Supprimer le téléchargement';

  @override
  String get offlineSynopsis => 'Synopsis';

  @override
  String get offlineMarkPlayedSnack =>
      'Marqué comme vu — synchronisation à la reconnexion';

  @override
  String get offlineAddFavoriteSnack =>
      'Ajouté aux favoris — synchronisation à la reconnexion';

  @override
  String get offlineDeleteTitle => 'Supprimer le téléchargement ?';

  @override
  String get offlineDeleteMessage =>
      'Le fichier et ses images locales seront supprimés.';

  @override
  String get offlineDeleteConfirm => 'Supprimer';

  @override
  String get offlineSeriesNoEpisodesTitle => 'Aucun épisode';

  @override
  String get offlineSeriesNoEpisodesMessage =>
      'Aucun épisode de cette série n\'est téléchargé.';

  @override
  String offlineSeasonLabel(int number) {
    return 'Saison $number';
  }

  @override
  String get offlineSeasonUnknown => 'Saison ?';

  @override
  String get downloadButtonDownload => 'Télécharger';

  @override
  String get downloadButtonQueued => 'En attente — appuyer pour annuler';

  @override
  String downloadButtonDownloading(String percent) {
    return 'Téléchargement $percent% — appuyer pour pause';
  }

  @override
  String downloadButtonPaused(String percent) {
    return 'Pause $percent% — appuyer pour reprendre';
  }

  @override
  String get downloadButtonDownloaded =>
      'Téléchargé — appui long pour supprimer';

  @override
  String downloadButtonFailedSnack(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String get downloadButtonDeleteTitle => 'Supprimer le téléchargement ?';

  @override
  String get downloadButtonDeleteMessage =>
      'Le fichier local sera supprimé. Vous pouvez le retélécharger ultérieurement.';

  @override
  String get downloadButtonDeleteConfirm => 'Supprimer';

  @override
  String get downloadButtonDeleteCancel => 'Annuler';

  @override
  String downloadButtonDeleteFailedSnack(String error) {
    return 'Échec de la suppression : $error';
  }

  @override
  String get downloadTileQueued => 'En attente';

  @override
  String get downloadTileDownloaded => 'Téléchargé';

  @override
  String get downloadTileFailed => 'Échec';

  @override
  String get downloadTileCancelled => 'Annulé';

  @override
  String get downloadTilePaused => 'Pause';

  @override
  String get downloadTileTooltipDelete => 'Supprimer';

  @override
  String get downloadTileTooltipResume => 'Reprendre';

  @override
  String get downloadTileTooltipCancel => 'Annuler';

  @override
  String get downloadTileTooltipPause => 'Pause';

  @override
  String get downloadTileTooltipRemove => 'Retirer';

  @override
  String playerResumeFrom(String time) {
    return 'Reprise depuis $time';
  }

  @override
  String get playerNoChapters => 'Aucun chapitre disponible';

  @override
  String playerChapterNumber(int number) {
    return 'Chapitre $number';
  }

  @override
  String get playerLockControls => 'Verrouiller les commandes';

  @override
  String get playerPictureInPicture => 'Picture-in-Picture';

  @override
  String get playerPipUnavailableIos =>
      'Picture-in-Picture non disponible sur iOS pour cette version';

  @override
  String get playerFullscreen => 'Plein écran';

  @override
  String get playerExitFullscreen => 'Quitter le plein écran';

  @override
  String get playerDismiss => 'Ignorer';

  @override
  String get playerPlayNow => 'Lire maintenant';

  @override
  String get adminServerName => 'Nom du serveur';

  @override
  String get adminVersion => 'Version';

  @override
  String get adminProduct => 'Produit';

  @override
  String get adminServerId => 'ID serveur';

  @override
  String get adminLocalAddress => 'Adresse locale';

  @override
  String get adminRestartPending => 'Redémarrage en attente';

  @override
  String get adminRestartPendingMessage =>
      'Le serveur a une mise à jour ou un changement de configuration nécessitant un redémarrage.';

  @override
  String get adminShuttingDown => 'Arrêt en cours';

  @override
  String get adminInfoSection => 'INFORMATIONS';

  @override
  String get adminRestartButton => 'Redémarrer le serveur';

  @override
  String get adminShutdownButton => 'Arrêter le serveur';

  @override
  String get adminRestartConfirmTitle => 'Redémarrer le serveur ?';

  @override
  String get adminRestartConfirmMessage =>
      'Toutes les lectures en cours seront interrompues. Le serveur sera indisponible pendant quelques secondes.';

  @override
  String get adminRestartConfirmLabel => 'Redémarrer';

  @override
  String get adminRestartSnack => 'Redémarrage demandé.';

  @override
  String get adminShutdownConfirmTitle => 'Arrêter le serveur ?';

  @override
  String get adminShutdownConfirmMessage =>
      'Le serveur Jellyfin sera arrêté. Il faudra le redémarrer manuellement (machine, conteneur, service systemd).';

  @override
  String get adminShutdownConfirmLabel => 'Arrêter';

  @override
  String get adminShutdownSnack => 'Arrêt demandé.';

  @override
  String adminErrorPrefix(String error) {
    return 'Erreur : $error';
  }

  @override
  String adminFailurePrefix(String error) {
    return 'Échec : $error';
  }

  @override
  String get adminLibrariesEmpty => 'Aucune bibliothèque configurée.';

  @override
  String get adminLibrariesScanAll => 'Lancer un scan complet';

  @override
  String get adminLibrariesScanAllTitle => 'Lancer un scan complet ?';

  @override
  String get adminLibrariesScanAllMessage =>
      'Le serveur va analyser toutes les bibliothèques en arrière-plan. Cela peut prendre plusieurs minutes selon la taille de la médiathèque.';

  @override
  String get adminLibrariesScanAllConfirm => 'Lancer';

  @override
  String get adminLibrariesScanSnack => 'Scan lancé.';

  @override
  String adminLibrariesScanOneSnack(String name) {
    return 'Scan lancé pour « $name ».';
  }

  @override
  String get adminLibrariesTooltipScan => 'Scanner cette bibliothèque';

  @override
  String get adminTasksNoTasks => 'Aucune tâche.';

  @override
  String get adminTasksRunning => 'En cours…';

  @override
  String adminTasksRunningPercent(String percent) {
    return 'En cours… $percent%';
  }

  @override
  String get adminTasksCancelling => 'Annulation…';

  @override
  String get adminTasksNeverRun => 'Jamais exécutée';

  @override
  String adminTasksCompleted(String ago) {
    return 'Terminée $ago';
  }

  @override
  String adminTasksFailed(String ago) {
    return 'Échec $ago';
  }

  @override
  String get adminTasksTooltipStop => 'Interrompre';

  @override
  String get adminTasksTooltipStart => 'Lancer';

  @override
  String get adminTasksLastRunStatus => 'Statut';

  @override
  String get adminTasksLastRunStart => 'Début';

  @override
  String get adminTasksLastRunEnd => 'Fin';

  @override
  String get adminTasksLastRunDuration => 'Durée';

  @override
  String get adminTasksLastRunError => 'Erreur';

  @override
  String get adminUsersAdd => 'Ajouter';

  @override
  String get adminUsersEmpty => 'Aucun utilisateur.';

  @override
  String get adminUsersNeverConnected => 'Jamais connecté';

  @override
  String adminUsersSeenAt(String when) {
    return 'Vu $when';
  }

  @override
  String get adminUsersBadgeAdmin => 'Admin';

  @override
  String get adminUsersBadgeDisabled => 'Désactivé';

  @override
  String get adminUserCreateTitle => 'Nouvel utilisateur';

  @override
  String get adminUserCreateName => 'Nom d\'utilisateur';

  @override
  String get adminUserCreatePassword => 'Mot de passe';

  @override
  String get adminUserCreatePasswordHelper =>
      'Laissez vide pour aucun mot de passe initial.';

  @override
  String get adminUserCreateIsAdmin => 'Administrateur';

  @override
  String get adminUserCreateIsAdminSubtitle =>
      'Donne tous les droits sur le serveur Jellyfin.';

  @override
  String get adminUserCreateRequired => 'Requis';

  @override
  String get adminUserCreateButton => 'Créer le compte';

  @override
  String get adminUserEditTitle => 'Utilisateur';

  @override
  String get adminUserEditIdentitySection => 'IDENTITÉ';

  @override
  String get adminUserEditLastLogin => 'Dernière connexion';

  @override
  String get adminUserEditRightsSection => 'DROITS';

  @override
  String get adminUserEditIsAdmin => 'Administrateur';

  @override
  String get adminUserEditIsAdminSelfHint =>
      'Vous ne pouvez pas retirer vos propres droits.';

  @override
  String get adminUserEditIsDisabled => 'Compte désactivé';

  @override
  String get adminUserEditIsDisabledSelfHint =>
      'Vous ne pouvez pas vous désactiver vous-même.';

  @override
  String get adminUserEditLibrariesSection => 'BIBLIOTHÈQUES';

  @override
  String get adminUserEditAllFolders => 'Accès à toutes les bibliothèques';

  @override
  String get adminUserEditSaveButton => 'Enregistrer';

  @override
  String get adminUserEditSaveSnack => 'Modifications enregistrées.';

  @override
  String get adminUserEditResetPassword => 'Réinitialiser le mot de passe';

  @override
  String get adminUserEditNewPasswordTitle => 'Nouveau mot de passe';

  @override
  String get adminUserEditNewPasswordHint => 'Mot de passe';

  @override
  String get adminUserEditResetPasswordCancel => 'Annuler';

  @override
  String get adminUserEditResetPasswordConfirm => 'Réinitialiser';

  @override
  String get adminUserEditResetPasswordSnack => 'Mot de passe réinitialisé.';

  @override
  String get adminUserEditDeleteButton => 'Supprimer ce compte';

  @override
  String adminUserEditDeleteTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get adminUserEditDeleteMessage =>
      'Cette action est irréversible. Le compte, ses préférences et son historique de lecture seront supprimés du serveur.';

  @override
  String get adminUserEditDeleteConfirm => 'Supprimer';

  @override
  String get homeRailContinueWatching => 'Continuer à regarder';

  @override
  String get homeRailNextUp => 'À finir';

  @override
  String get homeHeaderJellyfin => 'Vos contenus';

  @override
  String get homeRailLatest => 'Nouveautés';

  @override
  String get homeRailLatestSubtitle => 'Ajouts récents';

  @override
  String get homeRailForYou => 'Pour vous';

  @override
  String get homeRailGems => 'Pépites';

  @override
  String get homeRailQuickPicks => 'Vite vu';

  @override
  String get homeRailBecauseYouLiked => 'Parce que vous avez aimé…';

  @override
  String get homeRailUpcomingMovies => 'Films à venir';

  @override
  String get homeRailUpcomingEpisodes => 'Épisodes à venir';

  @override
  String get homeHeaderSeer => 'À découvrir';

  @override
  String get homeRailWatchProvidersMovies => 'Disponible sur…';

  @override
  String get homeRailTrending => 'Tendance aujourd\'hui';

  @override
  String get homeRailPopularSeries => 'Séries qui cartonnent';

  @override
  String get homeRailWatchlist => 'Votre watchlist';

  @override
  String get homeRailGenreSliderMovies => 'Films par genre';

  @override
  String get homeRailGenreSliderTv => 'Séries par genre';

  @override
  String get homeRailWatchProvidersTv => 'Séries par service';

  @override
  String homeRailBecauseYouWatched(String title) {
    return 'Parce que vous avez regardé $title';
  }

  @override
  String homeRailSimilarTo(String title) {
    return 'Comme $title';
  }

  @override
  String get homeMoodComedy => 'Pour rire un bon coup';

  @override
  String get homeMoodThrills => 'Pour frissonner ce soir';

  @override
  String get homeMoodTearjerker => 'Pour pleurer un bon coup';

  @override
  String get homeMoodEscape => 'Pour s\'évader';

  @override
  String get homeMoodAcclaimed => 'Acclamés par la critique';

  @override
  String get libraryRailNewMovies => 'Nouveaux films';

  @override
  String get libraryRailNewEpisodes => 'Nouveaux épisodes';

  @override
  String get libraryRailNewSeries => 'Nouvelles séries';

  @override
  String get libraryRailNewBoxsets => 'Nouveaux coffrets';

  @override
  String get libraryRailNewAlbums => 'Nouveaux albums';

  @override
  String get libraryRailNewMusicVideos => 'Nouveaux clips';

  @override
  String get libraryRailNewBooks => 'Nouveaux livres';

  @override
  String get libraryRailNewVideos => 'Nouvelles vidéos';

  @override
  String get libraryRailNewPhotos => 'Nouvelles photos';

  @override
  String get libraryRailNewTrailers => 'Nouvelles bandes-annonces';

  @override
  String get adminSessions => 'Sessions actives';

  @override
  String get adminSessionsSubtitle => 'Clients en lecture';

  @override
  String get adminSessionsEmpty => 'Aucune session active';

  @override
  String get adminSessionsIdle => 'Inactif';

  @override
  String adminSessionsPlaying(String title) {
    return 'En lecture : $title';
  }

  @override
  String get adminSessionsBadgeActive => 'Actif';

  @override
  String get adminSessionsSendMessage => 'Envoyer un message';

  @override
  String get adminSessionsStopPlayback => 'Arrêter la lecture';

  @override
  String get adminSessionsMessageDialogTitle => 'Envoyer un message';

  @override
  String get adminSessionsMessageDialogLabel => 'Message';

  @override
  String get adminSessionsMessageDialogHint =>
      'S\'affichera sur l\'écran de l\'utilisateur';

  @override
  String get adminSessionsMessageDialogSend => 'Envoyer';

  @override
  String get adminSessionsMessageSent => 'Message envoyé';

  @override
  String get adminSessionsStopConfirmTitle => 'Arrêter la lecture ?';

  @override
  String get adminSessionsStopConfirmMessage =>
      'La lecture en cours de l\'utilisateur sera interrompue.';

  @override
  String get adminSessionsStopSnack => 'Lecture arrêtée';

  @override
  String get adminDevices => 'Appareils enregistrés';

  @override
  String get adminDevicesSubtitle => 'Clients connectés à ce serveur';

  @override
  String get adminDevicesEmpty => 'Aucun appareil enregistré';

  @override
  String get adminDevicesRename => 'Renommer';

  @override
  String get adminDevicesDelete => 'Supprimer';

  @override
  String get adminDevicesRenameDialogTitle => 'Renommer l\'appareil';

  @override
  String get adminDevicesRenameDialogLabel => 'Nom personnalisé';

  @override
  String get adminDevicesRenameDialogSave => 'Enregistrer';

  @override
  String get adminDevicesRenameSnack => 'Appareil renommé';

  @override
  String get adminDevicesDeleteConfirmTitle => 'Supprimer cet appareil ?';

  @override
  String get adminDevicesDeleteConfirmMessage =>
      'L\'utilisateur devra se reconnecter sur cet appareil.';

  @override
  String get adminDevicesDeleteSnack => 'Appareil supprimé';

  @override
  String get adminActivityLog => 'Journal d\'activité';

  @override
  String get adminActivityLogSubtitle => 'Historique des événements serveur';

  @override
  String get adminActivityEmpty => 'Aucune activité à afficher';

  @override
  String get adminActivityFiltersTooltip => 'Filtres';

  @override
  String get adminActivityFiltersTitle => 'Filtres';

  @override
  String get adminActivityFilterLast7Days => '7 derniers jours uniquement';

  @override
  String get adminActivityFilterUserOnly => 'Actions utilisateur uniquement';

  @override
  String get adminServerLogs => 'Logs du serveur';

  @override
  String get adminServerLogsSubtitle => 'Consulter les fichiers de log';

  @override
  String get adminServerLogsEmpty => 'Aucun fichier de log disponible';

  @override
  String get adminLogViewerCopy => 'Copier';

  @override
  String get adminLogViewerCopied => 'Log copié dans le presse-papiers';

  @override
  String get adminLogViewerEmpty => 'Ce fichier de log est vide';

  @override
  String get adminPlugins => 'Plugins';

  @override
  String get adminPluginsSubtitle => 'Gérer les plugins du serveur';

  @override
  String get adminPluginsEmpty =>
      'Aucun plugin n\'est installé sur ce serveur.';

  @override
  String get adminPluginsUninstall => 'Désinstaller';

  @override
  String get adminPluginsUninstallConfirmTitle => 'Désinstaller le plugin ?';

  @override
  String adminPluginsUninstallConfirmMessage(String name) {
    return 'Le plugin « $name » sera supprimé définitivement. Le serveur devra peut-être redémarrer pour que le changement prenne effet.';
  }

  @override
  String get adminPluginsUninstallConfirmLabel => 'Désinstaller';

  @override
  String get adminPluginsStatusActive => 'Actif';

  @override
  String get adminPluginsStatusDisabled => 'Désactivé';

  @override
  String get adminPluginsStatusRestart => 'Redémarrage requis';

  @override
  String get adminPluginsStatusMalfunctioned => 'Défaillant';

  @override
  String get adminPluginsStatusNotSupported => 'Non supporté';

  @override
  String get adminPluginsStatusDeleted => 'Supprimé';

  @override
  String get adminPluginsStatusSuperseded => 'Remplacé';

  @override
  String adminPluginsVersionLabel(String version) {
    return 'v$version';
  }

  @override
  String get adminPluginsEnableTooltip => 'Activer le plugin';

  @override
  String get adminPluginsDisableTooltip => 'Désactiver le plugin';

  @override
  String get adminApiKeys => 'Clés API';

  @override
  String get adminApiKeysSubtitle => 'Gérer les jetons applicatifs';

  @override
  String get adminApiKeysEmpty => 'Aucune clé API n\'a encore été créée.';

  @override
  String get adminApiKeysCreate => 'Créer';

  @override
  String get adminApiKeysCreateDialogTitle => 'Nouvelle clé API';

  @override
  String get adminApiKeysAppNameLabel => 'Nom de l\'application';

  @override
  String get adminApiKeysAppNameHelper =>
      'Aide à identifier l\'intégration qui utilise cette clé.';

  @override
  String get adminApiKeysAppNameRequired =>
      'Le nom de l\'application est requis.';

  @override
  String get adminApiKeysCreateButton => 'Créer la clé';

  @override
  String get adminApiKeysCreateSuccess =>
      'Clé API créée. Elle est désormais visible dans la liste.';

  @override
  String get adminApiKeysCancel => 'Annuler';

  @override
  String get adminApiKeysCopy => 'Copier le jeton';

  @override
  String get adminApiKeysCopied => 'Jeton copié dans le presse-papiers.';

  @override
  String get adminApiKeysRevoke => 'Révoquer';

  @override
  String get adminApiKeysRevokeConfirmTitle => 'Révoquer la clé API ?';

  @override
  String adminApiKeysRevokeConfirmMessage(String app) {
    return 'La clé pour « $app » sera révoquée immédiatement. Tout client qui l\'utilise sera déconnecté.';
  }

  @override
  String get adminApiKeysRevokeConfirmLabel => 'Révoquer';

  @override
  String adminApiKeysCreatedAt(String date) {
    return 'Créée le $date';
  }

  @override
  String get adminLibrariesAdd => 'Ajouter une bibliothèque';

  @override
  String get adminLibrariesActionsTooltip => 'Actions';

  @override
  String get adminLibrariesMenuScan => 'Scanner';

  @override
  String get adminLibrariesMenuRename => 'Renommer';

  @override
  String get adminLibrariesMenuAddPath => 'Ajouter un chemin';

  @override
  String get adminLibrariesMenuManagePaths => 'Gérer les chemins';

  @override
  String get adminLibrariesMenuDelete => 'Supprimer';

  @override
  String get adminLibraryEditTitle => 'Nouvelle bibliothèque';

  @override
  String get adminLibraryNameLabel => 'Nom';

  @override
  String get adminLibraryNameRequired => 'Le nom est requis';

  @override
  String get adminLibraryTypeLabel => 'Type de collection';

  @override
  String get adminLibraryPathsLabel => 'Dossiers';

  @override
  String get adminLibraryNoPaths => 'Aucun dossier ajouté.';

  @override
  String get adminLibraryAddPath => 'Ajouter un chemin';

  @override
  String get adminLibraryRemovePath => 'Retirer le chemin';

  @override
  String get adminLibraryRefreshAfter =>
      'Scanner la bibliothèque après création';

  @override
  String get adminLibraryRefreshAfterSubtitle =>
      'Lance un scan initial une fois la bibliothèque créée.';

  @override
  String get adminLibraryCreateButton => 'Créer la bibliothèque';

  @override
  String get adminLibraryPathsRequired =>
      'Ajoutez au moins un dossier avant de créer la bibliothèque.';

  @override
  String get adminLibraryCreatedSnack => 'Bibliothèque créée.';

  @override
  String get adminLibraryTypeMovies => 'Films';

  @override
  String get adminLibraryTypeTvshows => 'Séries';

  @override
  String get adminLibraryTypeMusic => 'Musique';

  @override
  String get adminLibraryTypeMusicvideos => 'Clips musicaux';

  @override
  String get adminLibraryTypeHomevideos => 'Vidéos personnelles';

  @override
  String get adminLibraryTypeBoxsets => 'Collections';

  @override
  String get adminLibraryTypeBooks => 'Livres';

  @override
  String get adminLibraryTypeMixed => 'Mixte';

  @override
  String get adminLibraryRenameTitle => 'Renommer la bibliothèque';

  @override
  String get adminLibraryRenameCancel => 'Annuler';

  @override
  String get adminLibraryRenameConfirm => 'Renommer';

  @override
  String adminLibraryRenamedSnack(String name) {
    return 'Bibliothèque renommée en $name.';
  }

  @override
  String get adminLibraryDeleteTitle => 'Supprimer la bibliothèque';

  @override
  String adminLibraryDeleteMessage(String name) {
    return 'Supprimer définitivement la bibliothèque « $name » ? Les fichiers sur le disque sont conservés.';
  }

  @override
  String get adminLibraryDeleteConfirm => 'Supprimer';

  @override
  String adminLibraryDeletedSnack(String name) {
    return 'Bibliothèque « $name » supprimée.';
  }

  @override
  String adminLibraryPathAddedSnack(String path) {
    return 'Chemin ajouté : $path';
  }

  @override
  String adminLibraryPathRemovedSnack(String path) {
    return 'Chemin retiré : $path';
  }

  @override
  String adminLibraryManagePathsTitle(String name) {
    return 'Chemins de « $name »';
  }

  @override
  String get adminLibraryRemovePathTitle => 'Retirer le chemin';

  @override
  String adminLibraryRemovePathMessage(String path) {
    return 'Retirer « $path » de cette bibliothèque ? Les fichiers sur le disque sont conservés.';
  }

  @override
  String get adminLibraryRemovePathConfirm => 'Retirer';

  @override
  String get adminLibraryPathPickerTitle => 'Choisir un dossier';

  @override
  String get adminLibraryPathPickerClose => 'Fermer';

  @override
  String get adminLibraryPathPickerUp => 'Remonter';

  @override
  String get adminLibraryPathPickerRoot => 'Disques';

  @override
  String get adminLibraryPathPickerValidate => 'Utiliser ce dossier';

  @override
  String get adminLibraryPathPickerEmpty => 'Ce dossier est vide.';

  @override
  String get adminLibraryPathPickerSelect => 'Sélectionner';

  @override
  String adminLibraryPathValidationWarning(String error) {
    return 'Avertissement de validation : $error';
  }

  @override
  String get adminServerConfig => 'Configuration serveur';

  @override
  String get adminServerConfigSubtitle => 'Identité, chemins, comportement';

  @override
  String get adminServerConfigIdentitySection => 'IDENTITÉ';

  @override
  String get adminServerConfigServerName => 'Nom du serveur';

  @override
  String get adminServerConfigUiCulture => 'Langue de l\'interface serveur';

  @override
  String get adminServerConfigPathsSection => 'CHEMINS';

  @override
  String get adminServerConfigCachePath => 'Chemin du cache';

  @override
  String get adminServerConfigMetadataPath => 'Chemin des métadonnées';

  @override
  String get adminServerConfigStartupWizard => 'Assistant d\'installation';

  @override
  String get adminServerConfigStartupWizardDone => 'Terminé';

  @override
  String get adminServerConfigStartupWizardPending => 'En attente';

  @override
  String get adminServerConfigBehaviorSection => 'COMPORTEMENT';

  @override
  String get adminServerConfigQuickConnect => 'Quick Connect';

  @override
  String get adminServerConfigEnableMetrics => 'Métriques Prometheus';

  @override
  String get adminServerConfigEnableMetricsHint =>
      'Expose les métriques sur /metrics';

  @override
  String get adminServerConfigNormalizedIds => 'IDs normalisés (item-by-name)';

  @override
  String get adminServerConfigNormalizedIdsHint =>
      'Recommandé sur les nouveaux serveurs';

  @override
  String get adminServerConfigDiagnosticsSection => 'DIAGNOSTICS';

  @override
  String get adminServerConfigLogRetention => 'Rétention des logs (jours)';

  @override
  String get adminServerConfigSlowResponse => 'Avertir si réponse lente';

  @override
  String get adminServerConfigSlowResponseThreshold =>
      'Seuil de réponse lente (ms)';

  @override
  String get adminServerConfigCorsSection => 'CORS';

  @override
  String get adminServerConfigCorsHint =>
      'Hôtes autorisés à appeler l\'API depuis le navigateur. Utilisez * pour tout autoriser.';

  @override
  String get adminServerConfigCorsEmpty => 'Aucun hôte CORS configuré.';

  @override
  String get adminServerConfigCorsAdd => 'Ajouter un hôte';

  @override
  String get adminServerConfigCorsAddTitle => 'Ajouter un hôte CORS';

  @override
  String get adminServerConfigCorsAddHint => 'https://exemple.com';

  @override
  String get adminServerConfigCorsAddCancel => 'Annuler';

  @override
  String get adminServerConfigCorsAddConfirm => 'Ajouter';

  @override
  String get adminServerConfigSaveButton => 'Enregistrer la configuration';

  @override
  String get adminServerConfigSaveSnack => 'Configuration enregistrée';

  @override
  String get adminBranding => 'Identité visuelle';

  @override
  String get adminBrandingSubtitle =>
      'Mention de connexion, CSS personnalisé, splashscreen';

  @override
  String get adminBrandingMessagesSection => 'MESSAGES';

  @override
  String get adminBrandingLoginDisclaimer => 'Mention de connexion';

  @override
  String get adminBrandingLoginDisclaimerHint =>
      'Affichée sur l\'écran de connexion';

  @override
  String get adminBrandingAppearanceSection => 'APPARENCE';

  @override
  String get adminBrandingSplashscreenEnabled =>
      'Activer l\'écran de démarrage';

  @override
  String get adminBrandingSplashscreenEnabledHint =>
      'Utiliser un écran de démarrage personnalisé sur les clients compatibles';

  @override
  String get adminBrandingCustomCss => 'CSS personnalisé';

  @override
  String get adminBrandingCustomCssHint => 'Injecté dans le client web';

  @override
  String get adminBrandingSaveButton => 'Enregistrer l\'identité';

  @override
  String get adminBrandingSaveSnack => 'Identité enregistrée';

  @override
  String get adminBackup => 'Sauvegarde & restauration';

  @override
  String get adminBackupSubtitle =>
      'Créer et restaurer les sauvegardes du serveur';

  @override
  String get adminBackupListSection => 'SAUVEGARDES DISPONIBLES';

  @override
  String get adminBackupEmpty => 'Aucune sauvegarde trouvée.';

  @override
  String get adminBackupCreateSectionTitle => 'Créer une sauvegarde';

  @override
  String get adminBackupCreateHint =>
      'Archive la base du serveur et les contenus sélectionnés. L\'opération peut prendre plusieurs minutes.';

  @override
  String get adminBackupCreate => 'Créer une sauvegarde maintenant';

  @override
  String get adminBackupCreating => 'Sauvegarde en cours…';

  @override
  String get adminBackupCreateSnack => 'Sauvegarde créée';

  @override
  String adminBackupVersionPrefix(String version) {
    return 'Serveur v$version';
  }

  @override
  String get adminBackupContentMetadata => 'Métadonnées';

  @override
  String get adminBackupContentDatabase => 'Base de données';

  @override
  String get adminBackupContentSubtitles => 'Sous-titres';

  @override
  String get adminBackupContentTrickplay => 'Trickplay';

  @override
  String get adminBackupRestoreTooltip => 'Restaurer cette sauvegarde';

  @override
  String get adminBackupRestoreConfirm1Title => 'Restaurer cette sauvegarde ?';

  @override
  String get adminBackupRestoreConfirm1Message =>
      'Le serveur va redémarrer et revenir à la sauvegarde sélectionnée. Toutes les modifications depuis cette sauvegarde seront perdues.';

  @override
  String get adminBackupRestoreConfirm1Confirm => 'Continuer';

  @override
  String get adminBackupRestoreConfirm2Title => 'Vraiment confirmer ?';

  @override
  String get adminBackupRestoreConfirm2Message =>
      'Cette action est irréversible. Le serveur sera indisponible pendant quelques minutes.';

  @override
  String get adminBackupRestoreConfirm2Confirm => 'Oui, restaurer';

  @override
  String get adminBackupRestoreSnack =>
      'Restauration lancée ; le serveur redémarre…';

  @override
  String get castButton => 'Diffuser';

  @override
  String get castSheetTitle => 'Diffuser vers';

  @override
  String get castSheetSearching => 'Recherche d\'appareils…';

  @override
  String get castSheetEmpty =>
      'Aucun appareil Chromecast trouvé sur votre réseau.';

  @override
  String castSheetConnectedTo(String device) {
    return 'Connecté à $device';
  }

  @override
  String get castSheetDisconnect => 'Déconnecter';

  @override
  String castConnecting(String device) {
    return 'Connexion à $device…';
  }

  @override
  String castConnectionFailed(String device) {
    return 'Impossible de se connecter à $device';
  }

  @override
  String get castMiniPlayerStop => 'Arrêter la diffusion';

  @override
  String get castNowPlayingTitle => 'Diffusion en cours';

  @override
  String get castNowPlayingVolume => 'Volume du récepteur';

  @override
  String get castOfflineUnsupported =>
      'Diffusion indisponible pour les fichiers téléchargés';

  @override
  String castStartedSnack(String device) {
    return 'Diffusion sur $device';
  }

  @override
  String get playerUnlockControls => 'Déverrouiller les commandes';

  @override
  String get playerBack => 'Retour';

  @override
  String get playerPlay => 'Lecture';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerSeekBack => 'Reculer de 10 secondes';

  @override
  String get playerSeekForward => 'Avancer de 10 secondes';

  @override
  String get commonPlay => 'Lecture';

  @override
  String get commonErrorTitle => 'Une erreur est survenue';

  @override
  String get commonErrorRetry => 'Réessayer';

  @override
  String get commonEmptyTitle => 'Rien à afficher';

  @override
  String get drawerExpandTooltip => 'Étendre le menu';

  @override
  String get drawerCollapseTooltip => 'Réduire le menu';

  @override
  String get drawerHideAction => 'Masquer la navigation';

  @override
  String get drawerShowTooltip => 'Afficher la navigation';

  @override
  String get syncPlayTabLabel => 'Visionnage groupé';

  @override
  String get syncPlayCreateButton => 'Créer un groupe';

  @override
  String get syncPlayCreateDialogTitle => 'Nouveau groupe';

  @override
  String get syncPlayCreateGroupNameLabel => 'Nom du groupe';

  @override
  String get syncPlayCreateGroupNameHint => 'Ex : Soirée ciné';

  @override
  String get syncPlayCreateGroupNameRequired =>
      'Le nom est obligatoire (1–50 caractères)';

  @override
  String syncPlayMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get syncPlayLeaveButton => 'Quitter le groupe';

  @override
  String get syncPlayLeaveConfirmTitle => 'Quitter le groupe ?';

  @override
  String get syncPlayLeaveConfirmBody =>
      'Vous serez déconnecté de la session de visionnage groupé.';

  @override
  String get syncPlayJoinButton => 'Rejoindre';

  @override
  String get syncPlayJoinError => 'Impossible de rejoindre le groupe';

  @override
  String get syncPlayCreateError => 'Impossible de créer le groupe';

  @override
  String get syncPlayErrLibraryDenied =>
      'Accès à la bibliothèque refusé par le groupe';

  @override
  String get syncPlayErrGroupGone => 'Ce groupe n\'existe plus';

  @override
  String get syncPlayErrNotInGroup => 'Vous n\'êtes plus membre d\'un groupe';

  @override
  String get syncPlayErrTransport => 'Erreur de connexion — réessayez';

  @override
  String get syncPlayIndicatorTooltip => 'Visionnage groupé actif';

  @override
  String get syncPlayCastConflictTooltip =>
      'Quittez Cast pour utiliser le visionnage groupé';

  @override
  String get syncPlayPanelTitle => 'Groupe';

  @override
  String get syncPlayPanelMembersHeading => 'Membres';

  @override
  String get syncPlayPanelQueueHeading => 'File d\'attente';

  @override
  String get syncPlayPanelControlsRepeat => 'Répétition';

  @override
  String get syncPlayPanelControlsShuffle => 'Aléatoire';

  @override
  String get syncPlayStateIdle => 'En attente';

  @override
  String get syncPlayStatePaused => 'En pause';

  @override
  String get syncPlayStatePlaying => 'En lecture';

  @override
  String get syncPlayStateWaiting => 'Chargement…';

  @override
  String get syncPlayJoinDialogTitle => 'Rejoindre un groupe';

  @override
  String get syncPlayCreateGroupSubtitle => 'Créer un nouveau groupe';

  @override
  String get personPageRole => 'Acteur';

  @override
  String personPageTitleCount(String role, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString titres',
      one: '1 titre',
    );
    return '$role · $_temp0';
  }

  @override
  String get personFilterAll => 'Tout';

  @override
  String get personFilterMovies => 'Films';

  @override
  String get personFilterSeries => 'Séries';

  @override
  String get personFilterAllSemantics => 'Filtrer par tout';

  @override
  String get personFilterMoviesSemantics => 'Filtrer par films';

  @override
  String get personFilterSeriesSemantics => 'Filtrer par séries';

  @override
  String get personFilmographyEmptyTitle => 'Aucun titre disponible';

  @override
  String get personFilmographyEmpty =>
      'Nous n\'avons trouvé aucun film ou série associé à cet artiste.';

  @override
  String personPhotoSemantics(String name) {
    return 'Photo de $name';
  }

  @override
  String get searchPersonsSection => 'Personnes';

  @override
  String get searchPersonsTitle => 'Acteurs et équipe';
}
