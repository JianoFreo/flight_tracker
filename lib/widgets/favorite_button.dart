import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';

/// A star icon button that toggles whether an aircraft (by ICAO24) is
/// favorited. Reads/writes through [FavoritesProvider] so state stays in
/// sync everywhere it's shown (list, map, detail screen, favorites tab).
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.icao24, this.size = 22});

  final String icao24;
  final double size;

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(icao24);

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.star : Icons.star_border,
        color: isFavorite ? Colors.amber : null,
        size: size,
      ),
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      onPressed: () => favorites.toggle(icao24),
    );
  }
}
