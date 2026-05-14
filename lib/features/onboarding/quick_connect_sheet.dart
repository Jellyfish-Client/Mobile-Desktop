import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import 'quick_connect_controller.dart';

/// Bottom sheet that drives a Quick Connect flow. Pushed from the login
/// screen when the user picks the "Use a Quick Connect code" option.
class QuickConnectSheet extends ConsumerStatefulWidget {
  const QuickConnectSheet({required this.args, super.key});

  final QuickConnectArgs args;

  static Future<void> show(
    BuildContext context, {
    required QuickConnectArgs args,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => QuickConnectSheet(args: args),
    );
  }

  @override
  ConsumerState<QuickConnectSheet> createState() => _QuickConnectSheetState();
}

class _QuickConnectSheetState extends ConsumerState<QuickConnectSheet> {
  @override
  void initState() {
    super.initState();
    // Kick off the flow once the first frame is laid out so the controller has
    // a chance to publish QcLoading → the UI doesn't flash an empty state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(quickConnectControllerProvider.notifier).start(widget.args);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quickConnectControllerProvider);

    // Close the sheet automatically once the auth flow finishes — the router's
    // auth-aware redirect will route us to /home.
    ref.listen<QuickConnectState>(quickConnectControllerProvider, (prev, next) {
      if (next is QcDone && mounted) {
        Navigator.of(context).maybePop();
      }
    });

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.lg,
          bottom: AppSpacing.xl + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _grabHandle(context),
            const SizedBox(height: AppSpacing.lg),
            _Title(state: state),
            const SizedBox(height: AppSpacing.lg),
            _Body(state: state, args: widget.args),
            const SizedBox(height: AppSpacing.lg),
            _Actions(state: state),
          ],
        ),
      ),
    );
  }

  Widget _grabHandle(BuildContext context) => Center(
    child: Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _Title extends StatelessWidget {
  const _Title({required this.state});
  final QuickConnectState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final text = switch (state) {
      QcIdle() || QcLoading() => l10n.quickConnectTitle,
      QcPending() => l10n.quickConnectEnterCode,
      QcApproved() => l10n.quickConnectApproved,
      QcDone() => l10n.quickConnectDone,
      QcError() => l10n.quickConnectFailed,
      QcTimeout() => l10n.quickConnectExpired,
    };
    return Text(
      text,
      textAlign: TextAlign.center,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state, required this.args});
  final QuickConnectState state;
  final QuickConnectArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (state) {
      QcIdle() || QcLoading() => _CenteredSpinner(
        label: l10n.quickConnectGenerating,
      ),
      QcPending(code: final code) => _Pending(code: code, args: args),
      QcApproved() => _CenteredSpinner(label: l10n.quickConnectSigningIn),
      QcDone() => _CenteredCheck(label: l10n.quickConnectDone),
      QcError(message: final m) => _Message(icon: Icons.error_outline, text: m),
      QcTimeout() => _Message(
        icon: Icons.timer_off_outlined,
        text: l10n.quickConnectExpiredMessage,
      ),
    };
  }
}

class _Pending extends StatelessWidget {
  const _Pending({required this.code, required this.args});
  final String code;
  final QuickConnectArgs args;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serverLabel = args.serverName ?? 'your Jellyfin server';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        JfCard(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.lg,
          ),
          child: Column(
            children: [
              Text(
                _formatCode(code),
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.quickConnectCodeCopied),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 14),
                label: Text(context.l10n.quickConnectCopy),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          context.l10n.quickConnectInstruction(serverLabel),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              context.l10n.quickConnectWaiting,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCode(String code) {
    // Jellyfin codes are usually 6 chars — insert a space in the middle for
    // readability. Defensive against shorter/longer codes.
    if (code.length != 6) return code;
    return '${code.substring(0, 3)} ${code.substring(3)}';
  }
}

class _CenteredSpinner extends StatelessWidget {
  const _CenteredSpinner({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredCheck extends StatelessWidget {
  const _CenteredCheck({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.error, size: 36),
          const SizedBox(height: AppSpacing.md),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.state});
  final QuickConnectState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state) {
      QcDone() => const SizedBox.shrink(),
      QcError() || QcTimeout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JfButton.primary(
            label: context.l10n.quickConnectClose,
            onPressed: () => Navigator.of(context).maybePop(),
            fullWidth: true,
          ),
        ],
      ),
      _ => JfButton(
        label: context.l10n.onboardingCancel,
        variant: JfButtonVariant.ghost,
        fullWidth: true,
        onPressed: () {
          ref.read(quickConnectControllerProvider.notifier).cancel();
          Navigator.of(context).maybePop();
        },
      ),
    };
  }
}
