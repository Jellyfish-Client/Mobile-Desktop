//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'override_rule.g.dart';

/// OverrideRule
///
/// Properties:
/// * [id]
@BuiltValue()
abstract class OverrideRule
    implements Built<OverrideRule, OverrideRuleBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  OverrideRule._();

  factory OverrideRule([void updates(OverrideRuleBuilder b)]) = _$OverrideRule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(OverrideRuleBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<OverrideRule> get serializer => _$OverrideRuleSerializer();
}

class _$OverrideRuleSerializer implements PrimitiveSerializer<OverrideRule> {
  @override
  final Iterable<Type> types = const [OverrideRule, _$OverrideRule];

  @override
  final String wireName = r'OverrideRule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    OverrideRule object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    OverrideRule object, {
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
    required OverrideRuleBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  OverrideRule deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = OverrideRuleBuilder();
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
