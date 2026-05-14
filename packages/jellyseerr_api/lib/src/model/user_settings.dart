//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_settings.g.dart';

/// UserSettings
///
/// Properties:
/// * [username]
/// * [email]
/// * [discordId]
/// * [locale]
/// * [discoverRegion]
/// * [streamingRegion]
/// * [originalLanguage]
/// * [movieQuotaLimit] - Maximum number of movie requests allowed
/// * [movieQuotaDays] - Time period in days for movie quota
/// * [tvQuotaLimit] - Maximum number of TV requests allowed
/// * [tvQuotaDays] - Time period in days for TV quota
/// * [globalMovieQuotaDays] - Global movie quota days setting
/// * [globalMovieQuotaLimit] - Global movie quota limit setting
/// * [globalTvQuotaLimit] - Global TV quota limit setting
/// * [globalTvQuotaDays] - Global TV quota days setting
/// * [watchlistSyncMovies] - Enable watchlist sync for movies
/// * [watchlistSyncTv] - Enable watchlist sync for TV
@BuiltValue()
abstract class UserSettings
    implements Built<UserSettings, UserSettingsBuilder> {
  @BuiltValueField(wireName: r'username')
  String? get username;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'discordId')
  String? get discordId;

  @BuiltValueField(wireName: r'locale')
  String? get locale;

  @BuiltValueField(wireName: r'discoverRegion')
  String? get discoverRegion;

  @BuiltValueField(wireName: r'streamingRegion')
  String? get streamingRegion;

  @BuiltValueField(wireName: r'originalLanguage')
  String? get originalLanguage;

  /// Maximum number of movie requests allowed
  @BuiltValueField(wireName: r'movieQuotaLimit')
  num? get movieQuotaLimit;

  /// Time period in days for movie quota
  @BuiltValueField(wireName: r'movieQuotaDays')
  num? get movieQuotaDays;

  /// Maximum number of TV requests allowed
  @BuiltValueField(wireName: r'tvQuotaLimit')
  num? get tvQuotaLimit;

  /// Time period in days for TV quota
  @BuiltValueField(wireName: r'tvQuotaDays')
  num? get tvQuotaDays;

  /// Global movie quota days setting
  @BuiltValueField(wireName: r'globalMovieQuotaDays')
  num? get globalMovieQuotaDays;

  /// Global movie quota limit setting
  @BuiltValueField(wireName: r'globalMovieQuotaLimit')
  num? get globalMovieQuotaLimit;

  /// Global TV quota limit setting
  @BuiltValueField(wireName: r'globalTvQuotaLimit')
  num? get globalTvQuotaLimit;

  /// Global TV quota days setting
  @BuiltValueField(wireName: r'globalTvQuotaDays')
  num? get globalTvQuotaDays;

  /// Enable watchlist sync for movies
  @BuiltValueField(wireName: r'watchlistSyncMovies')
  bool? get watchlistSyncMovies;

  /// Enable watchlist sync for TV
  @BuiltValueField(wireName: r'watchlistSyncTv')
  bool? get watchlistSyncTv;

  UserSettings._();

  factory UserSettings([void updates(UserSettingsBuilder b)]) = _$UserSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserSettings> get serializer => _$UserSettingsSerializer();
}

class _$UserSettingsSerializer implements PrimitiveSerializer<UserSettings> {
  @override
  final Iterable<Type> types = const [UserSettings, _$UserSettings];

  @override
  final String wireName = r'UserSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.discordId != null) {
      yield r'discordId';
      yield serializers.serialize(
        object.discordId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.locale != null) {
      yield r'locale';
      yield serializers.serialize(
        object.locale,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.discoverRegion != null) {
      yield r'discoverRegion';
      yield serializers.serialize(
        object.discoverRegion,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.streamingRegion != null) {
      yield r'streamingRegion';
      yield serializers.serialize(
        object.streamingRegion,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.originalLanguage != null) {
      yield r'originalLanguage';
      yield serializers.serialize(
        object.originalLanguage,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.movieQuotaLimit != null) {
      yield r'movieQuotaLimit';
      yield serializers.serialize(
        object.movieQuotaLimit,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.movieQuotaDays != null) {
      yield r'movieQuotaDays';
      yield serializers.serialize(
        object.movieQuotaDays,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.tvQuotaLimit != null) {
      yield r'tvQuotaLimit';
      yield serializers.serialize(
        object.tvQuotaLimit,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.tvQuotaDays != null) {
      yield r'tvQuotaDays';
      yield serializers.serialize(
        object.tvQuotaDays,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.globalMovieQuotaDays != null) {
      yield r'globalMovieQuotaDays';
      yield serializers.serialize(
        object.globalMovieQuotaDays,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.globalMovieQuotaLimit != null) {
      yield r'globalMovieQuotaLimit';
      yield serializers.serialize(
        object.globalMovieQuotaLimit,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.globalTvQuotaLimit != null) {
      yield r'globalTvQuotaLimit';
      yield serializers.serialize(
        object.globalTvQuotaLimit,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.globalTvQuotaDays != null) {
      yield r'globalTvQuotaDays';
      yield serializers.serialize(
        object.globalTvQuotaDays,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.watchlistSyncMovies != null) {
      yield r'watchlistSyncMovies';
      yield serializers.serialize(
        object.watchlistSyncMovies,
        specifiedType: const FullType.nullable(bool),
      );
    }
    if (object.watchlistSyncTv != null) {
      yield r'watchlistSyncTv';
      yield serializers.serialize(
        object.watchlistSyncTv,
        specifiedType: const FullType.nullable(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserSettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.username = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'discordId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.discordId = valueDes;
          break;
        case r'locale':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.locale = valueDes;
          break;
        case r'discoverRegion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.discoverRegion = valueDes;
          break;
        case r'streamingRegion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.streamingRegion = valueDes;
          break;
        case r'originalLanguage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.originalLanguage = valueDes;
          break;
        case r'movieQuotaLimit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.movieQuotaLimit = valueDes;
          break;
        case r'movieQuotaDays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.movieQuotaDays = valueDes;
          break;
        case r'tvQuotaLimit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.tvQuotaLimit = valueDes;
          break;
        case r'tvQuotaDays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.tvQuotaDays = valueDes;
          break;
        case r'globalMovieQuotaDays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.globalMovieQuotaDays = valueDes;
          break;
        case r'globalMovieQuotaLimit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.globalMovieQuotaLimit = valueDes;
          break;
        case r'globalTvQuotaLimit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.globalTvQuotaLimit = valueDes;
          break;
        case r'globalTvQuotaDays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.globalTvQuotaDays = valueDes;
          break;
        case r'watchlistSyncMovies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.watchlistSyncMovies = valueDes;
          break;
        case r'watchlistSyncTv':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.watchlistSyncTv = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserSettingsBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
