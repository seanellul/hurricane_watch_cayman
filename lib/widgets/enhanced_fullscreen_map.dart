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
    mapController.move(
      LatLng(storm.latitude, storm.longitude),
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
              // Dynamic wind field visualization
              PolygonLayer(
                polygons: _generateTimeBasedWindFields(
                    widget.hurricanes, _selectedTimeIndex),
              ),
              // Animated wind arrows
              MarkerLayer(
                markers: _generateRealisticWindArrows(
                    widget.hurricanes, _selectedTimeIndex),
              ),
              // Hurricane markers (clickable)
              MarkerLayer(
                markers: widget.hurricanes.map((hurricane) {
                  return Marker(
                    point: LatLng(hurricane.latitude, hurricane.longitude),
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
  List<Polygon> _generateTimeBasedWindFields(
      List<Hurricane> hurricanes, int timeIndex) {
    List<Polygon> windFields = [];

    for (final hurricane in hurricanes) {
      final center = LatLng(hurricane.latitude, hurricane.longitude);
      final baseRadius = hurricane.windSpeed / 10;
      final timeMultiplier = 1.0 + (timeIndex / 48) * 0.5;
      final radius = baseRadius * timeMultiplier;

      List<LatLng> points = [];
      for (int i = 0; i < 36; i++) {
        final angle = i * 10 * math.pi / 180;
        final lat = center.latitude + radius * math.cos(angle);
        final lng = center.longitude + radius * math.sin(angle);
        points.add(LatLng(lat, lng));
      }

      windFields.add(Polygon(
        points: points,
        color: AppTheme.getHurricaneCategoryColor(hurricane.category)
            .withOpacity(0.15 + (timeIndex / 48) * 0.1),
        borderColor: AppTheme.getHurricaneCategoryColor(hurricane.category),
        borderStrokeWidth: 2,
      ));
    }

    return windFields;
  }

  // Generate realistic wind arrows
  List<Marker> _generateRealisticWindArrows(
      List<Hurricane> hurricanes, int timeIndex) {
    List<Marker> arrows = [];

    for (final hurricane in hurricanes) {
      final center = LatLng(hurricane.latitude, hurricane.longitude);
      final radius = hurricane.windSpeed / 8;

      for (int ring = 1; ring <= 4; ring++) {
        final ringDistance = radius * (ring / 4);
        final numArrowsInRing = 6 + (ring * 2);

        for (int j = 0; j < numArrowsInRing; j++) {
          final baseAngle = (j / numArrowsInRing) * 2 * math.pi;
          final spiralOffset = (ring - 1) * (math.pi / 6);
          final angle = baseAngle + spiralOffset;

          final lat = center.latitude + ringDistance * math.cos(angle);
          final lng = center.longitude + ringDistance * math.sin(angle);

          final windDirection = angle + (math.pi / 2);
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
}
