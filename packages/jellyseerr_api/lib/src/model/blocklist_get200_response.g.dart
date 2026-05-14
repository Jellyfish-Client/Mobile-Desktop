// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocklist_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BlocklistGet200Response extends BlocklistGet200Response {
  @override
  final PageInfo? pageInfo;
  @override
  final BuiltList<BlocklistGet200ResponseResultsInner>? results;

  factory _$BlocklistGet200Response(
          [void Function(BlocklistGet200ResponseBuilder)? updates]) =>
      (BlocklistGet200ResponseBuilder()..update(updates))._build();

  _$BlocklistGet200Response._({this.pageInfo, this.results}) : super._();
  @override
  BlocklistGet200Response rebuild(
          void Function(BlocklistGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BlocklistGet200ResponseBuilder toBuilder() =>
      BlocklistGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BlocklistGet200Response &&
        pageInfo == other.pageInfo &&
        results == other.results;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, pageInfo.hashCode);
    _$hash = $jc(_$hash, results.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BlocklistGet200Response')
          ..add('pageInfo', pageInfo)
          ..add('results', results))
        .toString();
  }
}

class BlocklistGet200ResponseBuilder
    implements
        Builder<BlocklistGet200Response, BlocklistGet200ResponseBuilder> {
  _$BlocklistGet200Response? _$v;

  PageInfoBuilder? _pageInfo;
  PageInfoBuilder get pageInfo => _$this._pageInfo ??= PageInfoBuilder();
  set pageInfo(PageInfoBuilder? pageInfo) => _$this._pageInfo = pageInfo;

  ListBuilder<BlocklistGet200ResponseResultsInner>? _results;
  ListBuilder<BlocklistGet200ResponseResultsInner> get results =>
      _$this._results ??= ListBuilder<BlocklistGet200ResponseResultsInner>();
  set results(ListBuilder<BlocklistGet200ResponseResultsInner>? results) =>
      _$this._results = results;

  BlocklistGet200ResponseBuilder() {
    BlocklistGet200Response._defaults(this);
  }

  BlocklistGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _pageInfo = $v.pageInfo?.toBuilder();
      _results = $v.results?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BlocklistGet200Response other) {
    _$v = other as _$BlocklistGet200Response;
  }

  @override
  void update(void Function(BlocklistGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BlocklistGet200Response build() => _build();

  _$BlocklistGet200Response _build() {
    _$BlocklistGet200Response _$result;
    try {
      _$result = _$v ??
          _$BlocklistGet200Response._(
            pageInfo: _pageInfo?.build(),
            results: _results?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'pageInfo';
        _pageInfo?.build();
        _$failedField = 'results';
        _results?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BlocklistGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
