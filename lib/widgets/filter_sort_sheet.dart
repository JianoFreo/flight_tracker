import 'package:flutter/material.dart';
import '../providers/flight_provider.dart';

/// Bottom sheet for the List/Map tabs: ground filter, altitude range,
/// and sort options. Reads/writes [FlightProvider] directly via the
/// instance passed in, since this is shown via `showModalBottomSheet`
/// outside the normal widget tree where `context.watch` still works
/// fine, but explicit passing keeps it obvious what it controls.
class FilterSortSheet extends StatefulWidget {
  const FilterSortSheet({super.key, required this.provider});

  final FlightProvider provider;

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  late GroundFilter _groundFilter;
  late RangeValues _altitudeRangeFeet;
  late FlightSortBy _sortBy;
  late bool _ascending;

  static const double _maxAltitudeFeet = 45000;

  @override
  void initState() {
    super.initState();
    final p = widget.provider;
    _groundFilter = p.groundFilter;
    _altitudeRangeFeet = RangeValues(
      ((p.minAltitudeMeters ?? 0) * 3.28084).clamp(0, _maxAltitudeFeet),
      ((p.maxAltitudeMeters ?? _maxAltitudeFeet * 0.3048) * 3.28084).clamp(0, _maxAltitudeFeet),
    );
    _sortBy = p.sortBy;
    _ascending = p.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter & sort', style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: _resetAll, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: 12),
          Text('Aircraft status', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<GroundFilter>(
            segments: const [
              ButtonSegment(value: GroundFilter.all, label: Text('All')),
              ButtonSegment(value: GroundFilter.airborneOnly, label: Text('Airborne')),
              ButtonSegment(value: GroundFilter.groundedOnly, label: Text('Grounded')),
            ],
            selected: {_groundFilter},
            onSelectionChanged: (selection) => setState(() => _groundFilter = selection.first),
          ),
          const SizedBox(height: 20),
          Text(
            'Altitude: ${_altitudeRangeFeet.start.round()} – ${_altitudeRangeFeet.end.round()} ft',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          RangeSlider(
            values: _altitudeRangeFeet,
            min: 0,
            max: _maxAltitudeFeet,
            divisions: 45,
            labels: RangeLabels(
              '${_altitudeRangeFeet.start.round()} ft',
              '${_altitudeRangeFeet.end.round()} ft',
            ),
            onChanged: (values) => setState(() => _altitudeRangeFeet = values),
          ),
          const SizedBox(height: 12),
          Text('Sort by', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _sortChip('Callsign', FlightSortBy.callsign),
              _sortChip('Altitude', FlightSortBy.altitude),
              _sortChip('Speed', FlightSortBy.speed),
              _sortChip('Country', FlightSortBy.country),
              _sortChip('Last contact', FlightSortBy.lastContact),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Direction:'),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Ascending'),
                selected: _ascending,
                onSelected: (_) => setState(() => _ascending = true),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Descending'),
                selected: !_ascending,
                onSelected: (_) => setState(() => _ascending = false),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _apply,
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, FlightSortBy value) {
    return ChoiceChip(
      label: Text(label),
      selected: _sortBy == value,
      onSelected: (_) => setState(() => _sortBy = value),
    );
  }

  void _resetAll() {
    setState(() {
      _groundFilter = GroundFilter.all;
      _altitudeRangeFeet = const RangeValues(0, _maxAltitudeFeet);
      _sortBy = FlightSortBy.callsign;
      _ascending = true;
    });
  }

  void _apply() {
    widget.provider.setGroundFilter(_groundFilter);
    final minMeters = _altitudeRangeFeet.start <= 0 ? null : _altitudeRangeFeet.start / 3.28084;
    final maxMeters =
        _altitudeRangeFeet.end >= _maxAltitudeFeet ? null : _altitudeRangeFeet.end / 3.28084;
    widget.provider.setAltitudeRange(minMeters, maxMeters);
    widget.provider.setSort(_sortBy, ascending: _ascending);
    Navigator.of(context).pop();
  }
}
