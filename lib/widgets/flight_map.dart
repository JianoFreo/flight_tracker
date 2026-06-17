import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../models/flight_state.dart';
import '../screens/flight_detail_screen.dart';

/// Live map view showing every tracked aircraft as a rotated marker.
/// Uses OpenStreetMap raster tiles, which require no API key — keeping
/// the whole app backend-free and key-free.
class FlightMap extends StatelessWidget {
  const FlightMap({super.key, required this.flights});

  final List<FlightState> flights;

  @override
  Widget build(BuildContext context) {
    final center = flights.isNotEmpty
        ? ll.LatLng(flights.first.latitude!, flights.first.longitude!)
        : const ll.LatLng(20, 0);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: flights.isNotEmpty ? 4 : 2,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.flight_tracker',
        ),
        MarkerLayer(
          markers: flights.map((flight) {
            return Marker(
              point: ll.LatLng(flight.latitude!, flight.longitude!),
              width: 36,
              height: 36,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FlightDetailScreen(flight: flight)),
                ),
                child: Transform.rotate(
                  angle: (flight.trueTrack ?? 0) * 3.14159265 / 180,
                  child: Icon(
                    Icons.flight,
                    color: flight.onGround ? Colors.grey : Colors.blueAccent,
                    size: 26,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
