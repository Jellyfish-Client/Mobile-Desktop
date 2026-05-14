//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'metadata_settings_settings.g.dart';

/// MetadataSettingsSettings
///
/// Properties:
/// * [tv]
/// * [anime]
@BuiltValue()
abstract class MetadataSettingsSettings
    implements
        Built<MetadataSettingsSettings, MetadataSettingsSettingsBuilder> {
  @BuiltValueField(wireName: r'tv')
  MetadataSettingsSettingsTvEnum? get tv;
  // enum tvEnum {  tvdb,  tmdb,  };

  @BuiltValueField(wireName: r'anime')
  MetadataSettingsSettingsAnimeEnum? get anime;
  // enum animeEnum {  tvdb,  tmdb,  };

  MetadataSettingsSettings._();

  factory MetadataSettingsSettings(
          [void updates(MetadataSettingsSettingsBuilder b)]) =
      _$MetadataSettingsSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MetadataSettingsSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MetadataSettingsSettings> get serializer =>
      _$MetadataSettingsSettingsSerializer();
}

class _$MetadataSettingsSettingsSerializer
    implements PrimitiveSerializer<MetadataSettingsSettings> {
  @override
  final Iterable<Type> types = const [
    MetadataSettingsSettings,
    _$MetadataSettingsSettings
  ];

  @override
  final String wireName = r'MetadataSettingsSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MetadataSettingsSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.tv != null) {
      yield r'tv';
      yield serializers.serialize(
        object.tv,
        specifiedType: const FullType(MetadataSettingsSettingsTvEnum),
      );
    }
    if (object.anime != null) {
      yield r'anime';
      yield serializers.serialize(
        object.anime,
        specifiedType: const FullType(MetadataSettingsSettingsAnimeEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MetadataSettingsSettings object, {
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
    required MetadataSettingsSettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tv':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MetadataSettingsSettingsTvEnum),
          ) as MetadataSettingsSettingsTvEnum;
          result.tv = valueDes;
          break;
        case r'anime':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MetadataSettingsSettingsAnimeEnum),
          ) as MetadataSettingsSettingsAnimeEnum;
          result.anime = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MetadataSettingsSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MetadataSettingsSettingsBuilder();
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

class MetadataSettingsSettingsTvEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'tvdb')
  static const MetadataSettingsSettingsTvEnum tvdb =
      _$metadataSettingsSettingsTvEnum_tvdb;
  @BuiltValueEnumConst(wireName: r'tmdb')
  static const MetadataSettingsSettingsTvEnum tmdb =
      _$metadataSettingsSettingsTvEnum_tmdb;

  static Serializer<MetadataSettingsSettingsTvEnum> get serializer =>
      _$metadataSettingsSettingsTvEnumSerializer;

  const MetadataSettingsSettingsTvEnum._(String name) : super(name);

  static BuiltSet<MetadataSettingsSettingsTvEnum> get values =>
      _$metadataSettingsSettingsTvEnumValues;
  static MetadataSettingsSettingsTvEnum valueOf(String name) =>
      _$metadataSettingsSettingsTvEnumValueOf(name);
}

class MetadataSettingsSettingsAnimeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'tvdb')
  static const MetadataSettingsSettingsAnimeEnum tvdb =
      _$metadataSettingsSettingsAnimeEnum_tvdb;
  @BuiltValueEnumConst(wireName: r'tmdb')
  static const MetadataSettingsSettingsAnimeEnum tmdb =
      _$metadataSettingsSettingsAnimeEnum_tmdb;

  static Serializer<MetadataSettingsSettingsAnimeEnum> get serializer =>
      _$metadataSettingsSettingsAnimeEnumSerializer;

  const MetadataSettingsSettingsAnimeEnum._(String name) : super(name);

  static BuiltSet<MetadataSettingsSettingsAnimeEnum> get values =>
      _$metadataSettingsSettingsAnimeEnumValues;
  static MetadataSettingsSettingsAnimeEnum valueOf(String name) =>
      _$metadataSettingsSettingsAnimeEnumValueOf(name);
}
