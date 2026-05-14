//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'settings_cache_get200_response_dns_cache_stats.g.dart';

/// SettingsCacheGet200ResponseDnsCacheStats
///
/// Properties:
/// * [size]
/// * [maxSize]
/// * [hits]
/// * [misses]
/// * [failures]
/// * [ipv4Fallbacks]
/// * [hitRate]
@BuiltValue()
abstract class SettingsCacheGet200ResponseDnsCacheStats
    implements
        Built<SettingsCacheGet200ResponseDnsCacheStats,
            SettingsCacheGet200ResponseDnsCacheStatsBuilder> {
  @BuiltValueField(wireName: r'size')
  num? get size;

  @BuiltValueField(wireName: r'maxSize')
  num? get maxSize;

  @BuiltValueField(wireName: r'hits')
  num? get hits;

  @BuiltValueField(wireName: r'misses')
  num? get misses;

  @BuiltValueField(wireName: r'failures')
  num? get failures;

  @BuiltValueField(wireName: r'ipv4Fallbacks')
  num? get ipv4Fallbacks;

  @BuiltValueField(wireName: r'hitRate')
  num? get hitRate;

  SettingsCacheGet200ResponseDnsCacheStats._();

  factory SettingsCacheGet200ResponseDnsCacheStats(
          [void updates(SettingsCacheGet200ResponseDnsCacheStatsBuilder b)]) =
      _$SettingsCacheGet200ResponseDnsCacheStats;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SettingsCacheGet200ResponseDnsCacheStatsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SettingsCacheGet200ResponseDnsCacheStats> get serializer =>
      _$SettingsCacheGet200ResponseDnsCacheStatsSerializer();
}

class _$SettingsCacheGet200ResponseDnsCacheStatsSerializer
    implements PrimitiveSerializer<SettingsCacheGet200ResponseDnsCacheStats> {
  @override
  final Iterable<Type> types = const [
    SettingsCacheGet200ResponseDnsCacheStats,
    _$SettingsCacheGet200ResponseDnsCacheStats
  ];

  @override
  final String wireName = r'SettingsCacheGet200ResponseDnsCacheStats';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SettingsCacheGet200ResponseDnsCacheStats object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.size != null) {
      yield r'size';
      yield serializers.serialize(
        object.size,
        specifiedType: const FullType(num),
      );
    }
    if (object.maxSize != null) {
      yield r'maxSize';
      yield serializers.serialize(
        object.maxSize,
        specifiedType: const FullType(num),
      );
    }
    if (object.hits != null) {
      yield r'hits';
      yield serializers.serialize(
        object.hits,
        specifiedType: const FullType(num),
      );
    }
    if (object.misses != null) {
      yield r'misses';
      yield serializers.serialize(
        object.misses,
        specifiedType: const FullType(num),
      );
    }
    if (object.failures != null) {
      yield r'failures';
      yield serializers.serialize(
        object.failures,
        specifiedType: const FullType(num),
      );
    }
    if (object.ipv4Fallbacks != null) {
      yield r'ipv4Fallbacks';
      yield serializers.serialize(
        object.ipv4Fallbacks,
        specifiedType: const FullType(num),
      );
    }
    if (object.hitRate != null) {
      yield r'hitRate';
      yield serializers.serialize(
        object.hitRate,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SettingsCacheGet200ResponseDnsCacheStats object, {
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
    required SettingsCacheGet200ResponseDnsCacheStatsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.size = valueDes;
          break;
        case r'maxSize':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.maxSize = valueDes;
          break;
        case r'hits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.hits = valueDes;
          break;
        case r'misses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.misses = valueDes;
          break;
        case r'failures':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.failures = valueDes;
          break;
        case r'ipv4Fallbacks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.ipv4Fallbacks = valueDes;
          break;
        case r'hitRate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.hitRate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SettingsCacheGet200ResponseDnsCacheStats deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SettingsCacheGet200ResponseDnsCacheStatsBuilder();
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
