//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_dns_cache_stats.dart';
import 'package:built_collection/built_collection.dart';
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_dns_cache_entries_value.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'settings_cache_get200_response_dns_cache.g.dart';

/// SettingsCacheGet200ResponseDnsCache
///
/// Properties:
/// * [stats]
/// * [entries]
@BuiltValue()
abstract class SettingsCacheGet200ResponseDnsCache
    implements
        Built<SettingsCacheGet200ResponseDnsCache,
            SettingsCacheGet200ResponseDnsCacheBuilder> {
  @BuiltValueField(wireName: r'stats')
  SettingsCacheGet200ResponseDnsCacheStats? get stats;

  @BuiltValueField(wireName: r'entries')
  BuiltMap<String, SettingsCacheGet200ResponseDnsCacheEntriesValue>?
      get entries;

  SettingsCacheGet200ResponseDnsCache._();

  factory SettingsCacheGet200ResponseDnsCache(
          [void updates(SettingsCacheGet200ResponseDnsCacheBuilder b)]) =
      _$SettingsCacheGet200ResponseDnsCache;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SettingsCacheGet200ResponseDnsCacheBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SettingsCacheGet200ResponseDnsCache> get serializer =>
      _$SettingsCacheGet200ResponseDnsCacheSerializer();
}

class _$SettingsCacheGet200ResponseDnsCacheSerializer
    implements PrimitiveSerializer<SettingsCacheGet200ResponseDnsCache> {
  @override
  final Iterable<Type> types = const [
    SettingsCacheGet200ResponseDnsCache,
    _$SettingsCacheGet200ResponseDnsCache
  ];

  @override
  final String wireName = r'SettingsCacheGet200ResponseDnsCache';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SettingsCacheGet200ResponseDnsCache object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.stats != null) {
      yield r'stats';
      yield serializers.serialize(
        object.stats,
        specifiedType: const FullType(SettingsCacheGet200ResponseDnsCacheStats),
      );
    }
    if (object.entries != null) {
      yield r'entries';
      yield serializers.serialize(
        object.entries,
        specifiedType: const FullType(BuiltMap, [
          FullType(String),
          FullType(SettingsCacheGet200ResponseDnsCacheEntriesValue)
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SettingsCacheGet200ResponseDnsCache object, {
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
    required SettingsCacheGet200ResponseDnsCacheBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'stats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(SettingsCacheGet200ResponseDnsCacheStats),
          ) as SettingsCacheGet200ResponseDnsCacheStats;
          result.stats.replace(valueDes);
          break;
        case r'entries':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [
              FullType(String),
              FullType(SettingsCacheGet200ResponseDnsCacheEntriesValue)
            ]),
          ) as BuiltMap<String,
              SettingsCacheGet200ResponseDnsCacheEntriesValue>;
          result.entries.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SettingsCacheGet200ResponseDnsCache deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SettingsCacheGet200ResponseDnsCacheBuilder();
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
