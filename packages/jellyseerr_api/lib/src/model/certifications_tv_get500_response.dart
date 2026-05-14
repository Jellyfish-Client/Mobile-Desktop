//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'certifications_tv_get500_response.g.dart';

/// CertificationsTvGet500Response
///
/// Properties:
/// * [status]
/// * [message]
@BuiltValue()
abstract class CertificationsTvGet500Response
    implements
        Built<CertificationsTvGet500Response,
            CertificationsTvGet500ResponseBuilder> {
  @BuiltValueField(wireName: r'status')
  num? get status;

  @BuiltValueField(wireName: r'message')
  String? get message;

  CertificationsTvGet500Response._();

  factory CertificationsTvGet500Response(
          [void updates(CertificationsTvGet500ResponseBuilder b)]) =
      _$CertificationsTvGet500Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CertificationsTvGet500ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CertificationsTvGet500Response> get serializer =>
      _$CertificationsTvGet500ResponseSerializer();
}

class _$CertificationsTvGet500ResponseSerializer
    implements PrimitiveSerializer<CertificationsTvGet500Response> {
  @override
  final Iterable<Type> types = const [
    CertificationsTvGet500Response,
    _$CertificationsTvGet500Response
  ];

  @override
  final String wireName = r'CertificationsTvGet500Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CertificationsTvGet500Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.status != null) {
      yield r'status';
      yield serializers.serialize(
        object.status,
        specifiedType: const FullType(num),
      );
    }
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
    CertificationsTvGet500Response object, {
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
    required CertificationsTvGet500ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.status = valueDes;
          break;
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
  CertificationsTvGet500Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CertificationsTvGet500ResponseBuilder();
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
