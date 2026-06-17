import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_state.dart';
import '../utils/constants.dart';

/// Thin wrapper around the OpenSky Network REST API.
///
/// This calls the public API directly from the device/browser — there is
/// no backend server involved. Anonymous access is rate-limited (roughly
/// one request every 10 seconds, ~400/day). For higher limits, create a
/// free OpenSky account and pass [username]/[password]; they're sent as
/// HTTP Basic Auth, never stored or transmitted anywhere else.
class FlightService {
  FlightService({this.username, this.password, http.Client? client})
      : _client = client ?? http.Client();

  final String? username;
  final String? password;
  final http.Client _client;

  /// Fetches all aircraft currently reporting a position within [bbox].
  /// Pass `bbox: null` to fetch the whole world (can return 10,000+
  /// aircraft — fine for desktop, heavy for mobile/web).
  Future<List<FlightState>> fetchStates({BoundingBox? bbox}) async {
    final uri = Uri.parse(AppConstants.statesAllEndpoint).replace(
      queryParameters: bbox == null
          ? null
          : {
              'lamin': bbox.minLat.toString(),
              'lomin': bbox.minLon.toString(),
              'lamax': bbox.maxLat.toString(),
              'lomax': bbox.maxLon.toString(),
            },
    );

    final response = await _client
        .get(uri, headers: _authHeaders())
        .timeout(const Duration(seconds: 15));

    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final states = body['states'] as List<dynamic>?;
    if (states == null) return [];

    return states
        .map((state) => FlightState.fromList(state as List<dynamic>))
        .where((flight) => flight.hasPosition)
        .toList();
  }

  /// Looks up a single aircraft by its 24-bit ICAO transponder address.
  Future<FlightState?> fetchByIcao24(String icao24) async {
    final uri = Uri.parse(AppConstants.statesAllEndpoint).replace(
      queryParameters: {'icao24': icao24.toLowerCase().trim()},
    );

    final response = await _client
        .get(uri, headers: _authHeaders())
        .timeout(const Duration(seconds: 15));

    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final states = body['states'] as List<dynamic>?;
    if (states == null || states.isEmpty) return null;
    return FlightState.fromList(states.first as List<dynamic>);
  }

  Map<String, String> _authHeaders() {
    if (username == null || password == null) return {};
    final credentials = base64Encode(utf8.encode('$username:$password'));
    return {'Authorization': 'Basic $credentials'};
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode == 429) {
      throw FlightServiceException(
        'OpenSky rate limit reached. Wait a minute before refreshing again.',
      );
    }
    if (response.statusCode != 200) {
      throw FlightServiceException(
        'OpenSky API returned an error (HTTP ${response.statusCode}).',
      );
    }
  }

  void dispose() => _client.close();
}

/// Thrown when the API request fails or is rate-limited. The message is
/// already human-readable and safe to show directly in the UI.
class FlightServiceException implements Exception {
  FlightServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// A simple lat/lon bounding box used to scope OpenSky queries to a
/// region instead of pulling every aircraft on the planet.
class BoundingBox {
  const BoundingBox({
    required this.minLat,
    required this.minLon,
    required this.maxLat,
    required this.maxLon,
  });

  final double minLat;
  final double minLon;
  final double maxLat;
  final double maxLon;
}
