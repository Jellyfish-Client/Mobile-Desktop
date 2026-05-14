import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';

enum _ErrorCategory {
  wrongCredentials,
  reverseProxy,
  authRequired,
  serverNotResponding,
  serverUnreachable,
  serverUnavailable,
  serverError,
  generic,
}

_ErrorCategory _classify(String message) {
  final m = message.toLowerCase();
  if (m.contains('invalid username or password')) {
    return _ErrorCategory.wrongCredentials;
  }
  if (m.contains('reverse proxy')) return _ErrorCategory.reverseProxy;
  if (m.contains('basic auth proxy') ||
      m.contains('http 401') ||
      m.contains('unauthorized')) {
    return _ErrorCategory.authRequired;
  }
  if (m.contains('did not respond') || m.contains('timeout')) {
    return _ErrorCategory.serverNotResponding;
  }
  if (m.contains('could not reach') ||
      m.contains('connection') ||
      m.contains('network')) {
    return _ErrorCategory.serverUnreachable;
  }
  if (m.contains('http') && (m.contains('502') || m.contains('503'))) {
    return _ErrorCategory.serverUnavailable;
  }
  if (m.contains('http')) return _ErrorCategory.serverError;
  return _ErrorCategory.generic;
}

IconData _categoryIcon(_ErrorCategory cat) => switch (cat) {
  _ErrorCategory.wrongCredentials => Icons.person_off_outlined,
  _ErrorCategory.reverseProxy => Icons.shield_outlined,
  _ErrorCategory.authRequired => Icons.lock_outline,
  _ErrorCategory.serverNotResponding => Icons.cloud_off_outlined,
  _ErrorCategory.serverUnreachable => Icons.cloud_off_outlined,
  _ErrorCategory.serverUnavailable => Icons.dns_outlined,
  _ErrorCategory.serverError => Icons.dns_outlined,
  _ErrorCategory.generic => Icons.error_outline,
};

/// Animated error panel shown above the form on onboarding screens.
///
/// Private to the `onboarding` feature — import via relative path only.
class OnboardingErrorPanel extends StatefulWidget {
  const OnboardingErrorPanel({
    required this.message,
    this.onDismiss,
    super.key,
  });

  final String message;
  final VoidCallback? onDismiss;

  @override
  State<OnboardingErrorPanel> createState() => _OnboardingErrorPanelState();
}

class _OnboardingErrorPanelState extends State<OnboardingErrorPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cat = _classify(widget.message);
    final l10n = context.l10n;

    final title = switch (cat) {
      _ErrorCategory.wrongCredentials => l10n.onboardingErrorWrongCredentials,
      _ErrorCategory.reverseProxy => l10n.onboardingErrorReverseProxy,
      _ErrorCategory.authRequired => l10n.onboardingErrorAuthRequired,
      _ErrorCategory.serverNotResponding =>
        l10n.onboardingErrorServerNotResponding,
      _ErrorCategory.serverUnreachable => l10n.onboardingErrorServerUnreachable,
      _ErrorCategory.serverUnavailable => l10n.onboardingErrorServerUnavailable,
      _ErrorCategory.serverError => l10n.onboardingErrorServerError,
      _ErrorCategory.generic => l10n.onboardingErrorGeneric,
    };

    final hint = switch (cat) {
      _ErrorCategory.wrongCredentials =>
        l10n.onboardingErrorWrongCredentialsHint,
      _ErrorCategory.reverseProxy => l10n.onboardingErrorReverseProxyHint,
      _ErrorCategory.serverNotResponding =>
        l10n.onboardingErrorServerNotRespondingHint,
      _ErrorCategory.serverUnreachable =>
        l10n.onboardingErrorServerUnreachableHint,
      _ErrorCategory.serverUnavailable =>
        l10n.onboardingErrorServerUnavailableHint,
      _ => null,
    };

    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: JfCard(
          color: scheme.errorContainer.withValues(alpha: 0.55),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_categoryIcon(cat), color: scheme.onErrorContainer, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.onErrorContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onErrorContainer.withValues(alpha: 0.8),
                      ),
                    ),
                    if (hint != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        hint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onErrorContainer.withValues(alpha: 0.65),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.onDismiss != null)
                GestureDetector(
                  onTap: widget.onDismiss,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: scheme.onErrorContainer.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
