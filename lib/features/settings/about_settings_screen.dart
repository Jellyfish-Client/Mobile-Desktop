import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';

const _kAppVersion = '1.0.0+1';

class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAboutTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.movie_filter_outlined),
            title: Text(l10n.aboutAppName),
            subtitle: Text(l10n.aboutAppSubtitle),
          ),
          ListTile(
            leading: const Icon(Icons.tag),
            title: Text(l10n.aboutVersion),
            subtitle: const Text(_kAppVersion),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.aboutLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.aboutAppName,
              applicationVersion: _kAppVersion,
            ),
          ),
        ],
      ),
    );
  }
}
