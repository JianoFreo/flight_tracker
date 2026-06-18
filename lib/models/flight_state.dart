/// Represents a single live aircraft "state vector" as reported by the
/// OpenSky Network public REST API.
///
/// Reference: https://openskynetwork.github.io/opensky-api/rest.html#response
class FlightState {
  final String icao24;
  final String? callsign;
  final String originCountry;
  final int? timePosition;
  final int lastContact;
  final double? longitude;
  final double? latitude;
  final double? baroAltitude;
  final bool onGround;
  final double? velocity;
  final double? trueTrack;
  final double? verticalRate;
  final double? geoAltitude;
  final String? squawk;
  final bool spi;
  final int positionSource;

  const FlightState({
    required this.icao24,
    this.callsign,
    required this.originCountry,
    this.timePosition,
    required this.lastContact,
    this.longitude,
    this.latitude,
    this.baroAltitude,
    required this.onGround,
    this.velocity,
    this.trueTrack,
    this.verticalRate,
    this.geoAltitude,
    this.squawk,
    required this.spi,
    required this.positionSource,
  });

  /// OpenSky returns each state vector as a positional JSON array (not a
  /// JSON object), so fields are parsed by fixed index rather than by key.
  factory FlightState.fromList(List<dynamic> raw) {
    String? cleanCallsign(dynamic v) {
      if (v is! String) return null;
      final trimmed = v.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    return FlightState(
      icao24: (raw[0] as String).trim(),
      callsign: cleanCallsign(raw[1]),
      originCountry: raw[2] as String? ?? 'Unknown',
      timePosition: raw[3] as int?,
      lastContact: raw[4] as int? ?? 0,
      longitude: (raw[5] as num?)?.toDouble(),
      latitude: (raw[6] as num?)?.toDouble(),
      baroAltitude: (raw[7] as num?)?.toDouble(),
      onGround: raw[8] as bool? ?? false,
      velocity: (raw[9] as num?)?.toDouble(),
      trueTrack: (raw[10] as num?)?.toDouble(),
      verticalRate: (raw[11] as num?)?.toDouble(),
      // index 12 ("sensors") is intentionally skipped — rarely populated.
      geoAltitude: (raw[13] as num?)?.toDouble(),
      squawk: raw[14] as String?,
      spi: raw[15] as bool? ?? false,
      positionSource: raw[16] as int? ?? 0,
    );
  }

  bool get hasPosition => latitude != null && longitude != null;

  String get displayName => callsign ?? icao24.toUpperCase();

  /// Serializes to a plain JSON-able map. Used by `StorageService` to
  /// cache the last successful fetch for offline/error fallback display —
  /// this is a different shape than [fromList], which parses OpenSky's
  /// raw positional array format.
  Map<String, dynamic> toJson() => {
        'icao24': icao24,
        'callsign': callsign,
        'originCountry': originCountry,
        'timePosition': timePosition,
        'lastContact': lastContact,
        'longitude': longitude,
        'latitude': latitude,
        'baroAltitude': baroAltitude,
        'onGround': onGround,
        'velocity': velocity,
        'trueTrack': trueTrack,
        'verticalRate': verticalRate,
        'geoAltitude': geoAltitude,
        'squawk': squawk,
        'spi': spi,
        'positionSource': positionSource,
      };

  factory FlightState.fromJson(Map<String, dynamic> json) => FlightState(
        icao24: json['icao24'] as String,
        callsign: json['callsign'] as String?,
        originCountry: json['originCountry'] as String? ?? 'Unknown',
        timePosition: json['timePosition'] as int?,
        lastContact: json['lastContact'] as int? ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        baroAltitude: (json['baroAltitude'] as num?)?.toDouble(),
        onGround: json['onGround'] as bool? ?? false,
        velocity: (json['velocity'] as num?)?.toDouble(),
        trueTrack: (json['trueTrack'] as num?)?.toDouble(),
        verticalRate: (json['verticalRate'] as num?)?.toDouble(),
        geoAltitude: (json['geoAltitude'] as num?)?.toDouble(),
        squawk: json['squawk'] as String?,
        spi: json['spi'] as bool? ?? false,
        positionSource: json['positionSource'] as int? ?? 0,
      );
}
