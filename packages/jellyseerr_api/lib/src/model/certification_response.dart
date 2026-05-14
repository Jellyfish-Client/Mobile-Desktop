//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:jellyseerr_api/src/model/certification.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'certification_response.g.dart';

/// CertificationResponse
///
/// Properties:
/// * [certifications]
@BuiltValue()
abstract class CertificationResponse
    implements Built<CertificationResponse, CertificationResponseBuilder> {
  @BuiltValueField(wireName: r'certifications')
  BuiltMap<String, BuiltList<Certification>>? get certifications;

  CertificationResponse._();

  factory CertificationResponse(
      [void updates(CertificationResponseBuilder b)]) = _$CertificationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CertificationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CertificationResponse> get serializer =>
      _$CertificationResponseSerializer();
}

class _$CertificationResponseSerializer
    implements PrimitiveSerializer<CertificationResponse> {
  @override
  final Iterable<Type> types = const [
    CertificationResponse,
    _$CertificationResponse
  ];

  @override
  final String wireName = r'CertificationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CertificationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.certifications != null) {
      yield r'certifications';
      yield serializers.serialize(
        object.certifications,
        specifiedType: const FullType(BuiltMap, [
          FullType(String),
          FullType(BuiltList, [FullType(Certification)])
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CertificationResponse object, {
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
    required CertificationResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'certifications':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [
              FullType(String),
              FullType(BuiltList, [FullType(Certification)])
            ]),
          ) as BuiltMap<String, BuiltList<Certification>>;
          result.certifications.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CertificationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CertificationResponseBuilder();
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
