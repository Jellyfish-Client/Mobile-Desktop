//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'certification.g.dart';

/// Certification
///
/// Properties:
/// * [certification]
/// * [meaning]
/// * [order]
@BuiltValue()
abstract class Certification
    implements Built<Certification, CertificationBuilder> {
  @BuiltValueField(wireName: r'certification')
  String get certification;

  @BuiltValueField(wireName: r'meaning')
  String? get meaning;

  @BuiltValueField(wireName: r'order')
  num? get order;

  Certification._();

  factory Certification([void updates(CertificationBuilder b)]) =
      _$Certification;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CertificationBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Certification> get serializer =>
      _$CertificationSerializer();
}

class _$CertificationSerializer implements PrimitiveSerializer<Certification> {
  @override
  final Iterable<Type> types = const [Certification, _$Certification];

  @override
  final String wireName = r'Certification';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Certification object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'certification';
    yield serializers.serialize(
      object.certification,
      specifiedType: const FullType(String),
    );
    if (object.meaning != null) {
      yield r'meaning';
      yield serializers.serialize(
        object.meaning,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.order != null) {
      yield r'order';
      yield serializers.serialize(
        object.order,
        specifiedType: const FullType.nullable(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Certification object, {
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
    required CertificationBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'certification':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.certification = valueDes;
          break;
        case r'meaning':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.meaning = valueDes;
          break;
        case r'order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.order = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Certification deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CertificationBuilder();
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
