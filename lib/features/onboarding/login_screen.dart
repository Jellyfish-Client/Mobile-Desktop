import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/auth/accounts_repository.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/jellyfin/jellyfin_client.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '_error_panel.dart';
import 'onboarding_controller.dart';
import 'quick_connect_controller.dart';
import 'quick_connect_sheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  /// Future that resolves to whether the current target server has Quick
  /// Connect enabled. Lazily computed once the [PendingServer] is known so we
  /// don't fire the request before we have a base URL.
  Future<bool>? _qcEnabledFuture;
  String? _qcCheckedFor;

  // Header entrance animation
  late final AnimationController _headerCtrl;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _headerOpacity = CurvedAnimation(
      parent: _headerCtrl,
      curve: Curves.easeOut,
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerCtrl.forward();

    // The reauth params point at an existing SavedAccount. Resolve it back to
    // a PendingServer so the rest of the screen behaves as a normal login.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_hydrateFromReauth());
    });
  }

  Future<void> _hydrateFromReauth() async {
    final params = GoRouterState.of(context).uri.queryParameters;
    if (params['reauth'] != '1') return;
    final serverId = params['serverId'];
    final userId = params['userId'];
    if (serverId == null || userId == null) return;

    final accounts = await ref.read(accountsRepositoryProvider).readAll();
    final acc = accounts.firstWhereOrNull(
      (a) => a.serverId == serverId && a.userId == userId,
    );
    if (acc == null || !mounted) return;

    ref.read(pendingServerProvider.notifier).state = PendingServer(
      url: acc.serverUrl,
      proxyAuth: acc.proxyAuth,
      serverName: acc.serverName,
      serverId: acc.serverId,
    );
    setState(() {
      if (_userController.text.isEmpty) _userController.text = acc.userName;
    });
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  bool get _isAddFlow =>
      GoRouterState.of(context).uri.queryParameters['add'] == '1';

  bool get _isReauth =>
      GoRouterState.of(context).uri.queryParameters['reauth'] == '1';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final pending = ref.read(pendingServerProvider);
    if (pending == null) {
      context.go('/onboarding/server');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await ref
          .read(onboardingControllerProvider)
          .login(
            serverUrl: pending.url,
            username: _userController.text.trim(),
            password: _passController.text,
            proxyAuth: pending.proxyAuth,
            serverName: pending.serverName,
            serverId: pending.serverId,
          );
      if (mounted && _isAddFlow) context.go('/accounts');
    } on OnboardingException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openQuickConnect(PendingServer pending) async {
    if (_busy) return;
    final beforeKey = ref
        .read(authControllerProvider)
        .valueOrNull
        ?.session
        ?.userId;
    await QuickConnectSheet.show(
      context,
      args: QuickConnectArgs(
        serverUrl: pending.url,
        proxyAuth: pending.proxyAuth,
        serverName: pending.serverName,
        serverId: pending.serverId,
      ),
    );
    if (!mounted) return;
    final afterKey = ref
        .read(authControllerProvider)
        .valueOrNull
        ?.session
        ?.userId;
    // Only route on real success (active session changed). Cancellation or
    // error leaves the session untouched — in which case we stay on /login.
    // For the normal (non-add) flow, the router's redirect picks up the new
    // session and moves us to /home; the add-flow has to navigate explicitly
    // because the redirect leaves `/login?add=1` alone.
    if (afterKey != null && afterKey != beforeKey && _isAddFlow) {
      context.go('/accounts');
    }
  }

  Future<bool> _ensureQcCheck(PendingServer pending) {
    if (_qcCheckedFor != pending.url) {
      _qcCheckedFor = pending.url;
      _qcEnabledFuture = ref
          .read(jellyfinClientProvider)
          .isQuickConnectEnabled(
            serverUrl: pending.url,
            proxyAuth: pending.proxyAuth,
          );
    }
    return _qcEnabledFuture ?? Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingServerProvider);
    final theme = Theme.of(context);

    // Strip scheme for display — keep it concise in the chip
    final displayUrl =
        pending?.url
            .replaceAll(RegExp('^https?://'), '')
            .replaceAll(RegExp(r'/$'), '') ??
        '';

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
                        SlideTransition(
                          position: _headerSlide,
                          child: FadeTransition(
                            opacity: _headerOpacity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Server chip + Change link
                                if (displayUrl.isNotEmpty)
                                  Row(
                                    children: [
                                      JfChip(
                                        label: displayUrl,
                                        icon: Icons.dns_outlined,
                                        tone: JfChipTone.brand,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      if (!_isReauth)
                                        GestureDetector(
                                          onTap: _busy
                                              ? null
                                              : () => context.go(
                                                  _isAddFlow
                                                      ? '/onboarding/server?add=1'
                                                      : '/onboarding/server',
                                                ),
                                          child: Text(
                                            context.l10n.onboardingChange,
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  _isReauth
                                      ? context.l10n.onboardingSessionExpired
                                      : context.l10n.onboardingWelcomeBack,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _isReauth
                                      ? context.l10n.onboardingSessionExpiredSubtitle
                                      : context.l10n.onboardingSignInSubtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // --- Error panel ---
                        if (_error != null) ...[
                          OnboardingErrorPanel(
                            key: ValueKey(_error),
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
                                controller: _userController,
                                label: context.l10n.onboardingUsername,
                                hint: context.l10n.onboardingUsernameHint,
                                prefixIcon: Icons.person_outline,
                                enabled: !_busy && !_isReauth,
                                textInputAction: TextInputAction.next,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? context.l10n.onboardingServerRequired
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              JfPasswordField(
                                controller: _passController,
                                label: context.l10n.onboardingPassword,
                                enabled: !_busy,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _login(),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? context.l10n.onboardingServerRequired
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // --- CTAs ---
                        JfButton.primary(
                          label: context.l10n.onboardingSignIn,
                          onPressed: _busy ? null : _login,
                          loading: _busy,
                          fullWidth: true,
                          size: JfButtonSize.lg,
                          icon: Icons.login,
                        ),
                        if (pending != null)
                          _QuickConnectButton(
                            futureBuilder: () => _ensureQcCheck(pending),
                            onTap: _busy
                                ? null
                                : () => _openQuickConnect(pending),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        if (!_isReauth)
                          JfButton.ghost(
                            label: context.l10n.onboardingChangeServer,
                            onPressed: _busy
                                ? null
                                : () => context.go(
                                    _isAddFlow
                                        ? '/onboarding/server?add=1'
                                        : '/onboarding/server',
                                  ),
                            icon: Icons.arrow_back,
                            size: JfButtonSize.sm,
                          )
                        else
                          JfButton.ghost(
                            label: context.l10n.onboardingCancel,
                            onPressed: _busy
                                ? null
                                : () => context.go(
                                    _isAddFlow ? '/accounts' : '/home',
                                  ),
                            size: JfButtonSize.sm,
                          ),
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

class _QuickConnectButton extends StatelessWidget {
  const _QuickConnectButton({required this.futureBuilder, required this.onTap});

  final Future<bool> Function() futureBuilder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: futureBuilder(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: JfButton(
            label: context.l10n.onboardingQuickConnect,
            variant: JfButtonVariant.secondary,
            fullWidth: true,
            icon: Icons.bolt_outlined,
            onPressed: onTap,
          ),
        );
      },
    );
  }
}

extension _IterableX<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
