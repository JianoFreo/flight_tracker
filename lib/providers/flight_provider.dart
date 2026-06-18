import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/flight_state.dart';
import '../services/flight_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Sort keys available in the flight list/map.
enum FlightSortBy { callsign, altitude, speed, country, lastContact }

/// Three-way ground filter: show everything, only airborne, or only
/// aircraft currently on the ground.
enum GroundFilter { all, airborneOnly, groundedOnly }

/// Central app state: the current list of live flights, the selected
/// region, filters/sorting, loading/error status, search filter, and
/// the auto-refresh timer. Screens/widgets read this via
/// Provider/Consumer instead of talking to [FlightService] directly,
/// keeping networking out of the UI.
class FlightProvider extends ChangeNotifier {
  FlightProvider({FlightService? service, StorageService? storage})
      : _service = service ?? FlightService(),
        _storage = storage ?? StorageService(),
        _selectedRegion = AppConstants.regions.first;

  final FlightService _service;
  final StorageService _storage;
  Timer? _refreshTimer;
  Duration _refreshInterval = AppConstants.defaultRefreshInterval;

  List<FlightState> _flights = [];
  bool _isLoading = false;
  String? _errorMessage;
  RegionOption _selectedRegion;
  bool _autoRefresh = true;
  String _searchQuery = '';

  // Filtering & sorting
  GroundFilter _groundFilter = GroundFilter.all;
  double? _minAltitudeMeters;
  double? _maxAltitudeMeters;
  FlightSortBy _sortBy = FlightSortBy.callsign;
  bool _sortAscending = true;

  // Offline cache fallback
  bool _isShowingCachedData = false;
  DateTime? _cachedAt;

  /// Flights after search, ground/altitude filters, and sort are applied.
  /// This is what every screen should read — never `_flights` directly.
  List<FlightState> get flights {
    var result = List<FlightState>.from(_flights);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((f) =>
              f.displayName.toLowerCase().contains(query) ||
              f.originCountry.toLowerCase().contains(query))
          .toList();
    }

    if (_groundFilter == GroundFilter.airborneOnly) {
      result = result.where((f) => !f.onGround).toList();
    } else if (_groundFilter == GroundFilter.groundedOnly) {
      result = result.where((f) => f.onGround).toList();
    }

    if (_minAltitudeMeters != null) {
      result = result.where((f) => (f.baroAltitude ?? 0) >= _minAltitudeMeters!).toList();
    }
    if (_maxAltitudeMeters != null) {
      result = result.where((f) => (f.baroAltitude ?? 0) <= _maxAltitudeMeters!).toList();
    }

    result.sort(_comparator);
    if (!_sortAscending) result = result.reversed.toList();

    return result;
  }

  /// Unfiltered flights — used by the statistics screen, which wants to
  /// summarize everything currently fetched, not just the filtered view.
  List<FlightState> get allFlights => _flights;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RegionOption get selectedRegion => _selectedRegion;
  bool get autoRefresh => _autoRefresh;
  int get totalCount => _flights.length;
  GroundFilter get groundFilter => _groundFilter;
  double? get minAltitudeMeters => _minAltitudeMeters;
  double? get maxAltitudeMeters => _maxAltitudeMeters;
  FlightSortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  bool get isShowingCachedData => _isShowingCachedData;
  DateTime? get cachedAt => _cachedAt;
  bool get hasActiveFilters =>
      _groundFilter != GroundFilter.all || _minAltitudeMeters != null || _maxAltitudeMeters != null;

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
      _isShowingCachedData = false;
      _cachedAt = null;
      unawaited(_storage.cacheFlights(_flights));
    } catch (e) {
      _errorMessage = e.toString();
      await _fallBackToCacheIfAvailable();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fallBackToCacheIfAvailable() async {
    // Only fall back if we have nothing on screen already — if a
    // previous successful fetch is still showing, keep that rather than
    // overwriting it with possibly-older cached data.
    if (_flights.isNotEmpty) return;
    final cached = await _storage.loadCachedFlights();
    if (cached == null) return;
    final (flights, cachedAt) = cached;
    _flights = flights;
    _isShowingCachedData = true;
    _cachedAt = cachedAt;
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

  void setGroundFilter(GroundFilter filter) {
    _groundFilter = filter;
    notifyListeners();
  }

  /// Pass `null` for either bound to clear that bound. Altitudes are in
  /// meters internally regardless of the display unit system.
  void setAltitudeRange(double? minMeters, double? maxMeters) {
    _minAltitudeMeters = minMeters;
    _maxAltitudeMeters = maxMeters;
    notifyListeners();
  }

  void clearFilters() {
    _groundFilter = GroundFilter.all;
    _minAltitudeMeters = null;
    _maxAltitudeMeters = null;
    notifyListeners();
  }

  void setSort(FlightSortBy sortBy, {bool? ascending}) {
    _sortBy = sortBy;
    if (ascending != null) _sortAscending = ascending;
    notifyListeners();
  }

  void toggleSortDirection() {
    _sortAscending = !_sortAscending;
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

  /// Called by the Settings screen when the user changes the refresh
  /// interval. Restarts the timer immediately if auto-refresh is on.
  void setRefreshInterval(Duration interval) {
    _refreshInterval = interval;
    if (_autoRefresh) _startTimer();
  }

  int _comparator(FlightState a, FlightState b) {
    switch (_sortBy) {
      case FlightSortBy.callsign:
        return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      case FlightSortBy.altitude:
        return (a.baroAltitude ?? -1).compareTo(b.baroAltitude ?? -1);
      case FlightSortBy.speed:
        return (a.velocity ?? -1).compareTo(b.velocity ?? -1);
      case FlightSortBy.country:
        return a.originCountry.toLowerCase().compareTo(b.originCountry.toLowerCase());
      case FlightSortBy.lastContact:
        return a.lastContact.compareTo(b.lastContact);
    }
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => loadFlights());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _service.dispose();
    super.dispose();
  }
}
