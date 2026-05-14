//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:jellyfin_api/src/model/session_message_type.dart';
import 'package:jellyfin_api/src/model/timer_event_info.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'timer_created_message.g.dart';

/// Timer created message.
///
/// Properties:
/// * [data]
/// * [messageId] - Gets or sets the message id.
/// * [messageType]
@BuiltValue()
abstract class TimerCreatedMessage
    implements Built<TimerCreatedMessage, TimerCreatedMessageBuilder> {
  @BuiltValueField(wireName: r'Data')
  TimerEventInfo? get data;

  /// Gets or sets the message id.
  @BuiltValueField(wireName: r'MessageId')
  String? get messageId;

  @BuiltValueField(wireName: r'MessageType')
  SessionMessageType? get messageType;
  // enum messageTypeEnum {  ForceKeepAlive,  GeneralCommand,  UserDataChanged,  Sessions,  Play,  SyncPlayCommand,  SyncPlayGroupUpdate,  Playstate,  RestartRequired,  ServerShuttingDown,  ServerRestarting,  LibraryChanged,  UserDeleted,  UserUpdated,  SeriesTimerCreated,  TimerCreated,  SeriesTimerCancelled,  TimerCancelled,  RefreshProgress,  ScheduledTaskEnded,  PackageInstallationCancelled,  PackageInstallationFailed,  PackageInstallationCompleted,  PackageInstalling,  PackageUninstalled,  ActivityLogEntry,  ScheduledTasksInfo,  ActivityLogEntryStart,  ActivityLogEntryStop,  SessionsStart,  SessionsStop,  ScheduledTasksInfoStart,  ScheduledTasksInfoStop,  KeepAlive,  };

  TimerCreatedMessage._();

  factory TimerCreatedMessage([void updates(TimerCreatedMessageBuilder b)]) =
      _$TimerCreatedMessage;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TimerCreatedMessageBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TimerCreatedMessage> get serializer =>
      _$TimerCreatedMessageSerializer();
}

class _$TimerCreatedMessageSerializer
    implements PrimitiveSerializer<TimerCreatedMessage> {
  @override
  final Iterable<Type> types = const [
    TimerCreatedMessage,
    _$TimerCreatedMessage
  ];

  @override
  final String wireName = r'TimerCreatedMessage';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TimerCreatedMessage object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.data != null) {
      yield r'Data';
      yield serializers.serialize(
        object.data,
        specifiedType: const FullType(TimerEventInfo),
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
    TimerCreatedMessage object, {
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
    required TimerCreatedMessageBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'Data':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(TimerEventInfo),
          ) as TimerEventInfo;
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
  TimerCreatedMessage deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TimerCreatedMessageBuilder();
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
