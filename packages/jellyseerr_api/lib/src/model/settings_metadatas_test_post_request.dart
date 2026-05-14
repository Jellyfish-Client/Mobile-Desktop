//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'settings_metadatas_test_post_request.g.dart';

/// SettingsMetadatasTestPostRequest
///
/// Properties:
/// * [tmdb]
/// * [tvdb]
@BuiltValue()
abstract class SettingsMetadatasTestPostRequest
    implements
        Built<SettingsMetadatasTestPostRequest,
            SettingsMetadatasTestPostRequestBuilder> {
  @BuiltValueField(wireName: r'tmdb')
  bool? get tmdb;

  @BuiltValueField(wireName: r'tvdb')
  bool? get tvdb;

  SettingsMetadatasTestPostRequest._();

  factory SettingsMetadatasTestPostRequest(
          [void updates(SettingsMetadatasTestPostRequestBuilder b)]) =
      _$SettingsMetadatasTestPostRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SettingsMetadatasTestPostRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SettingsMetadatasTestPostRequest> get serializer =>
      _$SettingsMetadatasTestPostRequestSerializer();
}

class _$SettingsMetadatasTestPostRequestSerializer
    implements PrimitiveSerializer<SettingsMetadatasTestPostRequest> {
  @override
  final Iterable<Type> types = const [
    SettingsMetadatasTestPostRequest,
    _$SettingsMetadatasTestPostRequest
  ];

  @override
  final String wireName = r'SettingsMetadatasTestPostRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SettingsMetadatasTestPostRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.tmdb != null) {
      yield r'tmdb';
      yield serializers.serialize(
        object.tmdb,
        specifiedType: const FullType(bool),
      );
    }
    if (object.tvdb != null) {
      yield r'tvdb';
      yield serializers.serialize(
        object.tvdb,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SettingsMetadatasTestPostRequest object, {
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
    required SettingsMetadatasTestPostRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tmdb':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.tmdb = valueDes;
          break;
        case r'tvdb':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.tvdb = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SettingsMetadatasTestPostRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SettingsMetadatasTestPostRequestBuilder();
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
