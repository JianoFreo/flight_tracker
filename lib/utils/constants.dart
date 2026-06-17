import '../services/flight_service.dart';

/// App-wide constant values: API endpoints, refresh timing, and the
/// predefined regions shown in the region picker.
class AppConstants {
  AppConstants._();

  /// Public, unauthenticated OpenSky Network endpoint. No API key needed
  /// for the request volume this app makes. See README for rate limits.
  static const String statesAllEndpoint =
      'https://opensky-network.org/api/states/all';

  static const Duration defaultRefreshInterval = Duration(seconds: 15);

  static const List<RegionOption> regions = [
    RegionOption('North America', BoundingBox(minLat: 14, minLon: -170, maxLat: 72, maxLon: -50)),
    RegionOption('Europe', BoundingBox(minLat: 34, minLon: -25, maxLat: 71, maxLon: 45)),
    RegionOption('Asia', BoundingBox(minLat: -10, minLon: 60, maxLat: 60, maxLon: 150)),
    RegionOption('Middle East', BoundingBox(minLat: 12, minLon: 25, maxLat: 42, maxLon: 65)),
    RegionOption('Oceania', BoundingBox(minLat: -50, minLon: 110, maxLat: 0, maxLon: 180)),
    RegionOption('South America', BoundingBox(minLat: -56, minLon: -82, maxLat: 13, maxLon: -34)),
    RegionOption('Africa', BoundingBox(minLat: -35, minLon: -18, maxLat: 38, maxLon: 52)),
    RegionOption('Entire world (slow)', null),
  ];
}

/// A single entry in the region dropdown. `bbox == null` means "world".
class RegionOption {
  const RegionOption(this.label, this.bbox);
  final String label;
  final BoundingBox? bbox;
}
