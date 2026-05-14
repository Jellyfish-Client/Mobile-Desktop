//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:jellyseerr_api/src/model/settings_cache_get200_response_dns_cache_entries_value_addresses.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'settings_cache_get200_response_dns_cache_entries_value.g.dart';

/// SettingsCacheGet200ResponseDnsCacheEntriesValue
///
/// Properties:
/// * [addresses]
/// * [activeAddress]
/// * [family]
/// * [age]
/// * [ttl]
/// * [networkErrors]
/// * [hits]
/// * [misses]
@BuiltValue()
abstract class SettingsCacheGet200ResponseDnsCacheEntriesValue
    implements
        Built<SettingsCacheGet200ResponseDnsCacheEntriesValue,
            SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder> {
  @BuiltValueField(wireName: r'addresses')
  SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses? get addresses;

  @BuiltValueField(wireName: r'activeAddress')
  String? get activeAddress;

  @BuiltValueField(wireName: r'family')
  num? get family;

  @BuiltValueField(wireName: r'age')
  num? get age;

  @BuiltValueField(wireName: r'ttl')
  num? get ttl;

  @BuiltValueField(wireName: r'networkErrors')
  num? get networkErrors;

  @BuiltValueField(wireName: r'hits')
  num? get hits;

  @BuiltValueField(wireName: r'misses')
  num? get misses;

  SettingsCacheGet200ResponseDnsCacheEntriesValue._();

  factory SettingsCacheGet200ResponseDnsCacheEntriesValue(
          [void updates(
              SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder b)]) =
      _$SettingsCacheGet200ResponseDnsCacheEntriesValue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SettingsCacheGet200ResponseDnsCacheEntriesValue>
      get serializer =>
          _$SettingsCacheGet200ResponseDnsCacheEntriesValueSerializer();
}

class _$SettingsCacheGet200ResponseDnsCacheEntriesValueSerializer
    implements
        PrimitiveSerializer<SettingsCacheGet200ResponseDnsCacheEntriesValue> {
  @override
  final Iterable<Type> types = const [
    SettingsCacheGet200ResponseDnsCacheEntriesValue,
    _$SettingsCacheGet200ResponseDnsCacheEntriesValue
  ];

  @override
  final String wireName = r'SettingsCacheGet200ResponseDnsCacheEntriesValue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SettingsCacheGet200ResponseDnsCacheEntriesValue object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.addresses != null) {
      yield r'addresses';
      yield serializers.serialize(
        object.addresses,
        specifiedType: const FullType(
            SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses),
      );
    }
    if (object.activeAddress != null) {
      yield r'activeAddress';
      yield serializers.serialize(
        object.activeAddress,
        specifiedType: const FullType(String),
      );
    }
    if (object.family != null) {
      yield r'family';
      yield serializers.serialize(
        object.family,
        specifiedType: const FullType(num),
      );
    }
    if (object.age != null) {
      yield r'age';
      yield serializers.serialize(
        object.age,
        specifiedType: const FullType(num),
      );
    }
    if (object.ttl != null) {
      yield r'ttl';
      yield serializers.serialize(
        object.ttl,
        specifiedType: const FullType(num),
      );
    }
    if (object.networkErrors != null) {
      yield r'networkErrors';
      yield serializers.serialize(
        object.networkErrors,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    SettingsCacheGet200ResponseDnsCacheEntriesValue object, {
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
    required SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'addresses':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses),
          ) as SettingsCacheGet200ResponseDnsCacheEntriesValueAddresses;
          result.addresses.replace(valueDes);
          break;
        case r'activeAddress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.activeAddress = valueDes;
          break;
        case r'family':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.family = valueDes;
          break;
        case r'age':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.age = valueDes;
          break;
        case r'ttl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.ttl = valueDes;
          break;
        case r'networkErrors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.networkErrors = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SettingsCacheGet200ResponseDnsCacheEntriesValue deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SettingsCacheGet200ResponseDnsCacheEntriesValueBuilder();
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
