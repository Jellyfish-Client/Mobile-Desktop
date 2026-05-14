import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/auth/accounts_repository.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/auth/saved_account.dart';
import '../../l10n/l10n_extension.dart';
import '../../shared/widgets/widgets.dart';
import '../onboarding/onboarding_controller.dart';
import 'widgets/account_avatar.dart';

/// Provider that exposes the list of known accounts. Refreshed whenever the
/// active session changes (add/switch/remove all flow through
/// [AuthController]).
final _accountsListProvider = FutureProvider.autoDispose<List<SavedAccount>>((
  ref,
) {
  ref.watch(authControllerProvider);
  return ref.read(accountsRepositoryProvider).readAll();
});

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activeSession = ref
        .watch(authControllerProvider)
        .valueOrNull
        ?.session;
    final accountsAsync = ref.watch(_accountsListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.accountsTitle)),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return _Empty(onAdd: () => _pushAddServer(context));
          }
          final grouped = _groupByServer(accounts);
          final serverCount = grouped.length;
          return ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              _SectionLabel(
                serverCount == 1
                    ? context.l10n.accountsMyServer
                    : context.l10n.accountsMyServers(serverCount),
              ),
              for (final entry in grouped.entries) ...[
                _ServerHeader(
                  serverName: entry.value.first.serverName,
                  serverUrl: entry.value.first.serverUrl,
                  onForgetServer: () => _confirmForgetServer(
                    context,
                    ref,
                    entry.value.first.serverName,
                    entry.value,
                  ),
                ),
                for (final account in entry.value)
                  _AccountTile(
                    account: account,
                    isActive:
                        activeSession?.serverId == account.serverId &&
                        activeSession?.userId == account.userId,
                    onTap: () => _switchTo(context, ref, account),
                    onRemove: () => _confirmRemove(context, ref, account),
                  ),
                _InlineAction(
                  icon: Icons.person_add_outlined,
                  label: context.l10n.accountsAddUser,
                  onTap: () => _pushAddUser(context, ref, entry.value.first),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              _SectionLabel(context.l10n.accountsOtherServer),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  0,
                ),
                child: JfButton.primary(
                  label: context.l10n.accountsAddServer,
                  icon: Icons.add,
                  fullWidth: true,
                  onPressed: () => _pushAddServer(context),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  context.l10n.accountsHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Groups accounts by server, preserving the input ordering (last-used first
  /// per group).
  Map<String, List<SavedAccount>> _groupByServer(List<SavedAccount> all) {
    final map = <String, List<SavedAccount>>{};
    for (final a in all) {
      map.putIfAbsent(a.serverId, () => []).add(a);
    }
    return map;
  }

  void _pushAddServer(BuildContext context) {
    context.push('/onboarding/server?add=1');
  }

  /// Add another user on a server we already know about — skip the URL probe
  /// step entirely and jump straight to the login form, with the server
  /// context pre-seeded into the onboarding controller.
  void _pushAddUser(
    BuildContext context,
    WidgetRef ref,
    SavedAccount serverSample,
  ) {
    ref.read(pendingServerProvider.notifier).state = PendingServer(
      url: serverSample.serverUrl,
      proxyAuth: serverSample.proxyAuth,
      serverName: serverSample.serverName,
      serverId: serverSample.serverId,
    );
    context.push('/login?add=1');
  }

  Future<void> _switchTo(
    BuildContext context,
    WidgetRef ref,
    SavedAccount account,
  ) async {
    await ref
        .read(authControllerProvider.notifier)
        .switchTo(serverId: account.serverId, userId: account.userId);
    if (context.mounted) context.go('/home');
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    SavedAccount account,
  ) async {
    final confirmed = await showJfConfirm(
      context,
      title: context.l10n.accountsDeleteTitle,
      message: context.l10n.accountsDeleteMessage(
        account.userName,
        account.serverName,
      ),
      confirmLabel: context.l10n.accountsDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await ref
        .read(authControllerProvider.notifier)
        .removeAccount(serverId: account.serverId, userId: account.userId);
  }

  Future<void> _confirmForgetServer(
    BuildContext context,
    WidgetRef ref,
    String serverName,
    List<SavedAccount> serverAccounts,
  ) async {
    final confirmed = await showJfConfirm(
      context,
      title: context.l10n.accountsForgetServerTitle(serverName),
      message: context.l10n.accountsForgetServerMessage(serverAccounts.length),
      confirmLabel: context.l10n.accountsForget,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await ref
        .read(authControllerProvider.notifier)
        .removeServer(serverAccounts.first.serverId);
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.accountsEmpty,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.accountsEmptyMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            JfButton.primary(
              label: context.l10n.accountsAddServer,
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xs,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _InlineAction extends StatelessWidget {
  const _InlineAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _ServerHeader extends StatelessWidget {
  const _ServerHeader({
    required this.serverName,
    required this.serverUrl,
    required this.onForgetServer,
  });

  final String serverName;
  final String serverUrl;
  final VoidCallback onForgetServer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = serverUrl
        .replaceAll(RegExp('^https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.dns_outlined,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serverName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  display,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: context.l10n.accountsForgetServer,
            onPressed: onForgetServer,
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.isActive,
    required this.onTap,
    required this.onRemove,
  });

  final SavedAccount account;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      leading: AccountAvatar(account: account, size: 40),
      title: Text(account.userName),
      subtitle: isActive
          ? Text(
              context.l10n.accountsActive,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            )
          : null,
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: scheme.onSurfaceVariant),
        tooltip: context.l10n.accountsRemove,
        onPressed: onRemove,
      ),
      onTap: isActive ? null : onTap,
      onLongPress: onRemove,
    );
  }
}
