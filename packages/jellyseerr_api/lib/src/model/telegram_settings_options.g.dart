// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_settings_options.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TelegramSettingsOptions extends TelegramSettingsOptions {
  @override
  final String? botUsername;
  @override
  final String? botAPI;
  @override
  final String? chatId;
  @override
  final String? messageThreadId;
  @override
  final bool? sendSilently;

  factory _$TelegramSettingsOptions(
          [void Function(TelegramSettingsOptionsBuilder)? updates]) =>
      (TelegramSettingsOptionsBuilder()..update(updates))._build();

  _$TelegramSettingsOptions._(
      {this.botUsername,
      this.botAPI,
      this.chatId,
      this.messageThreadId,
      this.sendSilently})
      : super._();
  @override
  TelegramSettingsOptions rebuild(
          void Function(TelegramSettingsOptionsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TelegramSettingsOptionsBuilder toBuilder() =>
      TelegramSettingsOptionsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TelegramSettingsOptions &&
        botUsername == other.botUsername &&
        botAPI == other.botAPI &&
        chatId == other.chatId &&
        messageThreadId == other.messageThreadId &&
        sendSilently == other.sendSilently;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, botUsername.hashCode);
    _$hash = $jc(_$hash, botAPI.hashCode);
    _$hash = $jc(_$hash, chatId.hashCode);
    _$hash = $jc(_$hash, messageThreadId.hashCode);
    _$hash = $jc(_$hash, sendSilently.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TelegramSettingsOptions')
          ..add('botUsername', botUsername)
          ..add('botAPI', botAPI)
          ..add('chatId', chatId)
          ..add('messageThreadId', messageThreadId)
          ..add('sendSilently', sendSilently))
        .toString();
  }
}

class TelegramSettingsOptionsBuilder
    implements
        Builder<TelegramSettingsOptions, TelegramSettingsOptionsBuilder> {
  _$TelegramSettingsOptions? _$v;

  String? _botUsername;
  String? get botUsername => _$this._botUsername;
  set botUsername(String? botUsername) => _$this._botUsername = botUsername;

  String? _botAPI;
  String? get botAPI => _$this._botAPI;
  set botAPI(String? botAPI) => _$this._botAPI = botAPI;

  String? _chatId;
  String? get chatId => _$this._chatId;
  set chatId(String? chatId) => _$this._chatId = chatId;

  String? _messageThreadId;
  String? get messageThreadId => _$this._messageThreadId;
  set messageThreadId(String? messageThreadId) =>
      _$this._messageThreadId = messageThreadId;

  bool? _sendSilently;
  bool? get sendSilently => _$this._sendSilently;
  set sendSilently(bool? sendSilently) => _$this._sendSilently = sendSilently;

  TelegramSettingsOptionsBuilder() {
    TelegramSettingsOptions._defaults(this);
  }

  TelegramSettingsOptionsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _botUsername = $v.botUsername;
      _botAPI = $v.botAPI;
      _chatId = $v.chatId;
      _messageThreadId = $v.messageThreadId;
      _sendSilently = $v.sendSilently;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TelegramSettingsOptions other) {
    _$v = other as _$TelegramSettingsOptions;
  }

  @override
  void update(void Function(TelegramSettingsOptionsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TelegramSettingsOptions build() => _build();

  _$TelegramSettingsOptions _build() {
    final _$result = _$v ??
        _$TelegramSettingsOptions._(
          botUsername: botUsername,
          botAPI: botAPI,
          chatId: chatId,
          messageThreadId: messageThreadId,
          sendSilently: sendSilently,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
