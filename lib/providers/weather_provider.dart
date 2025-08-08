import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hurricane_watch/models/weather.dart';
import 'package:hurricane_watch/models/hurricane.dart';
import 'package:hurricane_watch/services/weather_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherData? _currentWeather;
  List<Hurricane> _activeHurricanes = [];
  bool _isLoading = false;
  String? _error;

  static const _stormsCacheKey = 'storms_cache_v1';
  static const _stormsTsKey = 'storms_cache_ts_v1';
  static const _stormsTtl = Duration(minutes: 15);

  WeatherData? get currentWeather => _currentWeather;
  List<Hurricane> get activeHurricanes => _activeHurricanes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWeatherData() async {
    _setLoading(true);
    _clearError();

    try {
      final weather = await _weatherService.getCurrentWeather();
      _currentWeather = weather;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load weather data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadHurricaneData() async {
    _setLoading(true);
    _clearError();

    try {
      // Try cache first
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_stormsTsKey);
      if (ts != null) {
        final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts, isUtc: true);
        if (DateTime.now().toUtc().difference(cachedAt) <= _stormsTtl) {
          final data = prefs.getString(_stormsCacheKey);
          if (data != null) {
            final List<dynamic> jsonList = json.decode(data);
            _activeHurricanes = jsonList
                .map((e) => Hurricane.fromJson(e as Map<String, dynamic>))
                .toList();
            notifyListeners();
          }
        }
      }

      final hurricanes = await _weatherService.getActiveHurricanes();
      _activeHurricanes = hurricanes;
      // Save cache
      try {
        final prefs2 = await SharedPreferences.getInstance();
        await prefs2.setString(_stormsCacheKey,
            json.encode(_activeHurricanes.map((e) => e.toJson()).toList()));
        await prefs2.setInt(
            _stormsTsKey, DateTime.now().toUtc().millisecondsSinceEpoch);
      } catch (_) {}
      notifyListeners();
    } catch (e) {
      _setError('Failed to load hurricane data: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadHurricaneDetails(String stormId) async {
    _setLoading(true);
    _clearError();

    try {
      final hurricane = await _weatherService.getHurricaneDetails(stormId);

      // Update the hurricane in the list
      final index = _activeHurricanes.indexWhere((h) => h.id == stormId);
      if (index != -1) {
        _activeHurricanes[index] = hurricane;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to load hurricane details: $e');
    } finally {
      _setLoading(false);
    }
  }

  Hurricane? getHurricaneById(String id) {
    try {
      return _activeHurricanes.firstWhere((hurricane) => hurricane.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Hurricane> getHurricanesNearCayman() {
    // Filter hurricanes that might affect Cayman Islands
    // This is a simplified check - in a real app, you'd do more sophisticated calculations
    return _activeHurricanes.where((hurricane) {
      // Check if hurricane is within 500 miles of Cayman
      const caymanLat = 19.3133;
      const caymanLng = -81.2546;

      final distance = _calculateDistance(
        caymanLat,
        caymanLng,
        hurricane.latitude,
        hurricane.longitude,
      );

      return distance < 500; // 500 miles
    }).toList();
  }

  /// Returns the hurricane closest to Cayman with a naive ETA (hours) and confidence.
  /// Confidence is higher when the forecast track passes near Cayman in the next 72h.
  ({Hurricane? storm, double distanceMiles, int etaHours, double confidence})
      getClosestStormProximity() {
    const caymanLat = 19.3133;
    const caymanLng = -81.2546;
    double bestDistance = double.infinity;
    Hurricane? closest;

    for (final h in _activeHurricanes) {
      final d =
          _calculateDistance(caymanLat, caymanLng, h.latitude, h.longitude);
      if (d < bestDistance) {
        bestDistance = d;
        closest = h;
      }
    }

    if (closest == null) {
      return (storm: null, distanceMiles: 0, etaHours: 0, confidence: 0);
    }

    // Naive ETA based on current distance and wind speed proxy
    final speedMph = (closest.windSpeed * 1.15).clamp(5.0, 40.0); // approx
    final etaHours = (bestDistance / speedMph).round();

    // Confidence heuristic: look 72h forecast for min distance to Cayman
    double minFuture = bestDistance;
    for (final p in closest.forecastTrack) {
      final df =
          _calculateDistance(caymanLat, caymanLng, p.latitude, p.longitude);
      if (df < minFuture) minFuture = df;
    }
    double confidence = 0.2;
    if (minFuture < 500) confidence = 0.5;
    if (minFuture < 300) confidence = 0.75;
    if (minFuture < 150) confidence = 0.9;

    return (
      storm: closest,
      distanceMiles: bestDistance,
      etaHours: etaHours,
      confidence: confidence,
    );
  }

  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 3959; // miles

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        sin(lat1Rad) * sin(lat2Rad) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadWeatherData();
    await loadHurricaneData();
  }
}
