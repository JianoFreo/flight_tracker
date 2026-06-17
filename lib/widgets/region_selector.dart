import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Dropdown that lets the user scope the OpenSky query to a region
/// instead of pulling every aircraft on the planet.
class RegionSelector extends StatelessWidget {
  const RegionSelector({super.key, required this.selected, required this.onChanged});

  final RegionOption selected;
  final ValueChanged<RegionOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RegionOption>(
          value: selected,
          borderRadius: BorderRadius.circular(12),
          items: AppConstants.regions
              .map((region) => DropdownMenuItem(value: region, child: Text(region.label)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}
