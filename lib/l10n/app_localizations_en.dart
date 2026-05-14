// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Jellyfish';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccount => 'ACCOUNT';

  @override
  String get settingsMyProfile => 'My profile';

  @override
  String get settingsMyProfileSubtitle => 'Display name, password, photo';

  @override
  String get settingsServer => 'Server';

  @override
  String get settingsUser => 'User';

  @override
  String get settingsSwitchAccount => 'Switch account';

  @override
  String get settingsSwitchAccountSubtitleSingle => 'Add an account or server';

  @override
  String settingsSwitchAccountSubtitleMultiple(int count) {
    return '$count accounts saved';
  }

  @override
  String get settingsLogout => 'Sign out of this account';

  @override
  String get settingsDownloads => 'DOWNLOADS';

  @override
  String get settingsDownloadsTitle => 'Downloads';

  @override
  String get settingsDownloadsSubtitle => 'Wi-Fi only, background, storage';

  @override
  String get settingsDiscovery => 'DISCOVERY';

  @override
  String get settingsRequests => 'My requests';

  @override
  String get settingsRequestsSubtitle =>
      'Track movies and shows requested via Jellyseerr.';

  @override
  String get settingsPlayback => 'PLAYBACK';

  @override
  String get settingsPlaybackTitle => 'Playback';

  @override
  String get settingsAdmin => 'ADMINISTRATION';

  @override
  String get settingsAdminTitle => 'Administration';

  @override
  String get settingsAdminSubtitle => 'Server, users, libraries, tasks';

  @override
  String get settingsAbout => 'ABOUT';

  @override
  String get settingsAboutTitle => 'About';

  @override
  String get playbackLanguages => 'LANGUAGES';

  @override
  String get playbackAudioLanguage => 'Preferred audio language';

  @override
  String get playbackSubtitleLanguage => 'Preferred subtitle language';

  @override
  String get playbackSubtitleMode => 'Subtitle mode';

  @override
  String get playbackBehavior => 'BEHAVIOR';

  @override
  String get playbackAutoNextEpisode => 'Auto-play next episode';

  @override
  String get playbackDefaultAudioTrack => 'Play default audio track';

  @override
  String get playbackDefaultAudioTrackDescription =>
      'Automatically select the file\'s default audio track instead of your preferred language.';

  @override
  String get playbackRememberAudioSelections => 'Remember audio choices';

  @override
  String get playbackRememberSubtitleSelections => 'Remember subtitle choices';

  @override
  String get playbackShowMissingEpisodes => 'Show missing episodes';

  @override
  String get playbackAudioLanguageUpdated => 'Audio language updated.';

  @override
  String get playbackSubtitleLanguageUpdated => 'Subtitle language updated.';

  @override
  String get playbackSubtitleModeUpdated => 'Subtitle mode updated.';

  @override
  String get playbackAutoPlayEnabled => 'Auto-play enabled.';

  @override
  String get playbackAutoPlayDisabled => 'Auto-play disabled.';

  @override
  String get playbackPreferenceSaved => 'Preference saved.';

  @override
  String get playbackLanguageNone => 'None';

  @override
  String get playbackLanguageSearch => 'Search for a language';

  @override
  String get playbackSubtitleModeDefault => 'Default';

  @override
  String get playbackSubtitleModeDefaultDescription =>
      'Follow the file\'s setting';

  @override
  String get playbackSubtitleModeAlways => 'Always';

  @override
  String get playbackSubtitleModeAlwaysDescription =>
      'Show when a track matches your preferred language';

  @override
  String get playbackSubtitleModeOnlyForced => 'Forced only';

  @override
  String get playbackSubtitleModeOnlyForcedDescription =>
      'Only forced subtitles';

  @override
  String get playbackSubtitleModeSmart => 'Smart';

  @override
  String get playbackSubtitleModeSmartDescription =>
      'When audio is not in your preferred language';

  @override
  String get playbackSubtitleModeNone => 'None';

  @override
  String get playbackSubtitleModeNoneDescription => 'Never show';

  @override
  String get downloadsSettingsTitle => 'Downloads';

  @override
  String get downloadsOptions => 'OPTIONS';

  @override
  String get downloadsBackgroundEnabled => 'Background downloads';

  @override
  String get downloadsBackgroundEnabledDescription =>
      'Continue downloads when the app is closed.';

  @override
  String get downloadsWifiOnly => 'Wi-Fi only';

  @override
  String get downloadsWifiOnlyDescription =>
      'Block new downloads on mobile networks.';

  @override
  String get downloadsAutoDeleteWatched => 'Delete after watching';

  @override
  String get downloadsAutoDeleteWatchedDescription =>
      'Remove downloaded episodes after playback is finished.';

  @override
  String get downloadsStorage => 'STORAGE';

  @override
  String get downloadsStorageUsed => 'Space used';

  @override
  String get downloadsDeleteAll => 'Delete all';

  @override
  String get downloadsDeleteAllConfirm => 'Delete all downloads?';

  @override
  String get downloadsDeleteAllConfirmMessage =>
      'All downloaded files and their local images will be deleted. This action cannot be undone.';

  @override
  String get aboutAppName => 'Jellyfish';

  @override
  String get aboutAppSubtitle => 'Jellyfin + Seerr client';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutLicenses => 'Open-source licenses';

  @override
  String get profileDisplayName => 'Display name';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileDeletePhoto => 'Delete';

  @override
  String get profileDisplayNameUpdated => 'Display name updated.';

  @override
  String get profilePasswordChanged => 'Password changed.';

  @override
  String get profilePasswordIncorrect => 'Current password is incorrect.';

  @override
  String get profilePhotoUpdated => 'Profile photo updated.';

  @override
  String get profilePhotoDeleted => 'Profile photo deleted.';

  @override
  String get homeNoMoreContent => 'You\'ve seen it all';

  @override
  String get homeSearch => 'Search';

  @override
  String get homeOffline => 'Offline';

  @override
  String get homeOfflineNoDownloads => 'No downloads';

  @override
  String get homeOfflineNoDownloadsMessage =>
      'You\'re offline and no items are available on this device.';

  @override
  String get homeOfflineBanner => 'Offline mode — your local library';

  @override
  String get homeOfflineSeriesDownloaded => 'Downloaded series';

  @override
  String get homeOfflineMoviesDownloaded => 'Downloaded movies';

  @override
  String homeOfflineEpisodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0';
  }

  @override
  String get homePluginMissing =>
      'The Jellyfish.Bridge plugin is not installed on your Jellyfin server. Discover, Requests, and Calendar will remain empty. Ask your admin to install it.';

  @override
  String get homeNoJellyseerrAccount =>
      'Your Seerr account has not been activated. Ask your admin to open Seerr → Settings → Users → Import Jellyfin Users.';

  @override
  String get homeJellyseerrNotConfigured =>
      'Jellyseerr is not configured in the Jellyfish.Bridge plugin.';

  @override
  String get homeRadarrNotConfigured =>
      'Radarr is not configured in the Jellyfish.Bridge plugin.';

  @override
  String get homeSonarrNotConfigured =>
      'Sonarr is not configured in the Jellyfish.Bridge plugin.';

  @override
  String get homeUpstreamUnreachable =>
      'The external service is unreachable. Try again in a few moments.';

  @override
  String get homeUpstreamTimeout =>
      'The external service did not respond in time.';

  @override
  String get homePluginMissingError =>
      'The Jellyfish.Bridge plugin is not installed on your server.';

  @override
  String homeOtherError(int statusCode) {
    return 'An error occurred (HTTP $statusCode).';
  }

  @override
  String get libraryTitle => 'Library';

  @override
  String get librarySearch => 'Search library…';

  @override
  String get libraryAll => 'All';

  @override
  String get searchTitle => 'Search for a movie or show…';

  @override
  String get searchClear => 'Clear';

  @override
  String get searchIntroTitle => 'Search for a title';

  @override
  String get searchIntroWithSeerr =>
      'Search covers your Jellyfin library and lets you request new titles via Seerr.';

  @override
  String get searchIntroWithoutSeerr => 'Search covers your Jellyfin library.';

  @override
  String get searchIntroJellyfin => 'Jellyfin library';

  @override
  String get searchIntroJellyfinDescription =>
      'Movies and shows already available to you.';

  @override
  String get searchIntroSeerr => 'Request via Seerr';

  @override
  String get searchIntroSeerrDescription =>
      'Find a new title and submit a request to Seerr.';

  @override
  String get searchNoResults => 'No results';

  @override
  String searchNoResultsMessage(String query) {
    return 'No titles match \"$query\".';
  }

  @override
  String get searchJellyfinSection => '01 ── LIBRARY';

  @override
  String get searchJellyfinTitle => 'In your library';

  @override
  String get searchJellyfinLoadError => 'Failed to load Jellyfin';

  @override
  String get searchJellyfinEmpty => 'Nothing matches here.';

  @override
  String get searchSeerrSection => '02 ── SEERR';

  @override
  String get searchSeerrTitle => 'Request via Seerr';

  @override
  String get searchSeerrLoadError => 'Failed to reach Seerr';

  @override
  String get searchSeerrEmpty => 'Nothing to request for this query.';

  @override
  String get searchSeerrCollection => 'COLLECTION';

  @override
  String get offlineSearchTitle => 'Search (offline)';

  @override
  String get offlineSearchHint => 'Filter downloads…';

  @override
  String get offlineSearchNoResults => 'No results';

  @override
  String get offlineSearchNoDownloads => 'No downloads';

  @override
  String get offlineSearchNoDownloadsMessage =>
      'Download movies or shows to access them offline.';

  @override
  String offlineSearchNoResultsMessage(String query) {
    return 'No downloads match \"$query\".';
  }

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadsSettings => 'Download settings';

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
  String get accountsTitle => 'Accounts';

  @override
  String get accountsMyServer => 'MY SERVER';

  @override
  String accountsMyServers(int count) {
    return 'MY SERVERS · $count';
  }

  @override
  String get accountsAddUser => 'Add a user on this server';

  @override
  String get accountsOtherServer => 'OTHER SERVER';

  @override
  String get accountsAddServer => 'Add a Jellyfin server';

  @override
  String get accountsHint => 'Tap an account to switch. Long-press to delete.';

  @override
  String get accountsEmpty => 'No accounts saved';

  @override
  String get accountsEmptyMessage => 'Add a Jellyfin server to get started.';

  @override
  String get accountsForgetServer => 'Forget this server';

  @override
  String get accountsRemove => 'Delete';

  @override
  String get accountsActive => 'Active';

  @override
  String accountsForgetServerTitle(String serverName) {
    return 'Forget $serverName?';
  }

  @override
  String accountsForgetServerMessage(int count) {
    return 'The $count associated account(s) will be removed from this device.';
  }

  @override
  String get accountsForget => 'Forget';

  @override
  String get accountsDeleteTitle => 'Delete this account?';

  @override
  String accountsDeleteMessage(String userName, String serverName) {
    return '$userName on $serverName will be removed from this device.';
  }

  @override
  String get accountsDelete => 'Delete';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarAllTypes => 'All';

  @override
  String get calendarMovies => 'Movies';

  @override
  String get calendarEpisodes => 'Episodes';

  @override
  String get calendar30Days => '30 days';

  @override
  String get calendar90Days => '3 months';

  @override
  String get calendar365Days => '1 year';

  @override
  String get calendarMissing => 'Missing';

  @override
  String get calendarNoData => 'Failed to reach server.';

  @override
  String get calendarNoPlugin =>
      'The Jellyfish.Bridge plugin is not installed on your Jellyfin server. Ask your admin to install it.';

  @override
  String get calendarNoServices =>
      'Neither Radarr nor Sonarr are configured in the plugin. Ask your admin to connect at least one of them.';

  @override
  String get calendarLoadError => 'Failed to load calendar.';

  @override
  String get calendarNoItems =>
      'Nothing on the horizon for the selected period.';

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
  String get requestsOfflineUnavailable => 'Unavailable offline';

  @override
  String get requestsOfflineUnavailableMessage =>
      'Seerr requests require an active network connection.';

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
  String get adminServer => 'SERVER';

  @override
  String get adminDashboard => 'Dashboard';

  @override
  String get adminDashboardSubtitle => 'Version, OS, restart / stop';

  @override
  String get adminContent => 'CONTENT';

  @override
  String get adminLibraries => 'Libraries';

  @override
  String get adminLibrariesSubtitle => 'List and run scans';

  @override
  String get adminTasks => 'Scheduled tasks';

  @override
  String get adminTasksSubtitle => 'View and trigger server tasks';

  @override
  String get adminAccounts => 'ACCOUNTS';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminUsersSubtitle => 'Create, edit, delete';

  @override
  String get playerChapters => 'Chapters';

  @override
  String get playerSubtitlesAudio => 'Subtitles and audio';

  @override
  String get playerSpeed => 'Speed';

  @override
  String get playerNextUp => 'Next episode';

  @override
  String get playerLocked => 'Locked';

  @override
  String get playerUnlocked => 'Unlocked';

  @override
  String get playerAudioTrack => 'Audio track';

  @override
  String get playerSubtitles => 'Subtitles';

  @override
  String get playerSubtitlesOff => 'Off';

  @override
  String get playerSpeedNormal => 'Normal';

  @override
  String playerError(String error) {
    return 'Playback error: $error';
  }

  @override
  String errorGeneric(String message) {
    return 'Error: $message';
  }

  @override
  String errorFailed(String message) {
    return 'Failed: $message';
  }

  @override
  String selectionCancelled(String message) {
    return 'Selection cancelled: $message';
  }

  @override
  String get successSaved => 'Save';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String get deleteAllButton => 'Delete all';

  @override
  String get retryButton => 'Retry';

  @override
  String get profileDisplayNameTitle => 'Display name';

  @override
  String get profileChangePasswordTitle => 'Change password';

  @override
  String get profileCurrentPassword => 'Current password';

  @override
  String get profileNewPassword => 'New password';

  @override
  String get profileConfirmPassword => 'Confirm new password';

  @override
  String get profilePasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get profileRequired => 'Required';

  @override
  String get settingsLanguageSection => 'LANGUAGE';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsLanguageFrench => 'French';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsSectionApp => 'APP';

  @override
  String get settingsSectionContent => 'CONTENT';

  @override
  String get settingsSectionServerInfo => 'SERVER INFO';

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSearch => 'Search';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navDownloads => 'Downloads';

  @override
  String get navSettings => 'Settings';

  @override
  String get navMenuTooltip => 'Menu';

  @override
  String syncFlushedSnack(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions synced with Jellyfin',
      one: '$count action synced with Jellyfin',
    );
    return '$_temp0';
  }

  @override
  String get seerrAvailabilityAvailable => 'Available';

  @override
  String get seerrAvailabilityPartial => 'Partial';

  @override
  String get seerrAvailabilityProcessing => 'Processing';

  @override
  String get seerrAvailabilityPending => 'Pending';

  @override
  String get seerrAvailabilityUnavailable => 'Unavailable';

  @override
  String get upcomingViewAll => 'View all';

  @override
  String get libraryFailedToLoad => 'Failed to load library';

  @override
  String get libraryNoResults => 'No results';

  @override
  String get libraryNoResultsMessage =>
      'Try a different search term or filter.';

  @override
  String get detailsFailedToLoad => 'Failed to load';

  @override
  String get detailsItemInvalid => 'This item is invalid.';

  @override
  String get detailsRetry => 'Retry';

  @override
  String get detailsUnsupportedItem => 'Unsupported item';

  @override
  String get detailsUnsupportedItemMessage =>
      'This item type is not supported yet.';

  @override
  String get detailsPlay => 'Play';

  @override
  String get detailsResume => 'Resume';

  @override
  String get detailsNoEpisodes => 'No episodes available';

  @override
  String detailsResumeFrom(String time) {
    return 'from $time';
  }

  @override
  String get detailsEpisodes => 'Episodes';

  @override
  String get detailsDownloadSeason => 'Download season';

  @override
  String detailsSeason(int number) {
    return 'Season $number';
  }

  @override
  String get detailsNoEpisodesInSeason => 'No episodes in this season.';

  @override
  String get detailsWatched => 'Watched';

  @override
  String get detailsPreviousEpisode => 'Previous';

  @override
  String get detailsNextEpisode => 'Next';

  @override
  String get detailsMissingSeasons => 'Missing seasons';

  @override
  String detailsMissingSeason(int number) {
    return 'Season $number';
  }

  @override
  String get detailsBoxSetFailedToLoad => 'Failed to load items';

  @override
  String get detailsBoxSetEmpty => 'Empty collection';

  @override
  String get detailsBoxSetEmptyMessage => 'This collection has no items yet.';

  @override
  String get castSectionTitle => 'Cast';

  @override
  String get seerrDiscoverTitle => 'Discover on Seerr';

  @override
  String get seerrDiscoverSubtitle =>
      'Tap to request — added to your Jellyfin library once approved';

  @override
  String seerrRequestSent(String title) {
    return 'Request sent: $title';
  }

  @override
  String seerrRequestError(String error) {
    return 'Could not send request. $error';
  }

  @override
  String get seerrRequestSentLabel => 'Request sent';

  @override
  String get seerrAlreadyAvailable => 'Already available';

  @override
  String get seerrAlreadyRequested => 'Already requested';

  @override
  String seerrRequestSeasons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Request $count seasons',
      one: 'Request 1 season',
    );
    return '$_temp0';
  }

  @override
  String get seerrRequest => 'Request';

  @override
  String get seerrTypeMovie => 'Movie';

  @override
  String get seerrTypeSeries => 'Series';

  @override
  String get seerrSeasonsTitle => 'Seasons';

  @override
  String get seerrSelectAll => 'Select all';

  @override
  String get seerrDeselectAll => 'Deselect all';

  @override
  String get seerrBonus => 'Specials';

  @override
  String seerrSeasonNumber(int number) {
    return 'Season $number';
  }

  @override
  String get seerrCollectionMovies => 'Collection movies';

  @override
  String get seerrCollectionSelectAll => 'Select all';

  @override
  String get seerrCollectionDeselectAll => 'Deselect all';

  @override
  String get seerrCollectionSelectAtLeastOne => 'Select at least one movie';

  @override
  String get seerrCollectionRequested => 'Requested';

  @override
  String seerrCollectionRequestMovies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Request $count movies',
      one: 'Request 1 movie',
    );
    return '$_temp0';
  }

  @override
  String get seerrCollectionChip => 'Collection';

  @override
  String get seerrPendingLabel => 'Pending';

  @override
  String get seerrProcessingLabel => 'Processing';

  @override
  String get seerrPartialLabel => 'Partial';

  @override
  String get offlineUnavailableTitle => 'Unavailable offline';

  @override
  String get offlineUnavailableMessage =>
      'This item has not been downloaded. Reconnect to access it.';

  @override
  String get offlinePlay => 'Play';

  @override
  String get offlineMarkPlayed => 'Mark as watched';

  @override
  String get offlineAddFavorite => 'Add to favourites';

  @override
  String get offlineDeleteDownload => 'Delete download';

  @override
  String get offlineSynopsis => 'Synopsis';

  @override
  String get offlineMarkPlayedSnack =>
      'Marked as watched — will sync on reconnect';

  @override
  String get offlineAddFavoriteSnack =>
      'Added to favourites — will sync on reconnect';

  @override
  String get offlineDeleteTitle => 'Delete download?';

  @override
  String get offlineDeleteMessage =>
      'The file and its local images will be removed.';

  @override
  String get offlineDeleteConfirm => 'Delete';

  @override
  String get offlineSeriesNoEpisodesTitle => 'No episodes';

  @override
  String get offlineSeriesNoEpisodesMessage =>
      'No episodes from this series have been downloaded.';

  @override
  String offlineSeasonLabel(int number) {
    return 'Season $number';
  }

  @override
  String get offlineSeasonUnknown => 'Season ?';

  @override
  String get downloadButtonDownload => 'Download';

  @override
  String get downloadButtonQueued => 'Queued — tap to cancel';

  @override
  String downloadButtonDownloading(String percent) {
    return 'Downloading $percent% — tap to pause';
  }

  @override
  String downloadButtonPaused(String percent) {
    return 'Paused $percent% — tap to resume';
  }

  @override
  String get downloadButtonDownloaded => 'Downloaded — long-press to delete';

  @override
  String downloadButtonFailedSnack(String error) {
    return 'Download failed: $error';
  }

  @override
  String get downloadButtonDeleteTitle => 'Delete download?';

  @override
  String get downloadButtonDeleteMessage =>
      'The local file will be removed. You can download it again later.';

  @override
  String get downloadButtonDeleteConfirm => 'Delete';

  @override
  String get downloadButtonDeleteCancel => 'Cancel';

  @override
  String downloadButtonDeleteFailedSnack(String error) {
    return 'Delete failed: $error';
  }

  @override
  String get downloadTileQueued => 'Queued';

  @override
  String get downloadTileDownloaded => 'Downloaded';

  @override
  String get downloadTileFailed => 'Failed';

  @override
  String get downloadTileCancelled => 'Cancelled';

  @override
  String get downloadTilePaused => 'Paused';

  @override
  String get downloadTileTooltipDelete => 'Delete';

  @override
  String get downloadTileTooltipResume => 'Resume';

  @override
  String get downloadTileTooltipCancel => 'Cancel';

  @override
  String get downloadTileTooltipPause => 'Pause';

  @override
  String get downloadTileTooltipRemove => 'Remove';

  @override
  String playerResumeFrom(String time) {
    return 'Resuming from $time';
  }

  @override
  String get playerNoChapters => 'No chapters available';

  @override
  String playerChapterNumber(int number) {
    return 'Chapter $number';
  }

  @override
  String get playerLockControls => 'Lock controls';

  @override
  String get playerPictureInPicture => 'Picture-in-Picture';

  @override
  String get playerDismiss => 'Dismiss';

  @override
  String get playerPlayNow => 'Play now';

  @override
  String get adminServerName => 'Server name';

  @override
  String get adminVersion => 'Version';

  @override
  String get adminProduct => 'Product';

  @override
  String get adminServerId => 'Server ID';

  @override
  String get adminLocalAddress => 'Local address';

  @override
  String get adminRestartPending => 'Restart pending';

  @override
  String get adminRestartPendingMessage =>
      'The server has an update or configuration change that requires a restart.';

  @override
  String get adminShuttingDown => 'Shutting down';

  @override
  String get adminInfoSection => 'INFORMATION';

  @override
  String get adminRestartButton => 'Restart server';

  @override
  String get adminShutdownButton => 'Shut down server';

  @override
  String get adminRestartConfirmTitle => 'Restart server?';

  @override
  String get adminRestartConfirmMessage =>
      'All active playback sessions will be interrupted. The server will be unavailable for a few seconds.';

  @override
  String get adminRestartConfirmLabel => 'Restart';

  @override
  String get adminRestartSnack => 'Restart requested.';

  @override
  String get adminShutdownConfirmTitle => 'Shut down server?';

  @override
  String get adminShutdownConfirmMessage =>
      'The Jellyfin server will stop. You will need to restart it manually (machine, container, systemd service).';

  @override
  String get adminShutdownConfirmLabel => 'Shut down';

  @override
  String get adminShutdownSnack => 'Shutdown requested.';

  @override
  String adminErrorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String adminFailurePrefix(String error) {
    return 'Failed: $error';
  }

  @override
  String get adminLibrariesEmpty => 'No libraries configured.';

  @override
  String get adminLibrariesScanAll => 'Run full scan';

  @override
  String get adminLibrariesScanAllTitle => 'Run full scan?';

  @override
  String get adminLibrariesScanAllMessage =>
      'The server will scan all libraries in the background. This may take several minutes depending on the size of your media library.';

  @override
  String get adminLibrariesScanAllConfirm => 'Run';

  @override
  String get adminLibrariesScanSnack => 'Scan started.';

  @override
  String adminLibrariesScanOneSnack(String name) {
    return 'Scan started for \"$name\".';
  }

  @override
  String get adminLibrariesTooltipScan => 'Scan this library';

  @override
  String get adminTasksNoTasks => 'No tasks.';

  @override
  String get adminTasksRunning => 'Running…';

  @override
  String adminTasksRunningPercent(String percent) {
    return 'Running… $percent%';
  }

  @override
  String get adminTasksCancelling => 'Cancelling…';

  @override
  String get adminTasksNeverRun => 'Never run';

  @override
  String adminTasksCompleted(String ago) {
    return 'Completed $ago';
  }

  @override
  String adminTasksFailed(String ago) {
    return 'Failed $ago';
  }

  @override
  String get adminTasksTooltipStop => 'Stop';

  @override
  String get adminTasksTooltipStart => 'Run';

  @override
  String get adminTasksLastRunStatus => 'Status';

  @override
  String get adminTasksLastRunStart => 'Start';

  @override
  String get adminTasksLastRunEnd => 'End';

  @override
  String get adminTasksLastRunDuration => 'Duration';

  @override
  String get adminTasksLastRunError => 'Error';

  @override
  String get adminUsersAdd => 'Add';

  @override
  String get adminUsersEmpty => 'No users.';

  @override
  String get adminUsersNeverConnected => 'Never connected';

  @override
  String adminUsersSeenAt(String when) {
    return 'Seen $when';
  }

  @override
  String get adminUsersBadgeAdmin => 'Admin';

  @override
  String get adminUsersBadgeDisabled => 'Disabled';

  @override
  String get adminUserCreateTitle => 'New user';

  @override
  String get adminUserCreateName => 'Username';

  @override
  String get adminUserCreatePassword => 'Password';

  @override
  String get adminUserCreatePasswordHelper =>
      'Leave blank for no initial password.';

  @override
  String get adminUserCreateIsAdmin => 'Administrator';

  @override
  String get adminUserCreateIsAdminSubtitle =>
      'Grants full control over the Jellyfin server.';

  @override
  String get adminUserCreateRequired => 'Required';

  @override
  String get adminUserCreateButton => 'Create account';

  @override
  String get adminUserEditTitle => 'User';

  @override
  String get adminUserEditIdentitySection => 'IDENTITY';

  @override
  String get adminUserEditLastLogin => 'Last login';

  @override
  String get adminUserEditRightsSection => 'PERMISSIONS';

  @override
  String get adminUserEditIsAdmin => 'Administrator';

  @override
  String get adminUserEditIsAdminSelfHint =>
      'You cannot remove your own admin rights.';

  @override
  String get adminUserEditIsDisabled => 'Account disabled';

  @override
  String get adminUserEditIsDisabledSelfHint =>
      'You cannot disable your own account.';

  @override
  String get adminUserEditLibrariesSection => 'LIBRARIES';

  @override
  String get adminUserEditAllFolders => 'Access to all libraries';

  @override
  String get adminUserEditSaveButton => 'Save';

  @override
  String get adminUserEditSaveSnack => 'Changes saved.';

  @override
  String get adminUserEditResetPassword => 'Reset password';

  @override
  String get adminUserEditNewPasswordTitle => 'New password';

  @override
  String get adminUserEditNewPasswordHint => 'Password';

  @override
  String get adminUserEditResetPasswordCancel => 'Cancel';

  @override
  String get adminUserEditResetPasswordConfirm => 'Reset';

  @override
  String get adminUserEditResetPasswordSnack => 'Password reset.';

  @override
  String get adminUserEditDeleteButton => 'Delete account';

  @override
  String adminUserEditDeleteTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get adminUserEditDeleteMessage =>
      'This action is irreversible. The account, its preferences and playback history will be deleted from the server.';

  @override
  String get adminUserEditDeleteConfirm => 'Delete';

  @override
  String get homeRailContinueWatching => 'Continue watching';

  @override
  String get homeRailNextUp => 'Next up';

  @override
  String get homeHeaderJellyfin => 'Your library';

  @override
  String get homeRailLatest => 'What\'s new';

  @override
  String get homeRailLatestSubtitle => 'Recently added';

  @override
  String get homeRailForYou => 'For you';

  @override
  String get homeRailGems => 'Hidden gems';

  @override
  String get homeRailQuickPicks => 'Quick picks';

  @override
  String get homeRailBecauseYouLiked => 'Because you liked…';

  @override
  String get homeRailUpcomingMovies => 'Upcoming movies';

  @override
  String get homeRailUpcomingEpisodes => 'Upcoming episodes';

  @override
  String get homeHeaderSeer => 'Discover';

  @override
  String get homeRailWatchProvidersMovies => 'Available on…';

  @override
  String get homeRailTrending => 'Trending today';

  @override
  String get homeRailPopularSeries => 'Popular series';

  @override
  String get homeRailWatchlist => 'Your watchlist';

  @override
  String get homeRailGenreSliderMovies => 'Movies by genre';

  @override
  String get homeRailGenreSliderTv => 'Series by genre';

  @override
  String get homeRailWatchProvidersTv => 'Series by provider';

  @override
  String homeRailBecauseYouWatched(String title) {
    return 'Because you watched $title';
  }

  @override
  String homeRailSimilarTo(String title) {
    return 'Similar to $title';
  }

  @override
  String get homeMoodComedy => 'For a good laugh';

  @override
  String get homeMoodThrills => 'For a thrill tonight';

  @override
  String get homeMoodTearjerker => 'For a good cry';

  @override
  String get homeMoodEscape => 'To get away';

  @override
  String get homeMoodAcclaimed => 'Critically acclaimed';

  @override
  String get libraryRailNewMovies => 'New movies';

  @override
  String get libraryRailNewEpisodes => 'New episodes';

  @override
  String get libraryRailNewSeries => 'New series';

  @override
  String get libraryRailNewBoxsets => 'New box sets';

  @override
  String get libraryRailNewAlbums => 'New albums';

  @override
  String get libraryRailNewMusicVideos => 'New music videos';

  @override
  String get libraryRailNewBooks => 'New books';

  @override
  String get libraryRailNewVideos => 'New videos';

  @override
  String get libraryRailNewPhotos => 'New photos';

  @override
  String get libraryRailNewTrailers => 'New trailers';
}
