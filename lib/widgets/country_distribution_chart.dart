import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/flight_state.dart';

/// Bar chart of the top origin countries among the currently tracked
/// flights, computed entirely client-side from data already fetched —
/// no extra API call needed.
class CountryDistributionChart extends StatelessWidget {
  const CountryDistributionChart({super.key, required this.flights, this.maxBars = 6});

  final List<FlightState> flights;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final flight in flights) {
      counts[flight.originCountry] = (counts[flight.originCountry] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(maxBars).toList();

    if (top.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('No data to chart yet.')),
      );
    }

    final maxCount = top.first.value.toDouble();
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: maxCount * 1.2,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= top.length) return const SizedBox.shrink();
                  final country = top[index].key;
                  final short = country.length > 10 ? '${country.substring(0, 9)}…' : country;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      short,
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < top.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: top[i].value.toDouble(),
                    color: colorScheme.primary,
                    width: 22,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
