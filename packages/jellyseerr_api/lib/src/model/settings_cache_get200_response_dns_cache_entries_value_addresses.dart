//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'settings_cache_get200_response_dns_cache_entries_value_addresses.g.dart';

/// SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses
///
/// Properties:
/// * [ipv4]
/// * [ipv6]
@BuiltValue()
abstract class SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses
    implements
        Built<SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses,
            SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder> {
  @BuiltValueField(wireName: r'ipv4')
  num? get ipv4;

  @BuiltValueField(wireName: r'ipv6')
  num? get ipv6;

  SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses._();

  factory SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses(
      [void updates(
          SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder
              b)]) = _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses>
      get serializer =>
          _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesSerializer();
}

class _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesSerializer
    implements
        PrimitiveSerializer<
            SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses> {
  @override
  final Iterable<Type> types = const [
    SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses,
    _$SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses
  ];

  @override
  final String wireName =
      r'SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.ipv4 != null) {
      yield r'ipv4';
      yield serializers.serialize(
        object.ipv4,
        specifiedType: const FullType(num),
      );
    }
    if (object.ipv6 != null) {
      yield r'ipv6';
      yield serializers.serialize(
        object.ipv6,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses object, {
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
    required SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ipv4':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.ipv4 = valueDes;
          break;
        case r'ipv6':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.ipv6 = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        SettingsCacheGet200ResponseDnsCacheEntriesValueAddressesBuilder();
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
