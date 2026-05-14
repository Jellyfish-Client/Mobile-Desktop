//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:jellyseerr_api/src/date_serializer.dart';
import 'package:jellyseerr_api/src/model/date.dart';

import 'package:jellyseerr_api/src/model/auth_jellyfin_post_request.dart';
import 'package:jellyseerr_api/src/model/auth_local_post_request.dart';
import 'package:jellyseerr_api/src/model/auth_logout_post200_response.dart';
import 'package:jellyseerr_api/src/model/auth_plex_post_request.dart';
import 'package:jellyseerr_api/src/model/auth_reset_password_guid_post_request.dart';
import 'package:jellyseerr_api/src/model/auth_reset_password_post_request.dart';
import 'package:jellyseerr_api/src/model/blocklist.dart';
import 'package:jellyseerr_api/src/model/blocklist_get200_response.dart';
import 'package:jellyseerr_api/src/model/blocklist_get200_response_results_inner.dart';
import 'package:jellyseerr_api/src/model/cast.dart';
import 'package:jellyseerr_api/src/model/certification.dart';
import 'package:jellyseerr_api/src/model/certification_response.dart';
import 'package:jellyseerr_api/src/model/certifications_movie_get500_response.dart';
import 'package:jellyseerr_api/src/model/certifications_tv_get500_response.dart';
import 'package:jellyseerr_api/src/model/collection.dart';
import 'package:jellyseerr_api/src/model/company.dart';
import 'package:jellyseerr_api/src/model/credit_cast.dart';
import 'package:jellyseerr_api/src/model/credit_crew.dart';
import 'package:jellyseerr_api/src/model/crew.dart';
import 'package:jellyseerr_api/src/model/discord_settings.dart';
import 'package:jellyseerr_api/src/model/discord_settings_options.dart';
import 'package:jellyseerr_api/src/model/discover_genreslider_movie_get200_response_inner.dart';
import 'package:jellyseerr_api/src/model/discover_movies_genre_genre_id_get200_response.dart';
import 'package:jellyseerr_api/src/model/discover_movies_get200_response.dart';
import 'package:jellyseerr_api/src/model/discover_movies_language_language_get200_response.dart';
import 'package:jellyseerr_api/src/model/discover_movies_studio_studio_id_get200_response.dart';
import 'package:jellyseerr_api/src/model/discover_slider.dart';
import 'package:jellyseerr_api/src/model/discover_tv_genre_genre_id_get200_response.dart';
import 'package:jellyseerr_api/src/model/discover_tv_get200_response.dart';
import 'package:jellyseerr_api/src/model/discover_tv_language_language_get200_response.dart';
import 'package:jellyseerr_api/src/model/discover_tv_network_network_id_get200_response.dart';
import 'package:jellyseerr_api/src/model/episode.dart';
import 'package:jellyseerr_api/src/model/external_ids.dart';
import 'package:jellyseerr_api/src/model/genre.dart';
import 'package:jellyseerr_api/src/model/genres_movie_get200_response_inner.dart';
import 'package:jellyseerr_api/src/model/genres_tv_get200_response_inner.dart';
import 'package:jellyseerr_api/src/model/gotify_settings.dart';
import 'package:jellyseerr_api/src/model/gotify_settings_options.dart';
import 'package:jellyseerr_api/src/model/issue.dart';
import 'package:jellyseerr_api/src/model/issue_comment.dart';
import 'package:jellyseerr_api/src/model/issue_comment_comment_id_put_request.dart';
import 'package:jellyseerr_api/src/model/issue_count_get200_response.dart';
import 'package:jellyseerr_api/src/model/issue_get200_response.dart';
import 'package:jellyseerr_api/src/model/issue_issue_id_comment_post_request.dart';
import 'package:jellyseerr_api/src/model/issue_post_request.dart';
import 'package:jellyseerr_api/src/model/jellyfin_library.dart';
import 'package:jellyseerr_api/src/model/jellyfin_settings.dart';
import 'package:jellyseerr_api/src/model/job.dart';
import 'package:jellyseerr_api/src/model/keyword.dart';
import 'package:jellyseerr_api/src/model/keyword_keyword_id_get500_response.dart';
import 'package:jellyseerr_api/src/model/languages_get200_response_inner.dart';
import 'package:jellyseerr_api/src/model/main_settings.dart';
import 'package:jellyseerr_api/src/model/media_get200_response.dart';
import 'package:jellyseerr_api/src/model/media_info.dart';
import 'package:jellyseerr_api/src/model/media_media_id_status_post_request.dart';
import 'package:jellyseerr_api/src/model/media_media_id_watch_data_get200_response.dart';
import 'package:jellyseerr_api/src/model/media_media_id_watch_data_get200_response_data.dart';
import 'package:jellyseerr_api/src/model/media_request.dart';
import 'package:jellyseerr_api/src/model/media_request_modified_by.dart';
import 'package:jellyseerr_api/src/model/metadata_settings.dart';
import 'package:jellyseerr_api/src/model/metadata_settings_settings.dart';
import 'package:jellyseerr_api/src/model/movie_details.dart';
import 'package:jellyseerr_api/src/model/movie_details_collection.dart';
import 'package:jellyseerr_api/src/model/movie_details_credits.dart';
import 'package:jellyseerr_api/src/model/movie_details_production_countries_inner.dart';
import 'package:jellyseerr_api/src/model/movie_details_releases.dart';
import 'package:jellyseerr_api/src/model/movie_details_releases_results_inner.dart';
import 'package:jellyseerr_api/src/model/movie_details_releases_results_inner_release_dates_inner.dart';
import 'package:jellyseerr_api/src/model/movie_movie_id_ratings_get200_response.dart';
import 'package:jellyseerr_api/src/model/movie_movie_id_ratingscombined_get200_response.dart';
import 'package:jellyseerr_api/src/model/movie_movie_id_ratingscombined_get200_response_imdb.dart';
import 'package:jellyseerr_api/src/model/movie_result.dart';
import 'package:jellyseerr_api/src/model/network.dart';
import 'package:jellyseerr_api/src/model/network_settings.dart';
import 'package:jellyseerr_api/src/model/network_settings_dns_cache.dart';
import 'package:jellyseerr_api/src/model/network_settings_proxy.dart';
import 'package:jellyseerr_api/src/model/notification_agent_types.dart';
import 'package:jellyseerr_api/src/model/notification_email_settings.dart';
import 'package:jellyseerr_api/src/model/notification_email_settings_options.dart';
import 'package:jellyseerr_api/src/model/ntfy_settings.dart';
import 'package:jellyseerr_api/src/model/ntfy_settings_options.dart';
import 'package:jellyseerr_api/src/model/override_rule.dart';
import 'package:jellyseerr_api/src/model/page_info.dart';
import 'package:jellyseerr_api/src/model/person_details.dart';
import 'package:jellyseerr_api/src/model/person_person_id_combined_credits_get200_response.dart';
import 'package:jellyseerr_api/src/model/person_result.dart';
import 'package:jellyseerr_api/src/model/person_result_known_for_inner.dart';
import 'package:jellyseerr_api/src/model/plex_connection.dart';
import 'package:jellyseerr_api/src/model/plex_device.dart';
import 'package:jellyseerr_api/src/model/plex_library.dart';
import 'package:jellyseerr_api/src/model/plex_settings.dart';
import 'package:jellyseerr_api/src/model/production_company.dart';
import 'package:jellyseerr_api/src/model/public_settings.dart';
import 'package:jellyseerr_api/src/model/pushbullet_settings.dart';
import 'package:jellyseerr_api/src/model/pushbullet_settings_options.dart';
import 'package:jellyseerr_api/src/model/pushover_settings.dart';
import 'package:jellyseerr_api/src/model/pushover_settings_options.dart';
import 'package:jellyseerr_api/src/model/radarr_settings.dart';
import 'package:jellyseerr_api/src/model/regions_get200_response_inner.dart';
import 'package:jellyseerr_api/src/model/related_video.dart';
import 'package:jellyseerr_api/src/model/request_count_get200_response.dart';
import 'package:jellyseerr_api/src/model/request_post_request.dart';
import 'package:jellyseerr_api/src/model/request_post_request_seasons.dart';
import 'package:jellyseerr_api/src/model/request_request_id_put_request.dart';
import 'package:jellyseerr_api/src/model/search_company_get200_response.dart';
import 'package:jellyseerr_api/src/model/search_get200_response.dart';
import 'package:jellyseerr_api/src/model/search_get200_response_results_inner.dart';
import 'package:jellyseerr_api/src/model/search_keyword_get200_response.dart';
import 'package:jellyseerr_api/src/model/season.dart';
import 'package:jellyseerr_api/src/model/servarr_tag.dart';
import 'package:jellyseerr_api/src/model/service_profile.dart';
import 'package:jellyseerr_api/src/model/service_radarr_radarr_id_get200_response.dart';
import 'package:jellyseerr_api/src/model/service_sonarr_sonarr_id_get200_response.dart';
import 'package:jellyseerr_api/src/model/settings_about_get200_response.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_api_caches_inner.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_api_caches_inner_stats.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_dns_cache.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_dns_cache_entries_value.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_dns_cache_entries_value_addresses.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_dns_cache_stats.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_image_cache.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_image_cache_tmdb.dart';
import 'package:jellyseerr_api/src/model/settings_discover_add_post_request.dart';
import 'package:jellyseerr_api/src/model/settings_discover_slider_id_put_request.dart';
import 'package:jellyseerr_api/src/model/settings_jellyfin_sync_get200_response.dart';
import 'package:jellyseerr_api/src/model/settings_jellyfin_sync_post_request.dart';
import 'package:jellyseerr_api/src/model/settings_jellyfin_users_get200_response_inner.dart';
import 'package:jellyseerr_api/src/model/settings_jobs_job_id_schedule_post_request.dart';
import 'package:jellyseerr_api/src/model/settings_logs_get200_response_inner.dart';
import 'package:jellyseerr_api/src/model/settings_metadatas_test_post200_response.dart';
import 'package:jellyseerr_api/src/model/settings_metadatas_test_post_request.dart';
import 'package:jellyseerr_api/src/model/settings_notifications_pushover_sounds_get200_response_inner.dart';
import 'package:jellyseerr_api/src/model/settings_plex_sync_get200_response.dart';
import 'package:jellyseerr_api/src/model/settings_plex_users_get200_response_inner.dart';
import 'package:jellyseerr_api/src/model/settings_radarr_test_post200_response.dart';
import 'package:jellyseerr_api/src/model/settings_radarr_test_post_request.dart';
import 'package:jellyseerr_api/src/model/settings_sonarr_test_post_request.dart';
import 'package:jellyseerr_api/src/model/slack_settings.dart';
import 'package:jellyseerr_api/src/model/slack_settings_options.dart';
import 'package:jellyseerr_api/src/model/sonarr_series.dart';
import 'package:jellyseerr_api/src/model/sonarr_series_add_options_inner.dart';
import 'package:jellyseerr_api/src/model/sonarr_series_images_inner.dart';
import 'package:jellyseerr_api/src/model/sonarr_series_ratings_inner.dart';
import 'package:jellyseerr_api/src/model/sonarr_series_seasons_inner.dart';
import 'package:jellyseerr_api/src/model/sonarr_settings.dart';
import 'package:jellyseerr_api/src/model/spoken_language.dart';
import 'package:jellyseerr_api/src/model/status_appdata_get200_response.dart';
import 'package:jellyseerr_api/src/model/status_get200_response.dart';
import 'package:jellyseerr_api/src/model/tautulli_settings.dart';
import 'package:jellyseerr_api/src/model/telegram_settings.dart';
import 'package:jellyseerr_api/src/model/telegram_settings_options.dart';
import 'package:jellyseerr_api/src/model/tv_details.dart';
import 'package:jellyseerr_api/src/model/tv_details_content_ratings.dart';
import 'package:jellyseerr_api/src/model/tv_details_content_ratings_results_inner.dart';
import 'package:jellyseerr_api/src/model/tv_details_created_by_inner.dart';
import 'package:jellyseerr_api/src/model/tv_result.dart';
import 'package:jellyseerr_api/src/model/tv_tv_id_ratings_get200_response.dart';
import 'package:jellyseerr_api/src/model/user.dart';
import 'package:jellyseerr_api/src/model/user_get200_response.dart';
import 'package:jellyseerr_api/src/model/user_import_from_jellyfin_post_request.dart';
import 'package:jellyseerr_api/src/model/user_import_from_plex_post_request.dart';
import 'package:jellyseerr_api/src/model/user_post_request.dart';
import 'package:jellyseerr_api/src/model/user_put_request.dart';
import 'package:jellyseerr_api/src/model/user_register_push_subscription_post_request.dart';
import 'package:jellyseerr_api/src/model/user_settings.dart';
import 'package:jellyseerr_api/src/model/user_settings_notifications.dart';
import 'package:jellyseerr_api/src/model/user_user_id_push_subscriptions_get200_response.dart';
import 'package:jellyseerr_api/src/model/user_user_id_quota_get200_response.dart';
import 'package:jellyseerr_api/src/model/user_user_id_quota_get200_response_movie.dart';
import 'package:jellyseerr_api/src/model/user_user_id_requests_get200_response.dart';
import 'package:jellyseerr_api/src/model/user_user_id_settings_linked_accounts_jellyfin_post_request.dart';
import 'package:jellyseerr_api/src/model/user_user_id_settings_password_get200_response.dart';
import 'package:jellyseerr_api/src/model/user_user_id_settings_password_post_request.dart';
import 'package:jellyseerr_api/src/model/user_user_id_settings_permissions_get200_response.dart';
import 'package:jellyseerr_api/src/model/user_user_id_settings_permissions_post_request.dart';
import 'package:jellyseerr_api/src/model/user_user_id_watch_data_get200_response.dart';
import 'package:jellyseerr_api/src/model/user_user_id_watchlist_get200_response.dart';
import 'package:jellyseerr_api/src/model/user_user_id_watchlist_get200_response_results_inner.dart';
import 'package:jellyseerr_api/src/model/watch_provider_details.dart';
import 'package:jellyseerr_api/src/model/watch_provider_region.dart';
import 'package:jellyseerr_api/src/model/watch_providers_inner.dart';
import 'package:jellyseerr_api/src/model/watchlist.dart';
import 'package:jellyseerr_api/src/model/web_push_settings.dart';
import 'package:jellyseerr_api/src/model/webhook_settings.dart';
import 'package:jellyseerr_api/src/model/webhook_settings_options.dart';

part 'serializers.g.dart';

@SerializersFor([
  AuthJellyfinPostRequest,
  AuthLocalPostRequest,
  AuthLogoutPost200Response,
  AuthPlexPostRequest,
  AuthResetPasswordGuidPostRequest,
  AuthResetPasswordPostRequest,
  Blocklist,
  BlocklistGet200Response,
  BlocklistGet200ResponseResultsInner,
  Cast,
  Certification,
  CertificationResponse,
  CertificationsMovieGet500Response,
  CertificationsTvGet500Response,
  Collection,
  Company,
  CreditCast,
  CreditCrew,
  Crew,
  DiscordSettings,
  DiscordSettingsOptions,
  DiscoverGenresliderMovieGet200ResponseInner,
  DiscoverMoviesGenreGenreIdGet200Response,
  DiscoverMoviesGet200Response,
  DiscoverMoviesLanguageLanguageGet200Response,
  DiscoverMoviesStudioStudioIdGet200Response,
  DiscoverSlider,
  DiscoverTvGenreGenreIdGet200Response,
  DiscoverTvGet200Response,
  DiscoverTvLanguageLanguageGet200Response,
  DiscoverTvNetworkNetworkIdGet200Response,
  Episode,
  ExternalIds,
  Genre,
  GenresMovieGet200ResponseInner,
  GenresTvGet200ResponseInner,
  GotifySettings,
  GotifySettingsOptions,
  Issue,
  IssueComment,
  IssueCommentCommentIdPutRequest,
  IssueCountGet200Response,
  IssueGet200Response,
  IssueIssueIdCommentPostRequest,
  IssuePostRequest,
  JellyfinLibrary,
  JellyfinSettings,
  Job,
  Keyword,
  KeywordKeywordIdGet500Response,
  LanguagesGet200ResponseInner,
  MainSettings,
  MediaGet200Response,
  MediaInfo,
  MediaMediaIdStatusPostRequest,
  MediaMediaIdWatchDataGet200Response,
  MediaMediaIdWatchDataGet200ResponseData,
  MediaRequest,
  MediaRequestModifiedBy,
  MetadataSettings,
  MetadataSettingsSettings,
  MovieDetails,
  MovieDetailsCollection,
  MovieDetailsCredits,
  MovieDetailsProductionCountriesInner,
  MovieDetailsReleases,
  MovieDetailsReleasesResultsInner,
  MovieDetailsReleasesResultsInnerReleaseDatesInner,
  MovieMovieIdRatingsGet200Response,
  MovieMovieIdRatingscombinedGet200Response,
  MovieMovieIdRatingscombinedGet200ResponseImdb,
  MovieResult,
  Network,
  NetworkSettings,
  NetworkSettingsDnsCache,
  NetworkSettingsProxy,
  NotificationAgentTypes,
  NotificationEmailSettings,
  NotificationEmailSettingsOptions,
  NtfySettings,
  NtfySettingsOptions,
  OverrideRule,
  PageInfo,
  PersonDetails,
  PersonPersonIdCombinedCreditsGet200Response,
  PersonResult,
  PersonResultKnownForInner,
  PlexConnection,
  PlexDevice,
  PlexLibrary,
  PlexSettings,
  ProductionCompany,
  PublicSettings,
  PushbulletSettings,
  PushbulletSettingsOptions,
  PushoverSettings,
  PushoverSettingsOptions,
  RadarrSettings,
  RegionsGet200ResponseInner,
  RelatedVideo,
  RequestCountGet200Response,
  RequestPostRequest,
  RequestPostRequestSeasons,
  RequestRequestIdPutRequest,
  SearchCompanyGet200Response,
  SearchGet200Response,
  SearchGet200ResponseResultsInner,
  SearchKeywordGet200Response,
  Season,
  ServarrTag,
  ServiceProfile,
  ServiceRadarrRadarrIdGet200Response,
  ServiceSonarrSonarrIdGet200Response,
  SettingsAboutGet200Response,
  SettingsCacheGet200Response,
  SettingsCacheGet200ResponseApiCachesInner,
  SettingsCacheGet200ResponseApiCachesInnerStats,
  SettingsCacheGet200ResponseDnsCache,
  SettingsCacheGet200ResponseDnsCacheEntriesValue,
  SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses,
  SettingsCacheGet200ResponseDnsCacheStats,
  SettingsCacheGet200ResponseImageCache,
  SettingsCacheGet200ResponseImageCacheTmdb,
  SettingsDiscoverAddPostRequest,
  SettingsDiscoverSliderIdPutRequest,
  SettingsJellyfinSyncGet200Response,
  SettingsJellyfinSyncPostRequest,
  SettingsJellyfinUsersGet200ResponseInner,
  SettingsJobsJobIdSchedulePostRequest,
  SettingsLogsGet200ResponseInner,
  SettingsMetadatasTestPost200Response,
  SettingsMetadatasTestPostRequest,
  SettingsNotificationsPushoverSoundsGet200ResponseInner,
  SettingsPlexSyncGet200Response,
  SettingsPlexUsersGet200ResponseInner,
  SettingsRadarrTestPost200Response,
  SettingsRadarrTestPostRequest,
  SettingsSonarrTestPostRequest,
  SlackSettings,
  SlackSettingsOptions,
  SonarrSeries,
  SonarrSeriesAddOptionsInner,
  SonarrSeriesImagesInner,
  SonarrSeriesRatingsInner,
  SonarrSeriesSeasonsInner,
  SonarrSettings,
  SpokenLanguage,
  StatusAppdataGet200Response,
  StatusGet200Response,
  TautulliSettings,
  TelegramSettings,
  TelegramSettingsOptions,
  TvDetails,
  TvDetailsContentRatings,
  TvDetailsContentRatingsResultsInner,
  TvDetailsCreatedByInner,
  TvResult,
  TvTvIdRatingsGet200Response,
  User,
  UserGet200Response,
  UserImportFromJellyfinPostRequest,
  UserImportFromPlexPostRequest,
  UserPostRequest,
  UserPutRequest,
  UserRegisterPushSubscriptionPostRequest,
  UserSettings,
  UserSettingsNotifications,
  UserUserIdPushSubscriptionsGet200Response,
  UserUserIdQuotaGet200Response,
  UserUserIdQuotaGet200ResponseMovie,
  UserUserIdRequestsGet200Response,
  UserUserIdSettingsLinkedAccountsJellyfinPostRequest,
  UserUserIdSettingsPasswordGet200Response,
  UserUserIdSettingsPasswordPostRequest,
  UserUserIdSettingsPermissionsGet200Response,
  UserUserIdSettingsPermissionsPostRequest,
  UserUserIdWatchDataGet200Response,
  UserUserIdWatchlistGet200Response,
  UserUserIdWatchlistGet200ResponseResultsInner,
  WatchProviderDetails,
  WatchProviderRegion,
  WatchProvidersInner,
  Watchlist,
  WebPushSettings,
  WebhookSettings,
  WebhookSettingsOptions,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(WatchProviderRegion)]),
        () => ListBuilder<WatchProviderRegion>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(SettingsJellyfinUsersGet200ResponseInner)]),
        () => ListBuilder<SettingsJellyfinUsersGet200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(User)]),
        () => ListBuilder<User>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Job)]),
        () => ListBuilder<Job>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(DiscoverSlider)]),
        () => ListBuilder<DiscoverSlider>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(RadarrSettings)]),
        () => ListBuilder<RadarrSettings>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(SettingsPlexUsersGet200ResponseInner)]),
        () => ListBuilder<SettingsPlexUsersGet200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(RegionsGet200ResponseInner)]),
        () => ListBuilder<RegionsGet200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(GenresTvGet200ResponseInner)]),
        () => ListBuilder<GenresTvGet200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(WatchProviderDetails)]),
        () => ListBuilder<WatchProviderDetails>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SettingsLogsGet200ResponseInner)]),
        () => ListBuilder<SettingsLogsGet200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SonarrSeries)]),
        () => ListBuilder<SonarrSeries>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(LanguagesGet200ResponseInner)]),
        () => ListBuilder<LanguagesGet200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList,
            [FullType(SettingsNotificationsPushoverSoundsGet200ResponseInner)]),
        () => ListBuilder<
            SettingsNotificationsPushoverSoundsGet200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(
            BuiltList, [FullType(DiscoverGenresliderMovieGet200ResponseInner)]),
        () => ListBuilder<DiscoverGenresliderMovieGet200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(JellyfinLibrary)]),
        () => ListBuilder<JellyfinLibrary>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(SonarrSettings)]),
        () => ListBuilder<SonarrSettings>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(GenresMovieGet200ResponseInner)]),
        () => ListBuilder<GenresMovieGet200ResponseInner>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(OverrideRule)]),
        () => ListBuilder<OverrideRule>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PlexLibrary)]),
        () => ListBuilder<PlexLibrary>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ServiceProfile)]),
        () => ListBuilder<ServiceProfile>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(String)]),
        () => ListBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(PlexDevice)]),
        () => ListBuilder<PlexDevice>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
