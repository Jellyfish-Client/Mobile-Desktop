//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'settings_jellyfin_users_get200_response_inner.g.dart';

/// SettingsJellyfinUsersGet200ResponseInner
///
/// Properties:
/// * [username]
/// * [id]
/// * [thumb]
/// * [email]
@BuiltValue()
abstract class SettingsJellyfinUsersGet200ResponseInner
    implements
        Built<SettingsJellyfinUsersGet200ResponseInner,
            SettingsJellyfinUsersGet200ResponseInnerBuilder> {
  @BuiltValueField(wireName: r'username')
  String? get username;

  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'thumb')
  String? get thumb;

  @BuiltValueField(wireName: r'email')
  String? get email;

  SettingsJellyfinUsersGet200ResponseInner._();

  factory SettingsJellyfinUsersGet200ResponseInner(
          [void updates(SettingsJellyfinUsersGet200ResponseInnerBuilder b)]) =
      _$SettingsJellyfinUsersGet200ResponseInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SettingsJellyfinUsersGet200ResponseInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SettingsJellyfinUsersGet200ResponseInner> get serializer =>
      _$SettingsJellyfinUsersGet200ResponseInnerSerializer();
}

class _$SettingsJellyfinUsersGet200ResponseInnerSerializer
    implements PrimitiveSerializer<SettingsJellyfinUsersGet200ResponseInner> {
  @override
  final Iterable<Type> types = const [
    SettingsJellyfinUsersGet200ResponseInner,
    _$SettingsJellyfinUsersGet200ResponseInner
  ];

  @override
  final String wireName = r'SettingsJellyfinUsersGet200ResponseInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SettingsJellyfinUsersGet200ResponseInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    if (object.thumb != null) {
      yield r'thumb';
      yield serializers.serialize(
        object.thumb,
        specifiedType: const FullType(String),
      );
    }
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SettingsJellyfinUsersGet200ResponseInner object, {
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
    required SettingsJellyfinUsersGet200ResponseInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'thumb':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.thumb = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SettingsJellyfinUsersGet200ResponseInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SettingsJellyfinUsersGet200ResponseInnerBuilder();
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
