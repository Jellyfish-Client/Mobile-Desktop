import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '_error_panel.dart';
import 'onboarding_controller.dart';

class OnboardingServerScreen extends ConsumerStatefulWidget {
  const OnboardingServerScreen({super.key});

  @override
  ConsumerState<OnboardingServerScreen> createState() =>
      _OnboardingServerScreenState();
}

class _OnboardingServerScreenState extends ConsumerState<OnboardingServerScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  // Logo entrance animation
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoScale = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));
    _logoCtrl.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  bool get _isAddFlow =>
      GoRouterState.of(context).uri.queryParameters['add'] == '1';

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final probe = await ref
          .read(onboardingControllerProvider)
          .probe(_controller.text);
      ref.read(pendingServerProvider.notifier).state = PendingServer(
        url: probe.normalizedUrl,
        proxyAuth: probe.proxyAuth,
        serverName: probe.serverName,
        serverId: probe.serverId,
      );
      if (!mounted) return;
      context.go(_isAddFlow ? '/login?add=1' : '/login');
    } on OnboardingException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: (constraints.maxHeight * 0.08).clamp(
                  AppSpacing.xl,
                  AppSpacing.xxxl,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Header ---
                        FadeTransition(
                          opacity: _logoOpacity,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: const Center(child: JfLogo(size: 112)),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Jellyfish',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          context.l10n.onboardingConnect,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // --- Error panel (animated, sits above form) ---
                        if (_error != null) ...[
                          OnboardingErrorPanel(
                            message: _error!,
                            onDismiss: () => setState(() => _error = null),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // --- Form card ---
                        JfCard(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              JfTextField(
                                controller: _controller,
                                label: context.l10n.onboardingServerLabel,
                                hint: context.l10n.onboardingServerHint,
                                prefixIcon: Icons.dns_outlined,
                                keyboardType: TextInputType.url,
                                autocorrect: false,
                                enabled: !_busy,
                                textInputAction: TextInputAction.go,
                                onSubmitted: (_) => _continue(),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? context.l10n.onboardingServerRequired
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 12,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      context.l10n.onboardingServerTip,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant
                                                .withValues(alpha: 0.7),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // --- CTA ---
                        JfButton.primary(
                          label: context.l10n.onboardingContinue,
                          onPressed: _busy ? null : _continue,
                          loading: _busy,
                          fullWidth: true,
                          size: JfButtonSize.lg,
                          icon: Icons.arrow_forward,
                        ),
                        if (_isAddFlow) ...[
                          const SizedBox(height: AppSpacing.sm),
                          JfButton.ghost(
                            label: context.l10n.onboardingCancel,
                            onPressed: _busy
                                ? null
                                : () => context.go('/accounts'),
                            size: JfButtonSize.sm,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
