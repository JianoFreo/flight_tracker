import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flight_provider.dart';
import '../widgets/flight_list_item.dart';
import '../widgets/flight_map.dart';
import '../widgets/region_selector.dart';
import '../widgets/search_field.dart';
import '../widgets/status_banner.dart';
import 'flight_detail_screen.dart';

/// Main screen: search + region controls, a status strip, and a
/// List/Map tab view of all currently tracked aircraft.
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
    _tabController = TabController(length: 2, vsync: this);
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
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _FlightList(provider: provider),
                FlightMap(flights: provider.flights),
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
