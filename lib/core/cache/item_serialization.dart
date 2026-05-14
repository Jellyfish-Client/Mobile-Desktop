import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

const _baseItemListType = FullType(BuiltList, [FullType(BaseItemDto)]);

/// Encodes a list of [BaseItemDto] for disk storage. Uses the package's
/// `standardSerializers` (built_value + StandardJsonPlugin) so the on-disk
/// payload mirrors exactly what the server emits — no custom field mapping
/// that could drift out of sync with the OpenAPI schema.
String encodeBaseItemList(List<BaseItemDto> items) {
  final serialized = standardSerializers.serialize(
    BuiltList<BaseItemDto>.from(items),
    specifiedType: _baseItemListType,
  );
  return jsonEncode(serialized);
}

/// Decodes a payload previously produced by [encodeBaseItemList]. Returns
/// `null` if the payload is unparseable so callers can transparently fall
/// back to a fresh network fetch instead of surfacing the error.
List<BaseItemDto>? tryDecodeBaseItemList(String payload) {
  try {
    final decoded = jsonDecode(payload);
    final result =
        standardSerializers.deserialize(
              decoded,
              specifiedType: _baseItemListType,
            )!
            as BuiltList<BaseItemDto>;
    return result.toList();
  } on Object {
    return null;
  }
}
