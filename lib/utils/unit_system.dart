/// The two unit systems the app can display altitude/speed/distance in.
/// Persisted via [SettingsProvider] and read by [Formatters].
enum UnitSystem { imperial, metric }

extension UnitSystemLabel on UnitSystem {
  String get label => this == UnitSystem.imperial ? 'Imperial (ft, kts)' : 'Metric (m, km/h)';
}
