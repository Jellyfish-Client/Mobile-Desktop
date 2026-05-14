//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'network_settings_dns_cache.g.dart';

/// NetworkSettingsDnsCache
///
/// Properties:
/// * [enabled]
/// * [forceMinTtl]
/// * [forceMaxTtl]
@BuiltValue()
abstract class NetworkSettingsDnsCache
    implements Built<NetworkSettingsDnsCache, NetworkSettingsDnsCacheBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  @BuiltValueField(wireName: r'forceMinTtl')
  num? get forceMinTtl;

  @BuiltValueField(wireName: r'forceMaxTtl')
  num? get forceMaxTtl;

  NetworkSettingsDnsCache._();

  factory NetworkSettingsDnsCache(
          [void updates(NetworkSettingsDnsCacheBuilder b)]) =
      _$NetworkSettingsDnsCache;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NetworkSettingsDnsCacheBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NetworkSettingsDnsCache> get serializer =>
      _$NetworkSettingsDnsCacheSerializer();
}

class _$NetworkSettingsDnsCacheSerializer
    implements PrimitiveSerializer<NetworkSettingsDnsCache> {
  @override
  final Iterable<Type> types = const [
    NetworkSettingsDnsCache,
    _$NetworkSettingsDnsCache
  ];

  @override
  final String wireName = r'NetworkSettingsDnsCache';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NetworkSettingsDnsCache object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.forceMinTtl != null) {
      yield r'forceMinTtl';
      yield serializers.serialize(
        object.forceMinTtl,
        specifiedType: const FullType(num),
      );
    }
    if (object.forceMaxTtl != null) {
      yield r'forceMaxTtl';
      yield serializers.serialize(
        object.forceMaxTtl,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NetworkSettingsDnsCache object, {
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
    required NetworkSettingsDnsCacheBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'forceMinTtl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.forceMinTtl = valueDes;
          break;
        case r'forceMaxTtl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.forceMaxTtl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NetworkSettingsDnsCache deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NetworkSettingsDnsCacheBuilder();
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
