//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_user_id_settings_linked_accounts_jellyfin_post_request.g.dart';

/// UserUserIdSettingsLinkedAccountsJellyfinPostRequest
///
/// Properties:
/// * [username]
/// * [password]
@BuiltValue()
abstract class UserUserIdSettingsLinkedAccountsJellyfinPostRequest
    implements
        Built<UserUserIdSettingsLinkedAccountsJellyfinPostRequest,
            UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder> {
  @BuiltValueField(wireName: r'username')
  String? get username;

  @BuiltValueField(wireName: r'password')
  String? get password;

  UserUserIdSettingsLinkedAccountsJellyfinPostRequest._();

  factory UserUserIdSettingsLinkedAccountsJellyfinPostRequest(
          [void updates(
              UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder b)]) =
      _$UserUserIdSettingsLinkedAccountsJellyfinPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserUserIdSettingsLinkedAccountsJellyfinPostRequest>
      get serializer =>
          _$UserUserIdSettingsLinkedAccountsJellyfinPostRequestSerializer();
}

class _$UserUserIdSettingsLinkedAccountsJellyfinPostRequestSerializer
    implements
        PrimitiveSerializer<
            UserUserIdSettingsLinkedAccountsJellyfinPostRequest> {
  @override
  final Iterable<Type> types = const [
    UserUserIdSettingsLinkedAccountsJellyfinPostRequest,
    _$UserUserIdSettingsLinkedAccountsJellyfinPostRequest
  ];

  @override
  final String wireName =
      r'UserUserIdSettingsLinkedAccountsJellyfinPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserUserIdSettingsLinkedAccountsJellyfinPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.username != null) {
      yield r'username';
      yield serializers.serialize(
        object.username,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    UserUserIdSettingsLinkedAccountsJellyfinPostRequest object, {
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
    required UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder result,
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
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserUserIdSettingsLinkedAccountsJellyfinPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserUserIdSettingsLinkedAccountsJellyfinPostRequestBuilder();
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
