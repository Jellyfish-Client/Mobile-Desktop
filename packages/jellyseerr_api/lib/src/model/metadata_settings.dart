//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:jellyseerr_api/src/model/metadata_settings_settings.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'metadata_settings.g.dart';

/// MetadataSettings
///
/// Properties:
/// * [settings]
@BuiltValue()
abstract class MetadataSettings
    implements Built<MetadataSettings, MetadataSettingsBuilder> {
  @BuiltValueField(wireName: r'settings')
  MetadataSettingsSettings? get settings;

  MetadataSettings._();

  factory MetadataSettings([void updates(MetadataSettingsBuilder b)]) =
      _$MetadataSettings;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MetadataSettingsBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MetadataSettings> get serializer =>
      _$MetadataSettingsSerializer();
}

class _$MetadataSettingsSerializer
    implements PrimitiveSerializer<MetadataSettings> {
  @override
  final Iterable<Type> types = const [MetadataSettings, _$MetadataSettings];

  @override
  final String wireName = r'MetadataSettings';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MetadataSettings object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.settings != null) {
      yield r'settings';
      yield serializers.serialize(
        object.settings,
        specifiedType: const FullType(MetadataSettingsSettings),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    MetadataSettings object, {
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
    required MetadataSettingsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'settings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MetadataSettingsSettings),
          ) as MetadataSettingsSettings;
          result.settings.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MetadataSettings deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MetadataSettingsBuilder();
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
