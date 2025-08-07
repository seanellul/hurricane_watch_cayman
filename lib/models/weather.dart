import 'package:json_annotation/json_annotation.dart';

part 'weather.g.dart';

@JsonSerializable()
class WeatherData {
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double windSpeed;
  final double windDirection;
  final double pressure;
  final double visibility;
  final String description;
  final String icon;
  final DateTime timestamp;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.description,
    required this.icon,
    required this.timestamp,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) =>
      _$WeatherDataFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherDataToJson(this);
}

@JsonSerializable()
class HourlyForecast {
  final DateTime timestamp;
  final double temperature;
  final double windSpeed;
  final double windDirection;
  final double humidity;
  final double precipitation;
  final String description;
  final String icon;

  HourlyForecast({
    required this.timestamp,
    required this.temperature,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.precipitation,
    required this.description,
    required this.icon,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) =>
      _$HourlyForecastFromJson(json);
  Map<String, dynamic> toJson() => _$HourlyForecastToJson(this);
}

@JsonSerializable()
class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final double windSpeed;
  final double windDirection;
  final double humidity;
  final double precipitation;
  final String description;
  final String icon;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.precipitation,
    required this.description,
    required this.icon,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastFromJson(json);
  Map<String, dynamic> toJson() => _$DailyForecastToJson(this);
}
