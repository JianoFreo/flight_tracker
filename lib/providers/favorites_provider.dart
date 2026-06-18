import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

/// Tracks which aircraft (by ICAO24 address) the user has starred as a
/// favorite, persisted locally so the list survives app restarts.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({StorageService? storage}) : _storage = storage ?? StorageService();

  final StorageService _storage;
  Set<String> _favoriteIcao24 = {};
  bool _loaded = false;

  bool get loaded => _loaded;
  Set<String> get favorites => _favoriteIcao24;
  int get count => _favoriteIcao24.length;

  Future<void> load() async {
    _favoriteIcao24 = await _storage.loadFavorites();
    _loaded = true;
    notifyListeners();
  }

  bool isFavorite(String icao24) => _favoriteIcao24.contains(icao24.toLowerCase());

  void toggle(String icao24) {
    final key = icao24.toLowerCase();
    if (_favoriteIcao24.contains(key)) {
      _favoriteIcao24.remove(key);
    } else {
      _favoriteIcao24.add(key);
    }
    notifyListeners();
    _storage.saveFavorites(_favoriteIcao24);
  }

  void clearAll() {
    _favoriteIcao24 = {};
    notifyListeners();
    _storage.saveFavorites(_favoriteIcao24);
  }
}
