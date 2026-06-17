import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/flight_state.dart';
import '../services/flight_service.dart';
import '../utils/constants.dart';

/// Central app state: the current list of live flights, the selected
/// region, loading/error status, search filter, and the auto-refresh
/// timer. Screens/widgets read this via Provider/Consumer instead of
/// talking to [FlightService] directly, keeping networking out of the UI.
class FlightProvider extends ChangeNotifier {
  FlightProvider({FlightService? service})
      : _service = service ?? FlightService(),
        _selectedRegion = AppConstants.regions.first;

  final FlightService _service;
  Timer? _refreshTimer;

  List<FlightState> _flights = [];
  bool _isLoading = false;
  String? _errorMessage;
  RegionOption _selectedRegion;
  bool _autoRefresh = true;
  String _searchQuery = '';

  /// Flights filtered by the current search query (callsign or country).
  List<FlightState> get flights {
    if (_searchQuery.isEmpty) return _flights;
    final query = _searchQuery.toLowerCase();
    return _flights
        .where((f) =>
            f.displayName.toLowerCase().contains(query) ||
            f.originCountry.toLowerCase().contains(query))
        .toList();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RegionOption get selectedRegion => _selectedRegion;
  bool get autoRefresh => _autoRefresh;
  int get totalCount => _flights.length;

  /// Kicks off the first load and starts auto-refresh if enabled. Call
  /// once from the widget that owns this provider (e.g. in `main.dart`).
  void start() {
    loadFlights();
    if (_autoRefresh) _startTimer();
  }

  Future<void> loadFlights() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _flights = await _service.fetchStates(bbox: _selectedRegion.bbox);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectRegion(RegionOption region) {
    if (region == _selectedRegion) return;
    _selectedRegion = region;
    loadFlights();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleAutoRefresh(bool enabled) {
    _autoRefresh = enabled;
    if (enabled) {
      _startTimer();
    } else {
      _refreshTimer?.cancel();
    }
    notifyListeners();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      AppConstants.defaultRefreshInterval,
      (_) => loadFlights(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _service.dispose();
    super.dispose();
  }
}
