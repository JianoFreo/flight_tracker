import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/flight_state.dart';
import '../utils/constants.dart';

/// Thin wrapper around the OpenSky Network REST API.
///
/// This calls the public API directly from the device/browser — there is
/// no backend server involved. Anonymous access is rate-limited (roughly
/// one request every 10 seconds, ~400/day) and only returns the most
/// recent state vectors.
///
/// Note: OpenSky has moved authenticated access to an OAuth2
/// client-credentials flow and no longer accepts HTTP Basic Auth
/// (username/password). This service intentionally only supports
/// anonymous requests; if you need authenticated access for higher
/// limits, implement the OAuth2 token exchange described at
/// https://openskynetwork.github.io/opensky-api/rest.html and attach the
/// resulting bearer token as an `Authorization` header below.
class FlightService {
  FlightService({http.Client? client}) : _client = client ?? http.Client();

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

    final response = await _get(uri);
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

    final response = await _get(uri);
    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final states = body['states'] as List<dynamic>?;
    if (states == null || states.isEmpty) return null;
    return FlightState.fromList(states.first as List<dynamic>);
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      return await _client.get(uri).timeout(const Duration(seconds: 15));
    } on http.ClientException {
      // On Flutter Web this is almost always a CORS rejection: the
      // browser blocks the response because opensky-network.org does
      // not reliably send Access-Control-Allow-Origin headers (this is a
      // known, longstanding limitation of their API, not a bug in this
      // app). Mobile/desktop builds aren't affected since CORS is a
      // browser-only restriction.
      if (kIsWeb) {
        throw FlightServiceException(
          "Couldn't reach OpenSky from the browser. Their API doesn't "
          'reliably send CORS headers, so most browsers block the '
          'response. Try running this app on Android, iOS, or desktop '
          '(flutter run -d <device>) instead — that path calls the API '
          'directly with no browser restrictions.',
        );
      }
      rethrow;
    }
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
