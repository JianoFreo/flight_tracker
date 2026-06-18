import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/unit_system.dart';

/// Holds user-configurable app settings (theme, units, refresh interval)
/// and persists them locally via [StorageService]. Defaults are applied
/// immediately on construction; persisted values load asynchronously and
/// override the defaults a moment later via [notifyListeners].
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({StorageService? storage}) : _storage = storage ?? StorageService();

  final StorageService _storage;

  ThemeMode _themeMode = ThemeMode.system;
  UnitSystem _unitSystem = UnitSystem.imperial;
  int _refreshSeconds = 15;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  UnitSystem get unitSystem => _unitSystem;
  int get refreshSeconds => _refreshSeconds;
  bool get loaded => _loaded;

  Future<void> load() async {
    final themeName = await _storage.loadThemeModeName();
    final unitName = await _storage.loadUnitSystemName();
    final refresh = await _storage.loadRefreshSeconds();

    _themeMode = _themeModeFromName(themeName) ?? _themeMode;
    _unitSystem = _unitSystemFromName(unitName) ?? _unitSystem;
    _refreshSeconds = refresh ?? _refreshSeconds;
    _loaded = true;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _storage.saveThemeModeName(mode.name);
  }

  void setUnitSystem(UnitSystem unit) {
    _unitSystem = unit;
    notifyListeners();
    _storage.saveUnitSystemName(unit.name);
  }

  void setRefreshSeconds(int seconds) {
    _refreshSeconds = seconds;
    notifyListeners();
    _storage.saveRefreshSeconds(seconds);
  }

  ThemeMode? _themeModeFromName(String? name) {
    switch (name) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  UnitSystem? _unitSystemFromName(String? name) {
    switch (name) {
      case 'imperial':
        return UnitSystem.imperial;
      case 'metric':
        return UnitSystem.metric;
      default:
        return null;
    }
  }
}
