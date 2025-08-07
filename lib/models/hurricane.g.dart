// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hurricane.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hurricane _$HurricaneFromJson(Map<String, dynamic> json) => Hurricane(
      id: json['id'] as String,
      name: json['name'] as String,
      basin: json['basin'] as String,
      classification: json['classification'] as String,
      category: (json['category'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      forecastTrack: (json['forecastTrack'] as List<dynamic>)
          .map((e) => ForecastPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      windFields: (json['windFields'] as List<dynamic>)
          .map((e) => WindField.fromJson(e as Map<String, dynamic>))
          .toList(),
      watchesWarnings: (json['watchesWarnings'] as List<dynamic>)
          .map((e) => WatchWarning.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$HurricaneToJson(Hurricane instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'basin': instance.basin,
      'classification': instance.classification,
      'category': instance.category,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'windSpeed': instance.windSpeed,
      'pressure': instance.pressure,
      'timestamp': instance.timestamp.toIso8601String(),
      'forecastTrack': instance.forecastTrack,
      'windFields': instance.windFields,
      'watchesWarnings': instance.watchesWarnings,
    };

ForecastPoint _$ForecastPointFromJson(Map<String, dynamic> json) =>
    ForecastPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      pressure: (json['pressure'] as num).toDouble(),
      category: (json['category'] as num).toInt(),
    );

Map<String, dynamic> _$ForecastPointToJson(ForecastPoint instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'windSpeed': instance.windSpeed,
      'pressure': instance.pressure,
      'category': instance.category,
    };

WindField _$WindFieldFromJson(Map<String, dynamic> json) => WindField(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      windSpeed: (json['windSpeed'] as num).toDouble(),
      type: json['type'] as String,
    );

Map<String, dynamic> _$WindFieldToJson(WindField instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius': instance.radius,
      'windSpeed': instance.windSpeed,
      'type': instance.type,
    };

WatchWarning _$WatchWarningFromJson(Map<String, dynamic> json) => WatchWarning(
      type: json['type'] as String,
      area: json['area'] as String,
      issued: DateTime.parse(json['issued'] as String),
      expires: DateTime.parse(json['expires'] as String),
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => GeoPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WatchWarningToJson(WatchWarning instance) =>
    <String, dynamic>{
      'type': instance.type,
      'area': instance.area,
      'issued': instance.issued.toIso8601String(),
      'expires': instance.expires.toIso8601String(),
      'coordinates': instance.coordinates,
    };

GeoPoint _$GeoPointFromJson(Map<String, dynamic> json) => GeoPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$GeoPointToJson(GeoPoint instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
