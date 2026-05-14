//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'keyword_keyword_id_get500_response.g.dart';

/// KeywordKeywordIdGet500Response
///
/// Properties:
/// * [message]
@BuiltValue()
abstract class KeywordKeywordIdGet500Response
    implements
        Built<KeywordKeywordIdGet500Response,
            KeywordKeywordIdGet500ResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  String? get message;

  KeywordKeywordIdGet500Response._();

  factory KeywordKeywordIdGet500Response(
          [void updates(KeywordKeywordIdGet500ResponseBuilder b)]) =
      _$KeywordKeywordIdGet500Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(KeywordKeywordIdGet500ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<KeywordKeywordIdGet500Response> get serializer =>
      _$KeywordKeywordIdGet500ResponseSerializer();
}

class _$KeywordKeywordIdGet500ResponseSerializer
    implements PrimitiveSerializer<KeywordKeywordIdGet500Response> {
  @override
  final Iterable<Type> types = const [
    KeywordKeywordIdGet500Response,
    _$KeywordKeywordIdGet500Response
  ];

  @override
  final String wireName = r'KeywordKeywordIdGet500Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    KeywordKeywordIdGet500Response object, {
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
    KeywordKeywordIdGet500Response object, {
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
    required KeywordKeywordIdGet500ResponseBuilder result,
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
  KeywordKeywordIdGet500Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = KeywordKeywordIdGet500ResponseBuilder();
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
