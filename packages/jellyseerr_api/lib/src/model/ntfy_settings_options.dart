//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'ntfy_settings_options.g.dart';

/// NtfySettingsOptions
///
/// Properties:
/// * [url]
/// * [topic]
/// * [authMethodUsernamePassword]
/// * [username]
/// * [password]
/// * [authMethodToken]
/// * [token]
@BuiltValue()
abstract class NtfySettingsOptions
    implements Built<NtfySettingsOptions, NtfySettingsOptionsBuilder> {
  @BuiltValueField(wireName: r'url')
  String? get url;

  @BuiltValueField(wireName: r'topic')
  String? get topic;

  @BuiltValueField(wireName: r'authMethodUsernamePassword')
  bool? get authMethodUsernamePassword;

  @BuiltValueField(wireName: r'username')
  String? get username;

  @BuiltValueField(wireName: r'password')
  String? get password;

  @BuiltValueField(wireName: r'authMethodToken')
  bool? get authMethodToken;

  @BuiltValueField(wireName: r'token')
  String? get token;

  NtfySettingsOptions._();

  factory NtfySettingsOptions([void updates(NtfySettingsOptionsBuilder b)]) =
      _$NtfySettingsOptions;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NtfySettingsOptionsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NtfySettingsOptions> get serializer =>
      _$NtfySettingsOptionsSerializer();
}

class _$NtfySettingsOptionsSerializer
    implements PrimitiveSerializer<NtfySettingsOptions> {
  @override
  final Iterable<Type> types = const [
    NtfySettingsOptions,
    _$NtfySettingsOptions
  ];

  @override
  final String wireName = r'NtfySettingsOptions';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NtfySettingsOptions object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.url != null) {
      yield r'url';
      yield serializers.serialize(
        object.url,
        specifiedType: const FullType(String),
      );
    }
    if (object.topic != null) {
      yield r'topic';
      yield serializers.serialize(
        object.topic,
        specifiedType: const FullType(String),
      );
    }
    if (object.authMethodUsernamePassword != null) {
      yield r'authMethodUsernamePassword';
      yield serializers.serialize(
        object.authMethodUsernamePassword,
        specifiedType: const FullType(bool),
      );
    }
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
    if (object.authMethodToken != null) {
      yield r'authMethodToken';
      yield serializers.serialize(
        object.authMethodToken,
        specifiedType: const FullType(bool),
      );
    }
    if (object.token != null) {
      yield r'token';
      yield serializers.serialize(
        object.token,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    NtfySettingsOptions object, {
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
    required NtfySettingsOptionsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'topic':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.topic = valueDes;
          break;
        case r'authMethodUsernamePassword':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.authMethodUsernamePassword = valueDes;
          break;
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
        case r'authMethodToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.authMethodToken = valueDes;
          break;
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NtfySettingsOptions deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NtfySettingsOptionsBuilder();
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
