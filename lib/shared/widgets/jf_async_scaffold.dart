import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import 'empty_state.dart';

/// Standardised scaffold for the [AsyncValue] → loading / error / empty / data
/// pattern that is duplicated across the admin modules and most feature
/// screens.
///
/// Provides sensible fallbacks aligned with the Jellyfish design system:
///   * `loading` → centred [CircularProgressIndicator]
///   * `error`   → [EmptyState] (`error_outline`, localised title, raw error
///     message)
///   * `empty`   → [EmptyState] (`inbox_outlined`, localised title)
///   * `data`    → child wrapped in a centred `ConstrainedBox(maxWidth:…)`
///     with an optional [padding].
///
/// The widget is intentionally lean: it does not own retry/refresh logic —
/// callers wire their own `RefreshIndicator` / button via the `error` /
/// `empty` slots when needed.
class JfAsyncScaffold<T> extends StatelessWidget {
  const JfAsyncScaffold({
    required this.value,
    required this.data,
    this.error,
    this.empty,
    this.isEmpty,
    this.maxWidth = 800,
    this.padding,
    this.loading,
    super.key,
  });

  /// Async source to render.
  final AsyncValue<T> value;

  /// Builder for the success state.
  final Widget Function(T data) data;

  /// Optional builder for the error state. When `null`, an [EmptyState] with
  /// the localised generic error title is shown.
  final Widget Function(Object error, StackTrace stack)? error;

  /// Optional override for the empty state. When `null`, an [EmptyState] with
  /// the localised generic empty title is shown.
  final Widget? empty;

  /// Optional predicate to determine whether [data] should be treated as an
  /// empty state. When `null`, the data state is never considered empty.
  final bool Function(T data)? isEmpty;

  /// Maximum content width applied to the data state. Defaults to 800 to
  /// match the admin modules' reading width.
  final double maxWidth;

  /// Padding wrapped around the data state. Defaults to a comfortable inset.
  final EdgeInsetsGeometry? padding;

  /// Optional override for the loading state.
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () =>
          loading ?? const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        if (error != null) return error!(err, stack);
        return EmptyState(
          icon: Icons.error_outline,
          title: context.l10n.commonErrorTitle,
          message: err.toString(),
        );
      },
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return empty ??
              EmptyState(
                icon: Icons.inbox_outlined,
                title: context.l10n.commonEmptyTitle,
              );
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding:
                  padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: data(d),
            ),
          ),
        );
      },
    );
  }
}
