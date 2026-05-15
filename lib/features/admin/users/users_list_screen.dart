import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../shared/widgets/jf_async_scaffold.dart';
import 'users_providers.dart';

class AdminUsersListScreen extends ConsumerWidget {
  const AdminUsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.adminUsers)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/settings/admin/users/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(context.l10n.adminUsersAdd),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminUsersProvider.notifier).refresh(),
        child: JfAsyncScaffold(
          value: async,
          maxWidth: double.infinity,
          padding: EdgeInsets.zero,
          error: (e, _) => ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(context.l10n.adminErrorPrefix(e.toString())),
                ),
              ),
            ],
          ),
          data: (users) {
            if (users.isEmpty) {
              return Center(child: Text(context.l10n.adminUsersEmpty));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              itemCount: users.length,
              itemBuilder: (_, i) => _UserTile(user: users[i]),
            );
          },
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final UserDto user;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAdmin = user.policy?.isAdministrator ?? false;
    final isDisabled = user.policy?.isDisabled ?? false;
    final initial = (user.name ?? '?').characters.first.toUpperCase();

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: Text(initial),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(user.name ?? '—', overflow: TextOverflow.ellipsis),
          ),
          if (isAdmin) ...[
            const SizedBox(width: AppSpacing.sm),
            _Badge(
              label: context.l10n.adminUsersBadgeAdmin,
              color: scheme.primaryContainer,
              foreground: scheme.onPrimaryContainer,
            ),
          ],
          if (isDisabled) ...[
            const SizedBox(width: AppSpacing.sm),
            _Badge(
              label: context.l10n.adminUsersBadgeDisabled,
              color: scheme.errorContainer,
              foreground: scheme.onErrorContainer,
            ),
          ],
        ],
      ),
      subtitle: Text(
        user.lastActivityDate != null
            ? context.l10n.adminUsersSeenAt(_relative(user.lastActivityDate!))
            : context.l10n.adminUsersNeverConnected,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/settings/admin/users/${user.id}'),
    );
  }

  String _relative(DateTime when) {
    final d = DateTime.now().toUtc().difference(when.toUtc());
    if (d.inSeconds < 60) return 'il y a quelques secondes';
    if (d.inMinutes < 60) return 'il y a ${d.inMinutes} min';
    if (d.inHours < 24) return 'il y a ${d.inHours} h';
    if (d.inDays < 7) return 'il y a ${d.inDays} j';
    return 'le ${when.toLocal().toString().split(' ').first}';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.foreground,
  });

  final String label;
  final Color color;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
