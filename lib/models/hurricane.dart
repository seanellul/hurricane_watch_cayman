import 'package:json_annotation/json_annotation.dart';

part 'hurricane.g.dart';

@JsonSerializable()
class Hurricane {
  final String id;
  final String name;
  final String basin;
  final String classification;
  final int category;
  final double latitude;
  final double longitude;
  final double windSpeed;
  final double pressure;
  final DateTime timestamp;
  final List<ForecastPoint> forecastTrack;
  final List<WindField> windFields;
  final List<WatchWarning> watchesWarnings;

  Hurricane({
    required this.id,
    required this.name,
    required this.basin,
    required this.classification,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.windSpeed,
    required this.pressure,
    required this.timestamp,
    required this.forecastTrack,
    required this.windFields,
    required this.watchesWarnings,
  });

  factory Hurricane.fromJson(Map<String, dynamic> json) =>
      _$HurricaneFromJson(json);
  Map<String, dynamic> toJson() => _$HurricaneToJson(this);
}

@JsonSerializable()
class ForecastPoint {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double windSpeed;
  final double pressure;
  final int category;

  ForecastPoint({
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.windSpeed,
    required this.pressure,
    required this.category,
  });

  factory ForecastPoint.fromJson(Map<String, dynamic> json) =>
      _$ForecastPointFromJson(json);
  Map<String, dynamic> toJson() => _$ForecastPointToJson(this);
}

@JsonSerializable()
class WindField {
  final double latitude;
  final double longitude;
  final double radius;
  final double windSpeed;
  final String type; // 34kt, 50kt, 64kt

  WindField({
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.windSpeed,
    required this.type,
  });

  factory WindField.fromJson(Map<String, dynamic> json) =>
      _$WindFieldFromJson(json);
  Map<String, dynamic> toJson() => _$WindFieldToJson(this);
}

@JsonSerializable()
class WatchWarning {
  final String type; // Watch, Warning
  final String area;
  final DateTime issued;
  final DateTime expires;
  final List<GeoPoint> coordinates;

  WatchWarning({
    required this.type,
    required this.area,
    required this.issued,
    required this.expires,
    required this.coordinates,
  });

  factory WatchWarning.fromJson(Map<String, dynamic> json) =>
      _$WatchWarningFromJson(json);
  Map<String, dynamic> toJson() => _$WatchWarningToJson(this);
}

@JsonSerializable()
class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint({
    required this.latitude,
    required this.longitude,
  });

  factory GeoPoint.fromJson(Map<String, dynamic> json) =>
      _$GeoPointFromJson(json);
  Map<String, dynamic> toJson() => _$GeoPointToJson(this);
}
