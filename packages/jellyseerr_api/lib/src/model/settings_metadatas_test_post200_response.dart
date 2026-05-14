//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'settings_metadatas_test_post200_response.g.dart';

/// SettingsMetadatasTestPost200Response
///
/// Properties:
/// * [message]
@BuiltValue()
abstract class SettingsMetadatasTestPost200Response
    implements
        Built<SettingsMetadatasTestPost200Response,
            SettingsMetadatasTestPost200ResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  String? get message;

  SettingsMetadatasTestPost200Response._();

  factory SettingsMetadatasTestPost200Response(
          [void updates(SettingsMetadatasTestPost200ResponseBuilder b)]) =
      _$SettingsMetadatasTestPost200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SettingsMetadatasTestPost200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SettingsMetadatasTestPost200Response> get serializer =>
      _$SettingsMetadatasTestPost200ResponseSerializer();
}

class _$SettingsMetadatasTestPost200ResponseSerializer
    implements PrimitiveSerializer<SettingsMetadatasTestPost200Response> {
  @override
  final Iterable<Type> types = const [
    SettingsMetadatasTestPost200Response,
    _$SettingsMetadatasTestPost200Response
  ];

  @override
  final String wireName = r'SettingsMetadatasTestPost200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SettingsMetadatasTestPost200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SettingsMetadatasTestPost200Response object, {
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
    required SettingsMetadatasTestPost200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SettingsMetadatasTestPost200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SettingsMetadatasTestPost200ResponseBuilder();
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
