import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/flight_provider.dart';
import '../widgets/flight_list_item.dart';
import 'flight_detail_screen.dart';

/// Shows aircraft the user has starred. Cross-references the favorites
/// set against whatever [FlightProvider] currently has fetched — a
/// favorite only shows as "live" if it's in the current fetch window
/// (i.e. within the selected region and still reporting a position).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final allFlights = context.watch<FlightProvider>().allFlights;

    final liveFavorites = allFlights.where((f) => favorites.isFavorite(f.icao24)).toList();
    final missingCount = favorites.count - liveFavorites.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (favorites.count > 0)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear all favorites',
              onPressed: () => _confirmClear(context, favorites),
            ),
        ],
      ),
      body: favorites.count == 0
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No favorites yet. Tap the star on any aircraft to track it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                if (missingCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      '$missingCount favorite${missingCount == 1 ? '' : 's'} not currently visible — '
                      'they may be outside the selected region or not reporting right now.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: liveFavorites.length,
                    itemBuilder: (context, index) {
                      final flight = liveFavorites[index];
                      return FlightListItem(
                        flight: flight,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FlightDetailScreen(flight: flight)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _confirmClear(BuildContext context, FavoritesProvider favorites) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear all favorites?'),
        content: const Text('This removes every starred aircraft. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              favorites.clearAll();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
