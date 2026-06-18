import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flight_state.dart';
import '../providers/settings_provider.dart';
import '../utils/country_flags.dart';
import '../utils/formatters.dart';
import 'favorite_button.dart';

/// A single row in the flight list view: callsign, country (with flag if
/// known), altitude, speed, a heading-rotated aircraft icon, a favorite
/// toggle, and — when supplied — the distance from the user (used by the
/// Nearby tab).
class FlightListItem extends StatelessWidget {
  const FlightListItem({
    super.key,
    required this.flight,
    this.onTap,
    this.distanceLabel,
  });

  final FlightState flight;
  final VoidCallback? onTap;

  /// Pre-formatted distance string (e.g. "12 km"), shown as a trailing
  /// chip when provided. Kept as a plain string rather than a raw double
  /// so this widget doesn't need to know about unit systems itself.
  final String? distanceLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unit = context.watch<SettingsProvider>().unitSystem;
    final flag = CountryFlags.flagFor(flight.originCountry);

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: flight.onGround ? Colors.grey.shade400 : colorScheme.primaryContainer,
          child: Transform.rotate(
            angle: (flight.trueTrack ?? 0) * 3.14159265 / 180,
            child: Icon(
              Icons.flight,
              size: 18,
              color: flight.onGround ? Colors.white : colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(flight.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            if (flag != null) flag,
            flight.originCountry,
            Formatters.lastSeen(flight.lastContact),
            if (distanceLabel != null) distanceLabel!,
          ].join(' • '),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.altitude(flight.baroAltitude, unit),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(Formatters.speed(flight.velocity, unit), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            FavoriteButton(icao24: flight.icao24, size: 20),
          ],
        ),
      ),
    );
  }
}
