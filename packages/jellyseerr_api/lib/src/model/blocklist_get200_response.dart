//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:jellyseerr_api/src/model/blocklist_get200_response_results_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:jellyseerr_api/src/model/page_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'blocklist_get200_response.g.dart';

/// BlocklistGet200Response
///
/// Properties:
/// * [pageInfo]
/// * [results]
@BuiltValue()
abstract class BlocklistGet200Response
    implements Built<BlocklistGet200Response, BlocklistGet200ResponseBuilder> {
  @BuiltValueField(wireName: r'pageInfo')
  PageInfo? get pageInfo;

  @BuiltValueField(wireName: r'results')
  BuiltList<BlocklistGet200ResponseResultsInner>? get results;

  BlocklistGet200Response._();

  factory BlocklistGet200Response(
          [void updates(BlocklistGet200ResponseBuilder b)]) =
      _$BlocklistGet200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BlocklistGet200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BlocklistGet200Response> get serializer =>
      _$BlocklistGet200ResponseSerializer();
}

class _$BlocklistGet200ResponseSerializer
    implements PrimitiveSerializer<BlocklistGet200Response> {
  @override
  final Iterable<Type> types = const [
    BlocklistGet200Response,
    _$BlocklistGet200Response
  ];

  @override
  final String wireName = r'BlocklistGet200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BlocklistGet200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.pageInfo != null) {
      yield r'pageInfo';
      yield serializers.serialize(
        object.pageInfo,
        specifiedType: const FullType(PageInfo),
      );
    }
    if (object.results != null) {
      yield r'results';
      yield serializers.serialize(
        object.results,
        specifiedType: const FullType(
            BuiltList, [FullType(BlocklistGet200ResponseResultsInner)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BlocklistGet200Response object, {
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
    required BlocklistGet200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'pageInfo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PageInfo),
          ) as PageInfo;
          result.pageInfo.replace(valueDes);
          break;
        case r'results':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(BlocklistGet200ResponseResultsInner)]),
          ) as BuiltList<BlocklistGet200ResponseResultsInner>;
          result.results.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BlocklistGet200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BlocklistGet200ResponseBuilder();
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
