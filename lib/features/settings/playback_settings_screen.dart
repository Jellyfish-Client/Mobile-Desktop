import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jellyfin_api/jellyfin_api.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/jellyfin/jellyfin_client.dart';
import '../../l10n/l10n_extension.dart';
import 'playback_settings_providers.dart';
import 'widgets/settings_section.dart';

class PlaybackSettingsScreen extends ConsumerWidget {
  const PlaybackSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(playbackConfigProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsPlaybackTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(playbackConfigProvider);
          await ref.read(playbackConfigProvider.future);
        },
        child: configAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 96),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(context.l10n.errorFailed('$e')),
                ),
              ),
            ],
          ),
          data: (cfg) => _PlaybackSettings(config: cfg),
        ),
      ),
    );
  }
}

class _PlaybackSettings extends ConsumerStatefulWidget {
  const _PlaybackSettings({required this.config});

  final UserConfiguration config;

  @override
  ConsumerState<_PlaybackSettings> createState() => _PlaybackSettingsState();
}

class _PlaybackSettingsState extends ConsumerState<_PlaybackSettings> {
  late UserConfiguration _local;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _local = widget.config;
  }

  /// Optimistic write: mutate local state immediately, POST the full
  /// UserConfiguration to the server, rollback on failure so the user sees
  /// the actual server state again. Reentrancy guarded by [_busy] — a second
  /// tap while a POST is in flight is dropped, so we don't end up with two
  /// concurrent writes racing for `_local` and conflicting rollbacks.
  Future<void> _apply(
    void Function(UserConfigurationBuilder) edit,
    String successMessage,
  ) async {
    if (_busy) return;
    final previous = _local;
    final next = _local.rebuild(edit);
    setState(() {
      _local = next;
      _busy = true;
    });
    final userId =
        ref.read(authControllerProvider).valueOrNull?.session?.userId;
    if (userId == null) {
      setState(() => _busy = false);
      return;
    }
    try {
      await ref.read(jellyfinApiProvider).getUserApi().updateUserConfiguration(
        userId: userId,
        userConfiguration: next,
      );
      // Sync the cached provider so a navigation back / refresh sees fresh.
      ref.invalidate(playbackConfigProvider);
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _local = previous;
        _busy = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorFailed('$e'))),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        SettingsSection(
          label: l10n.playbackLanguages,
          tiles: [
            ListTile(
              leading: const Icon(Icons.record_voice_over_outlined),
              title: Text(l10n.playbackAudioLanguage),
              subtitle: Text(_languageLabel(_local.audioLanguagePreference)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickLanguage(
                title: l10n.playbackAudioLanguage,
                current: _local.audioLanguagePreference,
                onPicked: (code) => _apply(
                  (b) => b..audioLanguagePreference = code,
                  l10n.playbackAudioLanguageUpdated,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.subtitles_outlined),
              title: Text(l10n.playbackSubtitleLanguage),
              subtitle: Text(_languageLabel(_local.subtitleLanguagePreference)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickLanguage(
                title: l10n.playbackSubtitleLanguage,
                current: _local.subtitleLanguagePreference,
                onPicked: (code) => _apply(
                  (b) => b..subtitleLanguagePreference = code,
                  l10n.playbackSubtitleLanguageUpdated,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.closed_caption_outlined),
              title: Text(l10n.playbackSubtitleMode),
              subtitle: Text(_subtitleModeLabel(_local.subtitleMode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickSubtitleMode,
            ),
          ],
        ),
        SettingsSection(
          label: l10n.playbackBehavior,
          tiles: [
            SwitchListTile(
              secondary: const Icon(Icons.skip_next_outlined),
              title: Text(l10n.playbackAutoNextEpisode),
              value: _local.enableNextEpisodeAutoPlay ?? true,
              onChanged: (v) => _apply(
                (b) => b..enableNextEpisodeAutoPlay = v,
                v
                    ? l10n.playbackAutoPlayEnabled
                    : l10n.playbackAutoPlayDisabled,
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.music_note_outlined),
              title: Text(l10n.playbackDefaultAudioTrack),
              subtitle: Text(l10n.playbackDefaultAudioTrackDescription),
              value: _local.playDefaultAudioTrack ?? true,
              onChanged: (v) => _apply(
                (b) => b..playDefaultAudioTrack = v,
                l10n.playbackPreferenceSaved,
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.history),
              title: Text(l10n.playbackRememberAudioSelections),
              value: _local.rememberAudioSelections ?? true,
              onChanged: (v) => _apply(
                (b) => b..rememberAudioSelections = v,
                l10n.playbackPreferenceSaved,
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.history_toggle_off),
              title: Text(l10n.playbackRememberSubtitleSelections),
              value: _local.rememberSubtitleSelections ?? true,
              onChanged: (v) => _apply(
                (b) => b..rememberSubtitleSelections = v,
                l10n.playbackPreferenceSaved,
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.help_outline),
              title: Text(l10n.playbackShowMissingEpisodes),
              value: _local.displayMissingEpisodes ?? false,
              onChanged: (v) => _apply(
                (b) => b..displayMissingEpisodes = v,
                l10n.playbackPreferenceSaved,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _languageLabel(String? code) {
    if (code == null || code.isEmpty) return context.l10n.playbackLanguageNone;
    // Resolve to displayName synchronously when the culture list is ready,
    // otherwise show the raw code so the screen renders without blocking.
    final cultures = ref.read(culturesProvider).valueOrNull;
    if (cultures == null) return code;
    for (final c in cultures) {
      if (c.threeLetterISOLanguageName == code ||
          c.twoLetterISOLanguageName == code ||
          c.name == code) {
        return c.displayName ?? code;
      }
    }
    return code;
  }

  Future<void> _pickLanguage({
    required String title,
    required String? current,
    required Future<void> Function(String? code) onPicked,
  }) async {
    final code = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _LanguagePickerSheet(title: title, current: current),
    );
    // showModalBottomSheet returns null when dismissed without a tap; we use
    // a sentinel "__none__" to distinguish "user picked Aucune" from cancel.
    if (code == null) return;
    final normalised = code == '__none__' ? null : code;
    if (normalised == current) return;
    await onPicked(normalised);
  }

  Future<void> _pickSubtitleMode() async {
    final modeUpdatedMsg = context.l10n.playbackSubtitleModeUpdated;
    final picked = await showModalBottomSheet<SubtitlePlaybackMode>(
      context: context,
      showDragHandle: true,
      builder: (_) => _SubtitleModeSheet(current: _local.subtitleMode),
    );
    if (picked == null || picked == _local.subtitleMode) return;
    await _apply(
      (b) => b..subtitleMode = picked,
      modeUpdatedMsg,
    );
  }

  String _subtitleModeLabel(SubtitlePlaybackMode? mode) {
    final l10n = context.l10n;
    return switch (mode) {
      SubtitlePlaybackMode.always => l10n.playbackSubtitleModeAlways,
      SubtitlePlaybackMode.onlyForced => l10n.playbackSubtitleModeOnlyForced,
      SubtitlePlaybackMode.none => l10n.playbackSubtitleModeNone,
      SubtitlePlaybackMode.smart => l10n.playbackSubtitleModeSmart,
      _ => l10n.playbackSubtitleModeDefault,
    };
  }
}

class _LanguagePickerSheet extends ConsumerStatefulWidget {
  const _LanguagePickerSheet({required this.title, required this.current});

  final String title;
  final String? current;

  @override
  ConsumerState<_LanguagePickerSheet> createState() =>
      _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends ConsumerState<_LanguagePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(culturesProvider);
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.sm,
            ),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.playbackLanguageSearch,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text(l10n.errorFailed('$e'))),
              data: (cultures) {
                final filtered = _query.isEmpty
                    ? cultures
                    : cultures
                        .where(
                          (c) =>
                              (c.displayName ?? '')
                                  .toLowerCase()
                                  .contains(_query) ||
                              (c.threeLetterISOLanguageName ?? '')
                                  .toLowerCase()
                                  .contains(_query),
                        )
                        .toList();
                return ListView.builder(
                  controller: controller,
                  itemCount: filtered.length + 1,
                  itemBuilder: (_, i) {
                    if (i == 0) {
                      return ListTile(
                        leading: Icon(
                          Icons.do_not_disturb_alt,
                          color: scheme.onSurfaceVariant,
                        ),
                        title: Text(l10n.playbackLanguageNone),
                        selected: widget.current == null,
                        onTap: () => Navigator.of(context).pop('__none__'),
                      );
                    }
                    final c = filtered[i - 1];
                    // Pick the best available identifier so we never pop null
                    // back to the caller (which would be interpreted as a
                    // dismiss and silently drop the selection).
                    final code = c.threeLetterISOLanguageName ??
                        c.twoLetterISOLanguageName ??
                        c.name;
                    if (code == null || code.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return ListTile(
                      title: Text(c.displayName ?? code),
                      subtitle: Text(code),
                      selected: widget.current == code,
                      onTap: () => Navigator.of(context).pop(code),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtitleModeSheet extends StatelessWidget {
  const _SubtitleModeSheet({required this.current});

  final SubtitlePlaybackMode? current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final entries = <(SubtitlePlaybackMode, String, String?)>[
      (
        SubtitlePlaybackMode.default_,
        l10n.playbackSubtitleModeDefault,
        l10n.playbackSubtitleModeDefaultDescription,
      ),
      (
        SubtitlePlaybackMode.always,
        l10n.playbackSubtitleModeAlways,
        l10n.playbackSubtitleModeAlwaysDescription,
      ),
      (
        SubtitlePlaybackMode.onlyForced,
        l10n.playbackSubtitleModeOnlyForced,
        l10n.playbackSubtitleModeOnlyForcedDescription,
      ),
      (
        SubtitlePlaybackMode.smart,
        l10n.playbackSubtitleModeSmart,
        l10n.playbackSubtitleModeSmartDescription,
      ),
      (
        SubtitlePlaybackMode.none,
        l10n.playbackSubtitleModeNone,
        l10n.playbackSubtitleModeNoneDescription,
      ),
    ];

    return SafeArea(
      child: RadioGroup<SubtitlePlaybackMode>(
        groupValue: current ?? SubtitlePlaybackMode.default_,
        onChanged: (v) => Navigator.of(context).pop(v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.playbackSubtitleMode,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            for (final (mode, title, subtitle) in entries)
              RadioListTile<SubtitlePlaybackMode>(
                title: Text(title),
                subtitle: subtitle == null ? null : Text(subtitle),
                value: mode,
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
