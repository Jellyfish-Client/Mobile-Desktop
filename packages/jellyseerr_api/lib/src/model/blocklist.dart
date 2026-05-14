//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:jellyseerr_api/src/model/media_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'blocklist.g.dart';

/// Blocklist
///
/// Properties:
/// * [tmdbId]
/// * [title]
/// * [media]
/// * [userId]
@BuiltValue()
abstract class Blocklist implements Built<Blocklist, BlocklistBuilder> {
  @BuiltValueField(wireName: r'tmdbId')
  num? get tmdbId;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'media')
  MediaInfo? get media;

  @BuiltValueField(wireName: r'userId')
  num? get userId;

  Blocklist._();

  factory Blocklist([void updates(BlocklistBuilder b)]) = _$Blocklist;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BlocklistBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Blocklist> get serializer => _$BlocklistSerializer();
}

class _$BlocklistSerializer implements PrimitiveSerializer<Blocklist> {
  @override
  final Iterable<Type> types = const [Blocklist, _$Blocklist];

  @override
  final String wireName = r'Blocklist';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Blocklist object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.tmdbId != null) {
      yield r'tmdbId';
      yield serializers.serialize(
        object.tmdbId,
        specifiedType: const FullType(num),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.media != null) {
      yield r'media';
      yield serializers.serialize(
        object.media,
        specifiedType: const FullType(MediaInfo),
      );
    }
    if (object.userId != null) {
      yield r'userId';
      yield serializers.serialize(
        object.userId,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    Blocklist object, {
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
    required BlocklistBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tmdbId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.tmdbId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'media':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MediaInfo),
          ) as MediaInfo;
          result.media.replace(valueDes);
          break;
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  Blocklist deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BlocklistBuilder();
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
