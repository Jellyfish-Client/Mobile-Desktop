//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'network_settings_proxy.g.dart';

/// NetworkSettingsProxy
///
/// Properties:
/// * [enabled]
/// * [hostname]
/// * [port]
/// * [useSsl]
/// * [user]
/// * [password]
/// * [bypassFilter]
/// * [bypassLocalAddresses]
@BuiltValue()
abstract class NetworkSettingsProxy
    implements Built<NetworkSettingsProxy, NetworkSettingsProxyBuilder> {
  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  @BuiltValueField(wireName: r'hostname')
  String? get hostname;

  @BuiltValueField(wireName: r'port')
  num? get port;

  @BuiltValueField(wireName: r'useSsl')
  bool? get useSsl;

  @BuiltValueField(wireName: r'user')
  String? get user;

  @BuiltValueField(wireName: r'password')
  String? get password;

  @BuiltValueField(wireName: r'bypassFilter')
  String? get bypassFilter;

  @BuiltValueField(wireName: r'bypassLocalAddresses')
  bool? get bypassLocalAddresses;

  NetworkSettingsProxy._();

  factory NetworkSettingsProxy([void updates(NetworkSettingsProxyBuilder b)]) =
      _$NetworkSettingsProxy;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NetworkSettingsProxyBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NetworkSettingsProxy> get serializer =>
      _$NetworkSettingsProxySerializer();
}

class _$NetworkSettingsProxySerializer
    implements PrimitiveSerializer<NetworkSettingsProxy> {
  @override
  final Iterable<Type> types = const [
    NetworkSettingsProxy,
    _$NetworkSettingsProxy
  ];

  @override
  final String wireName = r'NetworkSettingsProxy';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NetworkSettingsProxy object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.hostname != null) {
      yield r'hostname';
      yield serializers.serialize(
        object.hostname,
        specifiedType: const FullType(String),
      );
    }
    if (object.port != null) {
      yield r'port';
      yield serializers.serialize(
        object.port,
        specifiedType: const FullType(num),
      );
    }
    if (object.useSsl != null) {
      yield r'useSsl';
      yield serializers.serialize(
        object.useSsl,
        specifiedType: const FullType(bool),
      );
    }
    if (object.user != null) {
      yield r'user';
      yield serializers.serialize(
        object.user,
        specifiedType: const FullType(String),
      );
    }
    if (object.password != null) {
      yield r'password';
      yield serializers.serialize(
        object.password,
        specifiedType: const FullType(String),
      );
    }
    if (object.bypassFilter != null) {
      yield r'bypassFilter';
      yield serializers.serialize(
        object.bypassFilter,
        specifiedType: const FullType(String),
      );
    }
    if (object.bypassLocalAddresses != null) {
      yield r'bypassLocalAddresses';
      yield serializers.serialize(
        object.bypassLocalAddresses,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NetworkSettingsProxy object, {
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
    required NetworkSettingsProxyBuilder result,
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
        case r'hostname':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.hostname = valueDes;
          break;
        case r'port':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.port = valueDes;
          break;
        case r'useSsl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.useSsl = valueDes;
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.user = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'bypassFilter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bypassFilter = valueDes;
          break;
        case r'bypassLocalAddresses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.bypassLocalAddresses = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NetworkSettingsProxy deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NetworkSettingsProxyBuilder();
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
