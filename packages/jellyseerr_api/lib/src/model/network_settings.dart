//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:jellyseerr_api/src/model/network_settings_proxy.dart';
import 'package:jellyseerr_api/src/model/network_settings_dns_cache.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'network_settings.g.dart';

/// NetworkSettings
///
/// Properties:
/// * [csrfProtection]
/// * [forceIpv4First]
/// * [trustProxy]
/// * [proxy]
/// * [dnsCache]
@BuiltValue()
abstract class NetworkSettings
    implements Built<NetworkSettings, NetworkSettingsBuilder> {
  @BuiltValueField(wireName: r'csrfProtection')
  bool? get csrfProtection;

  @BuiltValueField(wireName: r'forceIpv4First')
  bool? get forceIpv4First;

  @BuiltValueField(wireName: r'trustProxy')
  bool? get trustProxy;

  @BuiltValueField(wireName: r'proxy')
  NetworkSettingsProxy? get proxy;

  @BuiltValueField(wireName: r'dnsCache')
  NetworkSettingsDnsCache? get dnsCache;

  NetworkSettings._();

  factory NetworkSettings([void updates(NetworkSettingsBuilder b)]) =
      _$NetworkSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NetworkSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NetworkSettings> get serializer =>
      _$NetworkSettingsSerializer();
}

class _$NetworkSettingsSerializer
    implements PrimitiveSerializer<NetworkSettings> {
  @override
  final Iterable<Type> types = const [NetworkSettings, _$NetworkSettings];

  @override
  final String wireName = r'NetworkSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NetworkSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.csrfProtection != null) {
      yield r'csrfProtection';
      yield serializers.serialize(
        object.csrfProtection,
        specifiedType: const FullType(bool),
      );
    }
    if (object.forceIpv4First != null) {
      yield r'forceIpv4First';
      yield serializers.serialize(
        object.forceIpv4First,
        specifiedType: const FullType(bool),
      );
    }
    if (object.trustProxy != null) {
      yield r'trustProxy';
      yield serializers.serialize(
        object.trustProxy,
        specifiedType: const FullType(bool),
      );
    }
    if (object.proxy != null) {
      yield r'proxy';
      yield serializers.serialize(
        object.proxy,
        specifiedType: const FullType(NetworkSettingsProxy),
      );
    }
    if (object.dnsCache != null) {
      yield r'dnsCache';
      yield serializers.serialize(
        object.dnsCache,
        specifiedType: const FullType(NetworkSettingsDnsCache),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NetworkSettings object, {
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
    required NetworkSettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'csrfProtection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.csrfProtection = valueDes;
          break;
        case r'forceIpv4First':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.forceIpv4First = valueDes;
          break;
        case r'trustProxy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.trustProxy = valueDes;
          break;
        case r'proxy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NetworkSettingsProxy),
          ) as NetworkSettingsProxy;
          result.proxy.replace(valueDes);
          break;
        case r'dnsCache':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(NetworkSettingsDnsCache),
          ) as NetworkSettingsDnsCache;
          result.dnsCache.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NetworkSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NetworkSettingsBuilder();
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
