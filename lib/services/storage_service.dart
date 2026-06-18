import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flight_state.dart';

/// The only file in the app that touches `shared_preferences` directly.
/// Everything is still purely local/on-device — there is no backend or
/// cloud sync here, just persistence between app launches.
class StorageService {
  static const _favoritesKey = 'favorites_icao24';
  static const _themeModeKey = 'settings_theme_mode'; // 'light' | 'dark' | 'system'
  static const _unitSystemKey = 'settings_unit_system'; // 'imperial' | 'metric'
  static const _refreshSecondsKey = 'settings_refresh_seconds';
  static const _cachedFlightsKey = 'cache_flights_json';
  static const _cachedAtKey = 'cache_flights_at';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---- Favorites ----------------------------------------------------

  Future<Set<String>> loadFavorites() async {
    final prefs = await _prefs;
    return (prefs.getStringList(_favoritesKey) ?? const []).toSet();
  }

  Future<void> saveFavorites(Set<String> icao24Codes) async {
    final prefs = await _prefs;
    await prefs.setStringList(_favoritesKey, icao24Codes.toList());
  }

  // ---- Settings --------------------------------------------------------

  Future<String?> loadThemeModeName() async => (await _prefs).getString(_themeModeKey);

  Future<void> saveThemeModeName(String name) async => (await _prefs).setString(_themeModeKey, name);

  Future<String?> loadUnitSystemName() async => (await _prefs).getString(_unitSystemKey);

  Future<void> saveUnitSystemName(String name) async => (await _prefs).setString(_unitSystemKey, name);

  Future<int?> loadRefreshSeconds() async => (await _prefs).getInt(_refreshSecondsKey);

  Future<void> saveRefreshSeconds(int seconds) async =>
      (await _prefs).setInt(_refreshSecondsKey, seconds);

  // ---- Offline flight cache --------------------------------------------

  /// Stores the most recent successful fetch so the app has something to
  /// show (clearly labeled as stale) if a later refresh fails — e.g. no
  /// connectivity, or the API is temporarily unreachable.
  Future<void> cacheFlights(List<FlightState> flights) async {
    final prefs = await _prefs;
    final jsonList = flights.map((f) => f.toJson()).toList();
    await prefs.setString(_cachedFlightsKey, jsonEncode(jsonList));
    await prefs.setInt(_cachedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns the cached flights and the time they were cached, or `null`
  /// if nothing has been cached yet.
  Future<(List<FlightState>, DateTime)?> loadCachedFlights() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_cachedFlightsKey);
    final cachedAtMillis = prefs.getInt(_cachedAtKey);
    if (raw == null || cachedAtMillis == null) return null;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final flights = decoded
          .map((item) => FlightState.fromJson(item as Map<String, dynamic>))
          .toList();
      return (flights, DateTime.fromMillisecondsSinceEpoch(cachedAtMillis));
    } catch (_) {
      return null;
    }
  }
}
