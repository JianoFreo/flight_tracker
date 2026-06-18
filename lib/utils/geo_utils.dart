import 'dart:math' as math;
import 'unit_system.dart';

/// Pure geographic math used by the "Nearby" feature — no extra package
/// needed beyond `dart:math`, only device location comes from a package.
class GeoUtils {
  GeoUtils._();

  static const double _earthRadiusKm = 6371.0;

  /// Great-circle distance between two points, in kilometers.
  static double distanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;

  /// Formats a distance for display, honoring the user's chosen unit
  /// system (kilometers vs. miles).
  static String formatDistance(double km, UnitSystem unit) {
    if (unit == UnitSystem.imperial) {
      final miles = km * 0.621371;
      return '${miles.toStringAsFixed(miles < 10 ? 1 : 0)} mi';
    }
    return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
  }
}
