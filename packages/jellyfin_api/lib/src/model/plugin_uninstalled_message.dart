//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:jellyfin_api/src/model/session_message_type.dart';
import 'package:jellyfin_api/src/model/plugin_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'plugin_uninstalled_message.g.dart';

/// Plugin uninstalled message.
///
/// Properties:
/// * [data]
/// * [messageId] - Gets or sets the message id.
/// * [messageType]
@BuiltValue()
abstract class PluginUninstalledMessage
    implements
        Built<PluginUninstalledMessage, PluginUninstalledMessageBuilder> {
  @BuiltValueField(wireName: r'Data')
  PluginInfo? get data;

  /// Gets or sets the message id.
  @BuiltValueField(wireName: r'MessageId')
  String? get messageId;

  @BuiltValueField(wireName: r'MessageType')
  SessionMessageType? get messageType;
  // enum messageTypeEnum {  ForceKeepAlive,  GeneralCommand,  UserDataChanged,  Sessions,  Play,  SyncPlayCommand,  SyncPlayGroupUpdate,  Playstate,  RestartRequired,  ServerShuttingDown,  ServerRestarting,  LibraryChanged,  UserDeleted,  UserUpdated,  SeriesTimerCreated,  TimerCreated,  SeriesTimerCancelled,  TimerCancelled,  RefreshProgress,  ScheduledTaskEnded,  PackageInstallationCancelled,  PackageInstallationFailed,  PackageInstallationCompleted,  PackageInstalling,  PackageUninstalled,  ActivityLogEntry,  ScheduledTasksInfo,  ActivityLogEntryStart,  ActivityLogEntryStop,  SessionsStart,  SessionsStop,  ScheduledTasksInfoStart,  ScheduledTasksInfoStop,  KeepAlive,  };

  PluginUninstalledMessage._();

  factory PluginUninstalledMessage(
          [void updates(PluginUninstalledMessageBuilder b)]) =
      _$PluginUninstalledMessage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PluginUninstalledMessageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PluginUninstalledMessage> get serializer =>
      _$PluginUninstalledMessageSerializer();
}

class _$PluginUninstalledMessageSerializer
    implements PrimitiveSerializer<PluginUninstalledMessage> {
  @override
  final Iterable<Type> types = const [
    PluginUninstalledMessage,
    _$PluginUninstalledMessage
  ];

  @override
  final String wireName = r'PluginUninstalledMessage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PluginUninstalledMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'Data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(PluginInfo),
      );
    }
    if (object.messageId != null) {
      yield r'MessageId';
      yield serializers.serialize(
        object.messageId,
        specifiedType: const FullType(String),
      );
    }
    if (object.messageType != null) {
      yield r'MessageType';
      yield serializers.serialize(
        object.messageType,
        specifiedType: const FullType(SessionMessageType),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PluginUninstalledMessage object, {
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
    required PluginUninstalledMessageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'Data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PluginInfo),
          ) as PluginInfo;
          result.data.replace(valueDes);
          break;
        case r'MessageId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.messageId = valueDes;
          break;
        case r'MessageType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SessionMessageType),
          ) as SessionMessageType;
          result.messageType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PluginUninstalledMessage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PluginUninstalledMessageBuilder();
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
