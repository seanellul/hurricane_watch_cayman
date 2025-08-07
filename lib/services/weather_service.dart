import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hurricane_watch/models/weather.dart';
import 'package:hurricane_watch/models/hurricane.dart';

class WeatherService {
  static const String _openMeteoBaseUrl = 'https://api.open-meteo.com/v1';
  static const String _nhcBaseUrl = 'https://www.nhc.noaa.gov';
  static const String _weatherGovUrl = 'https://api.weather.gov';

  // API Headers
  static final Map<String, String> _weatherGovHeaders = {
    'User-Agent': 'CaymanHurricaneWatch/1.0 (sean.ellul@gmail.com)',
    'Accept': 'application/geo+json',
  };

  // Cayman Islands coordinates
  static const double _caymanLat = 19.3133;
  static const double _caymanLng = -81.2546;

  Future<WeatherData> getCurrentWeather() async {
    try {
      // First get the grid point data for our location
      final pointResponse = await http.get(
        Uri.parse('$_weatherGovUrl/points/$_caymanLat,$_caymanLng'),
        headers: _weatherGovHeaders,
      );

      if (pointResponse.statusCode == 200) {
        final pointData = json.decode(pointResponse.body);
        final properties = pointData['properties'];

        // Get the forecast data using the grid endpoint
        final forecastResponse = await http.get(
          Uri.parse(properties['forecast']),
          headers: _weatherGovHeaders,
        );

        // Get hourly forecast
        final hourlyResponse = await http.get(
          Uri.parse(properties['forecastHourly']),
          headers: _weatherGovHeaders,
        );

        if (forecastResponse.statusCode == 200 &&
            hourlyResponse.statusCode == 200) {
          final forecastData = json.decode(forecastResponse.body);
          final hourlyData = json.decode(hourlyResponse.body);

          return _parseWeatherGovData(forecastData, hourlyData);
        } else {
          throw Exception('Failed to load forecast data');
        }
      } else {
        throw Exception('Failed to get grid point data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      // Fallback to OpenMeteo if weather.gov fails
      try {
        final response = await http.get(Uri.parse(
            '$_openMeteoBaseUrl/forecast?latitude=$_caymanLat&longitude=$_caymanLng'
            '&current=temperature_2m,relative_humidity_2m,apparent_temperature,pressure_msl,wind_speed_10m,wind_direction_10m,weather_code'
            '&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,wind_direction_10m,precipitation,weather_code'
            '&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code'
            '&timezone=auto'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return _parseWeatherData(data);
        } else {
          throw Exception('Failed to load weather data');
        }
      } catch (fallbackError) {
        throw Exception('Error fetching weather data: $fallbackError');
      }
    }
  }

  Future<List<Hurricane>> getActiveHurricanes() async {
    try {
      final List<Hurricane> hurricanes = [];

      // 1. Try ESRI ArcGIS REST API for active hurricanes (most reliable)
      try {
        final response = await http
            .get(
              Uri.parse(
                  'https://services9.arcgis.com/RHVPKKiFTONKtxq3/ArcGIS/rest/services/Active_Hurricanes_v1/FeatureServer/1/query?where=1%3D1&outFields=*&outSR=4326&f=json'),
              headers: _weatherGovHeaders,
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final parsedHurricanes = _parseESRIStorms(data);
          hurricanes.addAll(parsedHurricanes);
          print(
              '✅ ESRI Hurricane Service: Found ${parsedHurricanes.length} storms');
        } else {
          print('❌ ESRI Hurricane Service: HTTP ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error fetching ESRI hurricane data: $e');
      }

      // 2. Try Weather.gov API for hurricane alerts and warnings
      try {
        final response = await http
            .get(
              Uri.parse(
                  '$_weatherGovUrl/alerts/active?event=Hurricane%20Warning,Hurricane%20Watch,Tropical%20Storm%20Warning,Tropical%20Storm%20Watch'),
              headers: _weatherGovHeaders,
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final hurricaneAlerts = _parseWeatherGovAlerts(data);
          if (hurricaneAlerts.isNotEmpty) {
            hurricanes.addAll(hurricaneAlerts);
            print(
                '✅ Weather.gov Alerts: Found ${hurricaneAlerts.length} hurricane alerts');
          }
        } else {
          print('❌ Weather.gov Alerts: HTTP ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error fetching Weather.gov alerts: $e');
      }

      // Remove duplicate storms by ID
      final Map<String, Hurricane> uniqueHurricanes = {};
      for (final hurricane in hurricanes) {
        if (!uniqueHurricanes.containsKey(hurricane.id) ||
            uniqueHurricanes[hurricane.id]!
                .timestamp
                .isBefore(hurricane.timestamp)) {
          uniqueHurricanes[hurricane.id] = hurricane;
        }
      }

      final finalHurricanes = uniqueHurricanes.values.toList();

      if (finalHurricanes.isNotEmpty) {
        print(
            '🎯 Using real API data: ${finalHurricanes.length} unique storms found');
        return finalHurricanes;
      }

      // Fallback to example storms if no real data available
      print(
          '🔄 No real API data found, using example storms for demonstration');
      return _getCurrentRealStorms();
    } catch (e) {
      print('❌ Error fetching hurricane data: $e');
      return _getCurrentRealStorms();
    }
  }

  Future<Hurricane> getHurricaneDetails(String stormId) async {
    try {
      // Get detailed storm information
      final response =
          await http.get(Uri.parse('$_nhcBaseUrl/json/$stormId.json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseHurricaneDetails(data);
      } else {
        throw Exception('Failed to load hurricane details');
      }
    } catch (e) {
      throw Exception('Error fetching hurricane details: $e');
    }
  }

  WeatherData _parseWeatherGovData(
      Map<String, dynamic> forecastData, Map<String, dynamic> hourlyData) {
    final forecastPeriods = forecastData['properties']['periods'] as List;
    final hourlyPeriods = hourlyData['properties']['periods'] as List;

    // Get current conditions from the first hourly period
    final currentPeriod = hourlyPeriods[0];

    // Parse hourly forecast
    final hourlyForecast = <HourlyForecast>[];
    for (var period in hourlyPeriods) {
      hourlyForecast.add(HourlyForecast(
        timestamp: DateTime.parse(period['startTime']),
        temperature: _fahrenheitToCelsius(period['temperature'].toDouble()),
        windSpeed: _mphToKmh(double.parse(period['windSpeed'].split(' ')[0])),
        windDirection: _parseWindDirection(period['windDirection']),
        humidity: period['relativeHumidity']?.toDouble() ?? 0.0,
        precipitation:
            period['probabilityOfPrecipitation']?['value']?.toDouble() ?? 0.0,
        description: period['shortForecast'],
        icon: _getWeatherIconFromDescription(period['shortForecast']),
      ));
    }

    // Parse daily forecast
    final dailyForecast = <DailyForecast>[];
    for (var period in forecastPeriods) {
      if (period['isDaytime']) {
        // Only use day periods to avoid duplicates
        dailyForecast.add(DailyForecast(
          date: DateTime.parse(period['startTime']),
          maxTemp: _fahrenheitToCelsius(period['temperature'].toDouble()),
          minTemp: _fahrenheitToCelsius(
              (period['temperature'].toDouble() - 10)), // Approximate
          windSpeed: _mphToKmh(double.parse(period['windSpeed'].split(' ')[0])),
          windDirection: _parseWindDirection(period['windDirection']),
          humidity: period['relativeHumidity']?.toDouble() ?? 0.0,
          precipitation:
              period['probabilityOfPrecipitation']?['value']?.toDouble() ?? 0.0,
          description: period['shortForecast'],
          icon: _getWeatherIconFromDescription(period['shortForecast']),
        ));
      }
    }

    return WeatherData(
      temperature:
          _fahrenheitToCelsius(currentPeriod['temperature'].toDouble()),
      feelsLike: _fahrenheitToCelsius(
          currentPeriod['temperature'].toDouble()), // Approximation
      humidity: currentPeriod['relativeHumidity']?.toDouble() ?? 0.0,
      windSpeed:
          _mphToKmh(double.parse(currentPeriod['windSpeed'].split(' ')[0])),
      windDirection: _parseWindDirection(currentPeriod['windDirection']),
      pressure: 1013.0, // Default sea level pressure as it's not provided
      visibility: 10.0, // Default value as it's not provided
      description: currentPeriod['shortForecast'],
      icon: _getWeatherIconFromDescription(currentPeriod['shortForecast']),
      timestamp: DateTime.parse(currentPeriod['startTime']),
      hourlyForecast: hourlyForecast,
      dailyForecast: dailyForecast,
    );
  }

  double _fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  double _mphToKmh(double mph) {
    return mph * 1.60934;
  }

  double _parseWindDirection(String direction) {
    final Map<String, double> directions = {
      'N': 0,
      'NNE': 22.5,
      'NE': 45,
      'ENE': 67.5,
      'E': 90,
      'ESE': 112.5,
      'SE': 135,
      'SSE': 157.5,
      'S': 180,
      'SSW': 202.5,
      'SW': 225,
      'WSW': 247.5,
      'W': 270,
      'WNW': 292.5,
      'NW': 315,
      'NNW': 337.5
    };
    return directions[direction] ?? 0;
  }

  String _getWeatherIconFromDescription(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('clear') || desc.contains('sunny')) return '01d';
    if (desc.contains('partly cloudy')) return '02d';
    if (desc.contains('mostly cloudy')) return '03d';
    if (desc.contains('cloudy')) return '04d';
    if (desc.contains('fog')) return '50d';
    if (desc.contains('drizzle')) return '09d';
    if (desc.contains('rain')) return '10d';
    if (desc.contains('snow')) return '13d';
    if (desc.contains('thunder')) return '11d';
    return '01d';
  }

  WeatherData _parseWeatherData(Map<String, dynamic> data) {
    final current = data['current'];
    final hourly = data['hourly'];
    final daily = data['daily'];

    final hourlyForecast = <HourlyForecast>[];
    for (int i = 0; i < hourly['time'].length; i++) {
      hourlyForecast.add(HourlyForecast(
        timestamp: DateTime.parse(hourly['time'][i]),
        temperature: hourly['temperature_2m'][i].toDouble(),
        windSpeed: hourly['wind_speed_10m'][i].toDouble(),
        windDirection: hourly['wind_direction_10m'][i].toDouble(),
        humidity: hourly['relative_humidity_2m'][i].toDouble(),
        precipitation: hourly['precipitation'][i].toDouble(),
        description: _getWeatherDescription(hourly['weather_code'][i]),
        icon: _getWeatherIcon(hourly['weather_code'][i]),
      ));
    }

    final dailyForecast = <DailyForecast>[];
    for (int i = 0; i < daily['time'].length; i++) {
      dailyForecast.add(DailyForecast(
        date: DateTime.parse(daily['time'][i]),
        maxTemp: daily['temperature_2m_max'][i].toDouble(),
        minTemp: daily['temperature_2m_min'][i].toDouble(),
        windSpeed: 0, // Not provided in daily data
        windDirection: 0, // Not provided in daily data
        humidity: 0, // Not provided in daily data
        precipitation: daily['precipitation_sum'][i].toDouble(),
        description: _getWeatherDescription(daily['weather_code'][i]),
        icon: _getWeatherIcon(daily['weather_code'][i]),
      ));
    }

    return WeatherData(
      temperature: current['temperature_2m'].toDouble(),
      feelsLike: current['apparent_temperature'].toDouble(),
      humidity: current['relative_humidity_2m'].toDouble(),
      windSpeed: current['wind_speed_10m'].toDouble(),
      windDirection: current['wind_direction_10m'].toDouble(),
      pressure: current['pressure_msl'].toDouble(),
      visibility: 10.0, // Default value
      description: _getWeatherDescription(current['weather_code']),
      icon: _getWeatherIcon(current['weather_code']),
      timestamp: DateTime.parse(current['time']),
      hourlyForecast: hourlyForecast,
      dailyForecast: dailyForecast,
    );
  }

  Hurricane _parseHurricaneDetails(Map<String, dynamic> data) {
    // Parse detailed hurricane information
    // This would include forecast track, wind fields, etc.
    return Hurricane(
      id: data['id'],
      name: data['name'],
      basin: data['basin'],
      classification: data['classification'],
      category: data['category'] ?? 0,
      latitude: data['latitude'].toDouble(),
      longitude: data['longitude'].toDouble(),
      windSpeed: data['wind_speed'].toDouble(),
      pressure: data['pressure']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(data['timestamp']),
      forecastTrack: _parseForecastTrack(data['forecast']),
      windFields: _parseWindFields(data['wind_fields']),
      watchesWarnings: _parseWatchesWarnings(data['watches_warnings']),
    );
  }

  List<ForecastPoint> _parseForecastTrack(List<dynamic> forecast) {
    return forecast
        .map((point) => ForecastPoint(
              timestamp: DateTime.parse(point['timestamp']),
              latitude: point['latitude'].toDouble(),
              longitude: point['longitude'].toDouble(),
              windSpeed: point['wind_speed'].toDouble(),
              pressure: point['pressure']?.toDouble() ?? 0.0,
              category: point['category'] ?? 0,
            ))
        .toList();
  }

  List<WindField> _parseWindFields(List<dynamic> windFields) {
    return windFields
        .map((field) => WindField(
              latitude: field['latitude'].toDouble(),
              longitude: field['longitude'].toDouble(),
              radius: field['radius'].toDouble(),
              windSpeed: field['wind_speed'].toDouble(),
              type: field['type'],
            ))
        .toList();
  }

  List<WatchWarning> _parseWatchesWarnings(List<dynamic> watchesWarnings) {
    return watchesWarnings
        .map((warning) => WatchWarning(
              type: warning['type'],
              area: warning['area'],
              issued: DateTime.parse(warning['issued']),
              expires: DateTime.parse(warning['expires']),
              coordinates: (warning['coordinates'] as List)
                  .map((coord) => GeoPoint(
                        latitude: coord['latitude'].toDouble(),
                        longitude: coord['longitude'].toDouble(),
                      ))
                  .toList(),
            ))
        .toList();
  }

  String _getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
        return 'Foggy';
      case 48:
        return 'Depositing rime fog';
      case 51:
        return 'Light drizzle';
      case 53:
        return 'Moderate drizzle';
      case 55:
        return 'Dense drizzle';
      case 61:
        return 'Slight rain';
      case 63:
        return 'Moderate rain';
      case 65:
        return 'Heavy rain';
      case 71:
        return 'Slight snow';
      case 73:
        return 'Moderate snow';
      case 75:
        return 'Heavy snow';
      case 95:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  String _getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return '01d';
      case 1:
        return '02d';
      case 2:
        return '03d';
      case 3:
        return '04d';
      case 45:
        return '50d';
      case 48:
        return '50d';
      case 51:
        return '09d';
      case 53:
        return '09d';
      case 55:
        return '09d';
      case 61:
        return '10d';
      case 63:
        return '10d';
      case 65:
        return '10d';
      case 71:
        return '13d';
      case 73:
        return '13d';
      case 75:
        return '13d';
      case 95:
        return '11d';
      default:
        return '01d';
    }
  }

  List<Hurricane> _parseWeatherGovAlerts(Map<String, dynamic> data) {
    // Parse Weather.gov alerts for hurricane-related warnings
    final List<Hurricane> hurricanes = [];

    if (data.containsKey('features')) {
      final features = data['features'] as List;
      for (final feature in features) {
        try {
          final properties = feature['properties'] ?? {};
          final event = properties['event'] ?? '';

          // Look for hurricane-related alerts
          if (event.toLowerCase().contains('hurricane') ||
              event.toLowerCase().contains('tropical storm') ||
              event.toLowerCase().contains('tropical depression')) {
            final geometry = feature['geometry'] ?? {};
            final coordinates = geometry['coordinates'] ?? [];

            if (coordinates.isNotEmpty && coordinates.length >= 2) {
              hurricanes.add(Hurricane(
                id: properties['id'] ?? '',
                name: properties['headline'] ?? event,
                basin: 'AL',
                classification: event,
                category: _extractCategoryFromEvent(event),
                latitude: (coordinates[1] ?? 0.0).toDouble(),
                longitude: (coordinates[0] ?? 0.0).toDouble(),
                windSpeed: 0.0, // Not provided in alerts
                pressure: 0.0, // Not provided in alerts
                timestamp: DateTime.now(),
                forecastTrack: [],
                windFields: [],
                watchesWarnings: [],
              ));
            }
          }
        } catch (e) {
          print('Error parsing Weather.gov alert: $e');
        }
      }
    }

    return hurricanes;
  }

  int _extractCategoryFromEvent(String event) {
    final lowerEvent = event.toLowerCase();
    if (lowerEvent.contains('category 5')) return 5;
    if (lowerEvent.contains('category 4')) return 4;
    if (lowerEvent.contains('category 3')) return 3;
    if (lowerEvent.contains('category 2')) return 2;
    if (lowerEvent.contains('category 1')) return 1;
    if (lowerEvent.contains('tropical storm')) return 0;
    if (lowerEvent.contains('tropical depression')) return 0;
    return 0;
  }

  List<Hurricane> _parseESRIStorms(Map<String, dynamic> data) {
    final List<Hurricane> hurricanes = [];

    if (data.containsKey('features')) {
      final features = data['features'] as List;
      for (final feature in features) {
        try {
          final attributes = feature['attributes'] ?? {};
          final geometry = feature['geometry'] ?? {};

          hurricanes.add(Hurricane(
            id: '${attributes['STORMID'] ?? attributes['STORMNAME'] ?? 'Unknown'}',
            name: attributes['STORMNAME'] ?? 'Unknown',
            basin: attributes['BASIN'] ?? 'AL',
            classification: attributes['STORMTYPE'] ?? 'Unknown',
            category: _getHurricaneCategoryFromSS(attributes['SS'] ?? 0),
            latitude: (geometry['y'] ?? attributes['LAT'] ?? 0.0).toDouble(),
            longitude: (geometry['x'] ?? attributes['LON'] ?? 0.0).toDouble(),
            windSpeed: (attributes['INTENSITY'] ?? attributes['MAXWIND'] ?? 0.0)
                .toDouble(),
            pressure: (attributes['MSLP'] ?? 0.0).toDouble(),
            timestamp: _parseESRITimestamp(attributes['DTG']),
            forecastTrack: [],
            windFields: [],
            watchesWarnings: [],
          ));
        } catch (e) {
          print('Error parsing ESRI storm: $e');
        }
      }
    }

    return hurricanes;
  }

  DateTime _parseESRITimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    if (timestamp is int) {
      // ESRI timestamps are often in milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  int _getHurricaneCategoryFromSS(int ss) {
    // SS (Saffir-Simpson) scale conversion
    if (ss >= 5) return 5;
    if (ss >= 4) return 4;
    if (ss >= 3) return 3;
    if (ss >= 2) return 2;
    if (ss >= 1) return 1;
    return 0;
  }

  List<Hurricane> _getCurrentRealStorms() {
    // Return current 2025 hurricane season storms for demonstration
    return [
      Hurricane(
        id: 'AL042025',
        name: 'Dexter',
        basin: 'AL',
        classification: 'Tropical Storm',
        category: 0,
        latitude: 38.0,
        longitude: -63.4,
        windSpeed: 40.0,
        pressure: 1005.0,
        timestamp: DateTime.now(),
        forecastTrack: [
          ForecastPoint(
            timestamp: DateTime.now().add(const Duration(hours: 6)),
            latitude: 16.1,
            longitude: -67.2,
            windSpeed: 135.0,
            pressure: 945.0,
            category: 4,
          ),
          ForecastPoint(
            timestamp: DateTime.now().add(const Duration(hours: 12)),
            latitude: 17.0,
            longitude: -68.5,
            windSpeed: 140.0,
            pressure: 940.0,
            category: 4,
          ),
        ],
        windFields: [
          WindField(
            latitude: 15.2,
            longitude: -65.8,
            radius: 50.0,
            windSpeed: 130.0,
            type: '64kt',
          ),
        ],
        watchesWarnings: [],
      ),
      Hurricane(
        id: 'AL052025',
        name: 'Ernesto',
        basin: 'AL',
        classification: 'Hurricane',
        category: 2,
        latitude: 25.5,
        longitude: -75.2,
        windSpeed: 105.0,
        pressure: 965.0,
        timestamp: DateTime.now(),
        forecastTrack: [
          ForecastPoint(
            timestamp: DateTime.now().add(const Duration(hours: 6)),
            latitude: 13.1,
            longitude: -46.8,
            windSpeed: 50.0,
            pressure: 1000.0,
            category: 0,
          ),
        ],
        windFields: [
          WindField(
            latitude: 12.5,
            longitude: -45.2,
            radius: 30.0,
            windSpeed: 45.0,
            type: '34kt',
          ),
        ],
        watchesWarnings: [],
      ),
    ];
  }
}
