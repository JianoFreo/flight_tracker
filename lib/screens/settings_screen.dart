import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/flight_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/unit_system.dart';

/// Lets the user control theme, unit system, and refresh interval, plus
/// a quick "About" blurb crediting the data source. All settings persist
/// locally via [SettingsProvider]/[StorageService] — still no backend.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (mode) => settings.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (mode) => settings.setThemeMode(mode!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Match system'),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (mode) => settings.setThemeMode(mode!),
          ),
          const Divider(),
          const _SectionHeader('Units'),
          RadioListTile<UnitSystem>(
            title: const Text('Imperial (ft, knots, miles)'),
            value: UnitSystem.imperial,
            groupValue: settings.unitSystem,
            onChanged: (unit) => settings.setUnitSystem(unit!),
          ),
          RadioListTile<UnitSystem>(
            title: const Text('Metric (m, km/h, kilometers)'),
            value: UnitSystem.metric,
            groupValue: settings.unitSystem,
            onChanged: (unit) => settings.setUnitSystem(unit!),
          ),
          const Divider(),
          const _SectionHeader('Live refresh'),
          ListTile(
            title: const Text('Auto-refresh interval'),
            subtitle: Text('${settings.refreshSeconds} seconds'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: settings.refreshSeconds.toDouble(),
              min: 10,
              max: 60,
              divisions: 10,
              label: '${settings.refreshSeconds}s',
              onChanged: (value) {
                final seconds = value.round();
                settings.setRefreshSeconds(seconds);
                context.read<FlightProvider>().setRefreshInterval(Duration(seconds: seconds));
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'OpenSky\'s anonymous tier is rate-limited — intervals below 10s may '
              'start returning errors.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const Divider(),
          const _SectionHeader('Favorites'),
          Consumer<FavoritesProvider>(
            builder: (context, favorites, _) => ListTile(
              title: const Text('Starred aircraft'),
              subtitle: Text('${favorites.count} saved'),
            ),
          ),
          const Divider(),
          const _SectionHeader('About'),
          const ListTile(
            title: Text('Data source'),
            subtitle: Text(
              'Live aircraft positions come directly from the OpenSky Network '
              'public API — no backend server is involved. Maps use '
              'OpenStreetMap tiles.',
            ),
          ),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
