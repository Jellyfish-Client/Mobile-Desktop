//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:jellyseerr_api/src/model/user.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'blocklist_get200_response_results_inner.g.dart';

/// BlocklistGet200ResponseResultsInner
///
/// Properties:
/// * [user]
/// * [createdAt]
/// * [id]
/// * [mediaType]
/// * [title]
/// * [tmdbId]
@BuiltValue()
abstract class BlocklistGet200ResponseResultsInner
    implements
        Built<BlocklistGet200ResponseResultsInner,
            BlocklistGet200ResponseResultsInnerBuilder> {
  @BuiltValueField(wireName: r'user')
  User? get user;

  @BuiltValueField(wireName: r'createdAt')
  String? get createdAt;

  @BuiltValueField(wireName: r'id')
  num? get id;

  @BuiltValueField(wireName: r'mediaType')
  String? get mediaType;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'tmdbId')
  num? get tmdbId;

  BlocklistGet200ResponseResultsInner._();

  factory BlocklistGet200ResponseResultsInner(
          [void updates(BlocklistGet200ResponseResultsInnerBuilder b)]) =
      _$BlocklistGet200ResponseResultsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BlocklistGet200ResponseResultsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BlocklistGet200ResponseResultsInner> get serializer =>
      _$BlocklistGet200ResponseResultsInnerSerializer();
}

class _$BlocklistGet200ResponseResultsInnerSerializer
    implements PrimitiveSerializer<BlocklistGet200ResponseResultsInner> {
  @override
  final Iterable<Type> types = const [
    BlocklistGet200ResponseResultsInner,
    _$BlocklistGet200ResponseResultsInner
  ];

  @override
  final String wireName = r'BlocklistGet200ResponseResultsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BlocklistGet200ResponseResultsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.user != null) {
      yield r'user';
      yield serializers.serialize(
        object.user,
        specifiedType: const FullType(User),
      );
    }
    if (object.createdAt != null) {
      yield r'createdAt';
      yield serializers.serialize(
        object.createdAt,
        specifiedType: const FullType(String),
      );
    }
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(num),
      );
    }
    if (object.mediaType != null) {
      yield r'mediaType';
      yield serializers.serialize(
        object.mediaType,
        specifiedType: const FullType(String),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.tmdbId != null) {
      yield r'tmdbId';
      yield serializers.serialize(
        object.tmdbId,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BlocklistGet200ResponseResultsInner object, {
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
    required BlocklistGet200ResponseResultsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(User),
          ) as User;
          result.user.replace(valueDes);
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.createdAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.id = valueDes;
          break;
        case r'mediaType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mediaType = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'tmdbId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.tmdbId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BlocklistGet200ResponseResultsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BlocklistGet200ResponseResultsInnerBuilder();
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
