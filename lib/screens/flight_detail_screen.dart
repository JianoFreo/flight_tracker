import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../models/flight_state.dart';
import '../utils/formatters.dart';

/// Full detail view for a single aircraft: a small live map plus every
/// field returned by the OpenSky state vector.
class FlightDetailScreen extends StatelessWidget {
  const FlightDetailScreen({super.key, required this.flight});

  final FlightState flight;

  @override
  Widget build(BuildContext context) {
    final point = flight.hasPosition ? ll.LatLng(flight.latitude!, flight.longitude!) : null;

    return Scaffold(
      appBar: AppBar(title: Text(flight.displayName)),
      body: ListView(
        children: [
          if (point != null)
            SizedBox(
              height: 240,
              child: FlutterMap(
                options: MapOptions(initialCenter: point, initialZoom: 6),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flight_tracker',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: point,
                      width: 36,
                      height: 36,
                      child: Transform.rotate(
                        angle: (flight.trueTrack ?? 0) * 3.14159265 / 180,
                        child: const Icon(Icons.flight, color: Colors.blueAccent, size: 30),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(flight.displayName, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  'ICAO24: ${flight.icao24.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(height: 32),
                _DetailRow(label: 'Origin country', value: flight.originCountry),
                _DetailRow(label: 'Altitude', value: Formatters.altitude(flight.baroAltitude)),
                _DetailRow(label: 'Ground speed', value: Formatters.speed(flight.velocity)),
                _DetailRow(label: 'Heading', value: Formatters.heading(flight.trueTrack)),
                _DetailRow(
                  label: 'Vertical rate',
                  value: Formatters.verticalRate(flight.verticalRate),
                ),
                _DetailRow(label: 'On ground', value: flight.onGround ? 'Yes' : 'No'),
                _DetailRow(label: 'Squawk code', value: flight.squawk ?? '—'),
                _DetailRow(label: 'Last contact', value: Formatters.lastSeen(flight.lastContact)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
