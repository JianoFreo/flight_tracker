import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../widgets/country_distribution_chart.dart';
import '../widgets/flight_stat_card.dart';

/// Dashboard summarizing the currently fetched flights: counts, extremes,
/// and a country-distribution chart. Everything here is computed from
/// data already in [FlightProvider] — no extra network calls.
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flights = context.watch<FlightProvider>().allFlights;
    final unit = context.watch<SettingsProvider>().unitSystem;

    final airborne = flights.where((f) => !f.onGround).length;
    final grounded = flights.length - airborne;

    final altitudes = flights.map((f) => f.baroAltitude).whereType<double>().toList();
    final speeds = flights.map((f) => f.velocity).whereType<double>().toList();

    final avgAltitude = altitudes.isEmpty ? null : altitudes.reduce((a, b) => a + b) / altitudes.length;
    final fastest = speeds.isEmpty ? null : speeds.reduce((a, b) => a > b ? a : b);
    final highest = altitudes.isEmpty ? null : altitudes.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: flights.isEmpty
          ? const Center(child: Text('No data yet — load some flights first.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    FlightStatCard(
                      label: 'Aircraft tracked',
                      value: '${flights.length}',
                      icon: Icons.flight_takeoff,
                    ),
                    FlightStatCard(
                      label: 'Airborne / Grounded',
                      value: '$airborne / $grounded',
                      icon: Icons.compare_arrows,
                    ),
                    FlightStatCard(
                      label: 'Average altitude',
                      value: Formatters.altitude(avgAltitude, unit),
                      icon: Icons.height,
                    ),
                    FlightStatCard(
                      label: 'Highest altitude',
                      value: Formatters.altitude(highest, unit),
                      icon: Icons.arrow_upward,
                    ),
                    FlightStatCard(
                      label: 'Fastest ground speed',
                      value: Formatters.speed(fastest, unit),
                      icon: Icons.speed,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Top origin countries', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                CountryDistributionChart(flights: flights),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}
