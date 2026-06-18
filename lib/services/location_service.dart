import 'package:geolocator/geolocator.dart';

/// Thin wrapper around `geolocator` so the rest of the app never imports
/// it directly. Used only by the "Nearby" tab to sort/filter flights by
/// distance from the device's current position — entirely on-device,
/// no location data is sent anywhere except to OpenSky as part of the
/// normal bounding-box query.
class LocationService {
  /// Requests permission (if needed) and returns the device's current
  /// position, or throws a [LocationServiceException] with a message
  /// that's safe to show directly in the UI.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are turned off on this device. Enable them to see nearby flights.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw LocationServiceException(
        'Location permission was denied. Allow it in your device settings to see nearby flights.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission is permanently denied. Enable it from system settings to see nearby flights.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }
}

class LocationServiceException implements Exception {
  LocationServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
