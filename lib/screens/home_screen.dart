import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
import '../providers/settings_provider.dart';
import '../services/location_service.dart';
import '../utils/geo_utils.dart';
import '../widgets/filter_sort_sheet.dart';
import '../widgets/flight_list_item.dart';
import '../widgets/flight_map.dart';
import '../widgets/region_selector.dart';
import '../widgets/search_field.dart';
import '../widgets/status_banner.dart';
import 'flight_detail_screen.dart';

/// "Live" tab content: search + region controls, a status strip, and a
/// List / Map / Nearby tab view of all currently tracked aircraft.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlightProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Tracker'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: provider.hasActiveFilters,
              child: const Icon(Icons.tune),
            ),
            tooltip: 'Filter & sort',
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => FilterSortSheet(provider: provider),
            ),
          ),
          IconButton(
            icon: Icon(provider.autoRefresh ? Icons.sync : Icons.sync_disabled),
            tooltip: provider.autoRefresh ? 'Auto-refresh on' : 'Auto-refresh off',
            onPressed: () => provider.toggleAutoRefresh(!provider.autoRefresh),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh now',
            onPressed: provider.isLoading ? null : provider.loadFlights,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'List', icon: Icon(Icons.list)),
            Tab(text: 'Map', icon: Icon(Icons.map)),
            Tab(text: 'Nearby', icon: Icon(Icons.my_location)),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(child: SearchField(onChanged: provider.setSearchQuery)),
                const SizedBox(width: 8),
                RegionSelector(
                  selected: provider.selectedRegion,
                  onChanged: provider.selectRegion,
                ),
              ],
            ),
          ),
          StatusBanner(
            isLoading: provider.isLoading,
            errorMessage: provider.errorMessage,
            count: provider.flights.length,
            isShowingCachedData: provider.isShowingCachedData,
            cachedAt: provider.cachedAt,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FlightList(provider: provider),
                FlightMap(flights: provider.flights),
                const _NearbyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightList extends StatelessWidget {
  const _FlightList({required this.provider});

  final FlightProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.flights.isEmpty && !provider.isLoading) {
      return const Center(child: Text('No flights found in this region.'));
    }

    return RefreshIndicator(
      onRefresh: provider.loadFlights,
      child: ListView.builder(
        itemCount: provider.flights.length,
        itemBuilder: (context, index) {
          final flight = provider.flights[index];
          return FlightListItem(
            flight: flight,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FlightDetailScreen(flight: flight)),
            ),
          );
        },
      ),
    );
  }
}

/// Sorts the currently tracked flights by distance from the device's GPS
/// position. Location is fetched on demand (button tap) rather than
/// automatically, so the app never asks for location permission unless
/// the user actually opens this tab and asks for it.
class _NearbyTab extends StatefulWidget {
  const _NearbyTab();

  @override
  State<_NearbyTab> createState() => _NearbyTabState();
}

class _NearbyTabState extends State<_NearbyTab> {
  final _locationService = LocationService();
  double? _userLat;
  double? _userLon;
  bool _isLocating = false;
  String? _locationError;

  Future<void> _useMyLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _userLat = position.latitude;
        _userLon = position.longitude;
      });
    } catch (e) {
      setState(() => _locationError = e.toString());
    } finally {
      setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userLat == null || _userLon == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.my_location, size: 40),
              const SizedBox(height: 12),
              const Text(
                'Find aircraft closest to you right now.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_locationError != null) ...[
                Text(
                  _locationError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              FilledButton.icon(
                onPressed: _isLocating ? null : _useMyLocation,
                icon: _isLocating
                    ? const SizedBox(
                        width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.my_location),
                label: Text(_isLocating ? 'Locating…' : 'Use my location'),
              ),
            ],
          ),
        ),
      );
    }

    final provider = context.watch<FlightProvider>();
    final unit = context.watch<SettingsProvider>().unitSystem;

    final withDistance = provider.flights
        .map((f) => (
              flight: f,
              distanceKm: GeoUtils.distanceKm(
                lat1: _userLat!,
                lon1: _userLon!,
                lat2: f.latitude!,
                lon2: f.longitude!,
              ),
            ))
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Sorted by distance from your location',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton(onPressed: _useMyLocation, child: const Text('Refresh location')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: withDistance.length,
            itemBuilder: (context, index) {
              final entry = withDistance[index];
              return FlightListItem(
                flight: entry.flight,
                distanceLabel: GeoUtils.formatDistance(entry.distanceKm, unit),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FlightDetailScreen(flight: entry.flight)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
