// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'override_rule.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OverrideRule extends OverrideRule {
  @override
  final String? id;

  factory _$OverrideRule([void Function(OverrideRuleBuilder)? updates]) =>
      (OverrideRuleBuilder()..update(updates))._build();

  _$OverrideRule._({this.id}) : super._();
  @override
  OverrideRule rebuild(void Function(OverrideRuleBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OverrideRuleBuilder toBuilder() => OverrideRuleBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OverrideRule && id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OverrideRule')..add('id', id))
        .toString();
  }
}

class OverrideRuleBuilder
    implements Builder<OverrideRule, OverrideRuleBuilder> {
  _$OverrideRule? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  OverrideRuleBuilder() {
    OverrideRule._defaults(this);
  }

  OverrideRuleBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OverrideRule other) {
    _$v = other as _$OverrideRule;
  }

  @override
  void update(void Function(OverrideRuleBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OverrideRule build() => _build();

  _$OverrideRule _build() {
    final _$result = _$v ??
        _$OverrideRule._(
          id: id,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
