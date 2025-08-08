import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../models/hurricane.dart';
import '../models/weather.dart';
import '../utils/theme.dart';
import 'storm_info_panel.dart';

class EnhancedFullScreenMap extends StatefulWidget {
  final List<Hurricane> hurricanes;
  final AnimationController windAnimationController;
  final AnimationController cycloneAnimationController;
  final int selectedTimeIndex;
  final WeatherData? currentWeather;
  final Hurricane? focusedStorm; // Storm to focus on when opening

  const EnhancedFullScreenMap({
    super.key,
    required this.hurricanes,
    required this.windAnimationController,
    required this.cycloneAnimationController,
    required this.selectedTimeIndex,
    this.currentWeather,
    this.focusedStorm,
  });

  @override
  State<EnhancedFullScreenMap> createState() => _EnhancedFullScreenMapState();
}

class _EnhancedFullScreenMapState extends State<EnhancedFullScreenMap> {
  int _selectedTimeIndex = 0;
  Hurricane? selectedStorm;
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    _selectedTimeIndex = widget.selectedTimeIndex;
    selectedStorm = widget.focusedStorm;
    mapController = MapController();

    // Navigate to focused storm if provided
    if (widget.focusedStorm != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToStorm(widget.focusedStorm!);
      });
    }
  }

  void _navigateToStorm(Hurricane storm) {
    final center = _getForecastedCenter(storm, _selectedTimeIndex);
    mapController.move(
      LatLng(center.latitude, center.longitude),
      6.0, // Zoom level
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedStorm != null ? selectedStorm!.name : 'Live Map',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (selectedStorm != null)
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              onPressed: () => _navigateToStorm(selectedStorm!),
              tooltip: 'Center on Storm',
            ),
          IconButton(
            icon: const Icon(Icons.fullscreen_exit),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full-screen map
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: widget.focusedStorm != null
                  ? LatLng(widget.focusedStorm!.latitude,
                      widget.focusedStorm!.longitude)
                  : const LatLng(19.3133, -81.2546),
              initialZoom: widget.focusedStorm != null ? 6.0 : 4,
              maxZoom: 10,
              minZoom: 2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hurricane_watch',
              ),
              // Dynamic wind field visualization (asymmetric + cones)
              PolygonLayer(
                polygons: [
                  ..._generateAsymmetricWindFields(
                      widget.hurricanes, _selectedTimeIndex),
                  ..._generateForecastCones(
                      widget.hurricanes, _selectedTimeIndex),
                ],
              ),
              // Animated wind streamlines (orbiting)
              AnimatedBuilder(
                animation: widget.windAnimationController,
                builder: (context, _) {
                  return MarkerLayer(
                    markers: _generateRealisticWindArrows(
                      widget.hurricanes,
                      _selectedTimeIndex,
                      widget.windAnimationController.value,
                    ),
                  );
                },
              ),
              // Dashed forecast track and heading arrows
              PolylineLayer(
                polylines: _generateDashedPolylines(widget.hurricanes),
              ),
              MarkerLayer(
                markers: _generateHeadingArrows(
                    widget.hurricanes, _selectedTimeIndex),
              ),
              // Hurricane markers (clickable)
              MarkerLayer(
                markers: widget.hurricanes.map((hurricane) {
                  final center =
                      _getForecastedCenter(hurricane, _selectedTimeIndex);
                  return Marker(
                    point: LatLng(center.latitude, center.longitude),
                    width: 100,
                    height: 100,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStorm = hurricane;
                        });
                        _navigateToStorm(hurricane);
                      },
                      child: AnimatedBuilder(
                        animation: widget.cycloneAnimationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: -widget.cycloneAnimationController.value *
                                2 *
                                math.pi,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    AppTheme.getHurricaneCategoryColor(
                                            hurricane.category)
                                        .withOpacity(0.3),
                                    AppTheme.getHurricaneCategoryColor(
                                            hurricane.category)
                                        .withOpacity(0.8 +
                                            (0.2 *
                                                widget
                                                    .cycloneAnimationController
                                                    .value)),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedStorm == hurricane
                                      ? Colors.yellow
                                      : Colors.white,
                                  width: selectedStorm == hurricane ? 5 : 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.getHurricaneCategoryColor(
                                            hurricane.category)
                                        .withOpacity(0.4 +
                                            (0.3 *
                                                widget
                                                    .cycloneAnimationController
                                                    .value)),
                                    blurRadius: 25 +
                                        (15 *
                                            widget.cycloneAnimationController
                                                .value),
                                    spreadRadius: 8 +
                                        (8 *
                                            widget.cycloneAnimationController
                                                .value),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      hurricane.name[0],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Cat ${hurricane.category}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Cayman Islands marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(19.3133, -81.2546),
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.red,
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Forecast time slider at top
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Forecast Timeline',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Time: ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Expanded(
                        child: Slider(
                          value: _selectedTimeIndex.toDouble(),
                          min: 0,
                          max: 48,
                          divisions: 48,
                          label: '${_selectedTimeIndex}h',
                          onChanged: (value) {
                            setState(() {
                              _selectedTimeIndex = value.round();
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${_selectedTimeIndex}h',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Storm navigation buttons (when multiple storms)
          if (widget.hurricanes.length > 1)
            Positioned(
              top: 200,
              right: 20,
              child: Column(
                children: widget.hurricanes.map((storm) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedStorm = storm;
                        });
                        _navigateToStorm(storm);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedStorm == storm
                            ? AppTheme.getHurricaneCategoryColor(storm.category)
                            : Colors.white.withOpacity(0.9),
                        foregroundColor: selectedStorm == storm
                            ? Colors.white
                            : AppTheme.getHurricaneCategoryColor(
                                storm.category),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        storm.name[0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Storm info panel (bottom)
          if (selectedStorm != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: StormInfoPanel(
                hurricane: selectedStorm!,
                onClose: () {
                  setState(() {
                    selectedStorm = null;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // Generate wind fields that change based on forecast time
  // Generate realistic wind arrows that orbit around the storm
  List<Marker> _generateRealisticWindArrows(
      List<Hurricane> hurricanes, int timeIndex, double phase) {
    List<Marker> arrows = [];

    for (final hurricane in hurricanes) {
      final centerPoint = _getForecastedCenter(hurricane, timeIndex);
      final center = LatLng(centerPoint.latitude, centerPoint.longitude);
      final radius = hurricane.windSpeed / 8 * (1.0 + (timeIndex / 48) * 0.5);

      for (int ring = 1; ring <= 4; ring++) {
        final ringDistance = radius * (ring / 4);
        final numArrowsInRing = 6 + (ring * 2);

        for (int j = 0; j < numArrowsInRing; j++) {
          final baseAngle = (j / numArrowsInRing) * 2 * math.pi;
          final spiralOffset = (ring - 1) * (math.pi / 6);
          final animatedAngle = baseAngle +
              spiralOffset -
              phase * 2 * math.pi * (0.5 + ring * 0.25);

          final lat = center.latitude + ringDistance * math.cos(animatedAngle);
          final lng = center.longitude + ringDistance * math.sin(animatedAngle);

          final windDirection = animatedAngle + (math.pi / 2);
          final animationSpeed = 0.3 + (ring / 4) * 0.7;

          arrows.add(Marker(
            point: LatLng(lat, lng),
            width: 16,
            height: 16,
            child: AnimatedBuilder(
              animation: widget.windAnimationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: windDirection -
                      (widget.windAnimationController.value *
                          2 *
                          math.pi *
                          animationSpeed),
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          AppTheme.getHurricaneCategoryColor(hurricane.category)
                              .withOpacity(0.6 + (timeIndex / 48) * 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                );
              },
            ),
          ));
        }
      }
    }

    return arrows;
  }

  // Asymmetric wind fields from NOAA radii or fallback
  List<Polygon> _generateAsymmetricWindFields(
      List<Hurricane> hurricanes, int timeIndex) {
    final polygons = <Polygon>[];
    for (final h in hurricanes) {
      final center = _getForecastedCenter(h, timeIndex);
      if (h.windFields.isNotEmpty) {
        for (final wf in h.windFields) {
          final scale = 1.0 + (timeIndex / 48) * 0.3;
          final base = wf.radius * 0.01 * scale;
          final quads = [1.2, 1.0, 0.9, 1.1];
          final points = <LatLng>[];
          for (int i = 0; i < 72; i++) {
            final ang = (i / 72) * 2 * math.pi;
            final q = ((ang / (math.pi / 2)) % 4).floor();
            final r = base * quads[q];
            points.add(
              LatLng(
                center.latitude + r * math.cos(ang),
                center.longitude + r * math.sin(ang),
              ),
            );
          }
          polygons.add(
            Polygon(
              points: points,
              color: AppTheme.getHurricaneCategoryColor(h.category)
                  .withOpacity(0.1),
              borderColor: AppTheme.getHurricaneCategoryColor(h.category)
                  .withOpacity(0.35),
              borderStrokeWidth: 1.5,
            ),
          );
        }
      } else {
        // Simple circular field when we have no radii
        final baseRadius = h.windSpeed / 10;
        final timeMultiplier = 1.0 + (timeIndex / 48) * 0.5;
        final radius = baseRadius * timeMultiplier;
        final points = <LatLng>[];
        for (int i = 0; i < 36; i++) {
          final ang = i * 10 * math.pi / 180;
          points.add(
            LatLng(
              center.latitude + radius * math.cos(ang),
              center.longitude + radius * math.sin(ang),
            ),
          );
        }
        polygons.add(
          Polygon(
            points: points,
            color:
                AppTheme.getHurricaneCategoryColor(h.category).withOpacity(0.1),
            borderColor: AppTheme.getHurricaneCategoryColor(h.category)
                .withOpacity(0.35),
            borderStrokeWidth: 1.5,
          ),
        );
      }
    }
    return polygons;
  }

  // Forecast cone
  List<Polygon> _generateForecastCones(
      List<Hurricane> hurricanes, int timeIndex) {
    final cones = <Polygon>[];
    for (final h in hurricanes) {
      if (h.forecastTrack.length < 2) continue;
      final start = LatLng(h.latitude, h.longitude);
      final end = LatLng(
        h.forecastTrack.last.latitude,
        h.forecastTrack.last.longitude,
      );
      final points = <LatLng>[];
      const steps = 20;
      for (int i = 0; i <= steps; i++) {
        final t = i / steps;
        final lat = start.latitude + (end.latitude - start.latitude) * t;
        final lng = start.longitude + (end.longitude - start.longitude) * t;
        final width = (0.05 + 0.25 * t) * (1 + timeIndex / 96);
        final angle = math.atan2(
            end.latitude - start.latitude, end.longitude - start.longitude);
        points.add(LatLng(
            lat + width * math.sin(angle), lng - width * math.cos(angle)));
      }
      for (int i = steps; i >= 0; i--) {
        final t = i / steps;
        final lat = start.latitude + (end.latitude - start.latitude) * t;
        final lng = start.longitude + (end.longitude - start.longitude) * t;
        final width = (0.05 + 0.25 * t) * (1 + timeIndex / 96);
        final angle = math.atan2(
            end.latitude - start.latitude, end.longitude - start.longitude);
        points.add(LatLng(
            lat - width * math.sin(angle), lng + width * math.cos(angle)));
      }
      cones.add(
        Polygon(
          points: points,
          color: Colors.orange.withOpacity(0.08),
          borderColor: Colors.orange.withOpacity(0.25),
          borderStrokeWidth: 1.0,
        ),
      );
    }
    return cones;
  }

  // Dashed forecast track
  List<Polyline> _generateDashedPolylines(List<Hurricane> hurricanes) {
    final result = <Polyline>[];
    for (final h in hurricanes) {
      final track = [
        LatLng(h.latitude, h.longitude),
        ...h.forecastTrack.map((p) => LatLng(p.latitude, p.longitude)),
      ];
      if (track.length < 2) continue;
      const dashLen = 0.4;
      bool draw = true;
      for (int i = 0; i < track.length - 1; i++) {
        final a = track[i];
        final b = track[i + 1];
        final dx = b.longitude - a.longitude;
        final dy = b.latitude - a.latitude;
        final dist = math.sqrt(dx * dx + dy * dy);
        if (dist == 0) continue;
        final steps = (dist / dashLen).ceil();
        for (int s = 0; s < steps; s++) {
          final t1 = s / steps;
          final t2 = ((s + 1) / steps).clamp(0.0, 1.0);
          if (draw) {
            result.add(
              Polyline(
                points: [
                  LatLng(a.latitude + dy * t1, a.longitude + dx * t1),
                  LatLng(a.latitude + dy * t2, a.longitude + dx * t2),
                ],
                color: AppTheme.getHurricaneCategoryColor(h.category)
                    .withOpacity(0.8),
                strokeWidth: 2,
              ),
            );
          }
          draw = !draw;
        }
      }
    }
    return result;
  }

  // Heading arrows along track
  List<Marker> _generateHeadingArrows(
      List<Hurricane> hurricanes, int timeIndex) {
    final markers = <Marker>[];
    for (final h in hurricanes) {
      final path = [
        LatLng(h.latitude, h.longitude),
        ...h.forecastTrack.map((p) => LatLng(p.latitude, p.longitude)),
      ];
      if (path.length < 2) continue;
      for (int i = 0; i < path.length - 1; i += 2) {
        final a = path[i];
        final b = path[i + 1];
        final mid = LatLng(
            (a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
        final angle =
            math.atan2(b.latitude - a.latitude, b.longitude - a.longitude);
        markers.add(Marker(
          point: mid,
          width: 18,
          height: 18,
          child: Transform.rotate(
            angle: angle,
            child: Icon(
              Icons.navigation,
              size: 18,
              color: AppTheme.getHurricaneCategoryColor(h.category),
            ),
          ),
        ));
      }
    }
    return markers;
  }

  // Interpolate storm center along forecast track
  LatLng _getForecastedCenter(Hurricane h, int hourOffset) {
    if (h.forecastTrack.isEmpty || hourOffset <= 0) {
      return LatLng(h.latitude, h.longitude);
    }
    final target = h.timestamp.add(Duration(hours: hourOffset));
    ForecastPoint? prev;
    ForecastPoint? next;
    for (final p in h.forecastTrack) {
      if (p.timestamp.isBefore(target) ||
          p.timestamp.isAtSameMomentAs(target)) {
        prev = p;
      }
      if (p.timestamp.isAfter(target)) {
        next = p;
        break;
      }
    }
    prev ??= h.forecastTrack.first;
    next ??= h.forecastTrack.last;
    if (prev.timestamp == next.timestamp) {
      return LatLng(prev.latitude, prev.longitude);
    }
    final total =
        next.timestamp.difference(prev.timestamp).inSeconds.toDouble();
    final done = target
        .difference(prev.timestamp)
        .inSeconds
        .toDouble()
        .clamp(0.0, total);
    final t = total == 0 ? 0.0 : done / total;
    final lat = prev.latitude + (next.latitude - prev.latitude) * t;
    final lng = prev.longitude + (next.longitude - prev.longitude) * t;
    return LatLng(lat, lng);
  }
}
