import 'package:flutter/material.dart';
import '../models/flight_state.dart';
import '../utils/formatters.dart';

/// A single row in the flight list view: callsign, country, altitude,
/// speed, and a heading-rotated aircraft icon.
class FlightListItem extends StatelessWidget {
  const FlightListItem({super.key, required this.flight, this.onTap});

  final FlightState flight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
        subtitle: Text('${flight.originCountry} • ${Formatters.lastSeen(flight.lastContact)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Formatters.altitude(flight.baroAltitude), style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(Formatters.speed(flight.velocity), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
