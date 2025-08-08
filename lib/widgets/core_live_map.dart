import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../models/hurricane.dart';
import '../models/weather.dart';
import '../utils/theme.dart';
import 'storm_info_panel.dart';
// Fullscreen map not used here

class CoreLiveMap extends StatefulWidget {
  final List<Hurricane> hurricanes;
  final AnimationController windAnimationController;
  final AnimationController cycloneAnimationController;
  final WeatherData? currentWeather;

  const CoreLiveMap({
    super.key,
    required this.hurricanes,
    required this.windAnimationController,
    required this.cycloneAnimationController,
    this.currentWeather,
  });

  @override
  State<CoreLiveMap> createState() => _CoreLiveMapState();
}

class _CoreLiveMapState extends State<CoreLiveMap> {
  int _selectedTimeIndex = 0;
  Hurricane? selectedStorm;
  bool showControls = true;
  bool showStormInfo = false;
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height, // Full screen height
      width: MediaQuery.of(context).size.width, // Full screen width
      child: Stack(
        children: [
          // Full-background map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(19.3133, -81.2546),
              initialZoom: 4.5,
              maxZoom: 12,
              minZoom: 2,
              // Remove tap toggling to prevent overlays from disappearing during pans
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hurricane_watch',
              ),
              // Dynamic wind field visualization
              PolygonLayer(
                polygons: [
                  ..._generateAsymmetricWindFields(
                    widget.hurricanes,
                    _selectedTimeIndex,
                  ),
                  ..._generateForecastCones(
                    widget.hurricanes,
                    _selectedTimeIndex,
                  ),
                ],
              ),
              // Realistic wind streamlines orbiting around storm center
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
              // Forecast track as dashed polylines
              PolylineLayer(
                polylines: _generateDashedPolylines(
                  widget.hurricanes,
                ),
              ),
              // Heading arrows along the forecast path
              MarkerLayer(
                markers: _generateHeadingArrows(
                  widget.hurricanes,
                  _selectedTimeIndex,
                ),
              ),
              // Hurricane eye markers with improved design (clickable)
              MarkerLayer(
                markers: widget.hurricanes.map((hurricane) {
                  final forecastedCenter = _getForecastedCenter(
                    hurricane,
                    _selectedTimeIndex,
                  );
                  return Marker(
                    point: LatLng(
                        forecastedCenter.latitude, forecastedCenter.longitude),
                    width: 80,
                    height: 80,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedStorm =
                              selectedStorm == hurricane ? null : hurricane;
                        });

                        // Animate camera to focus on the selected storm
                        _mapController.move(
                          LatLng(forecastedCenter.latitude,
                              forecastedCenter.longitude),
                          6.0, // Zoom level
                        );
                      },
                      child: AnimatedBuilder(
                        animation: widget.cycloneAnimationController,
                        builder: (context, child) {
                          // Use pulsing instead of rotation
                          final pulseScale = 1.0 +
                              (widget.cycloneAnimationController.value * 0.1);

                          return Transform.scale(
                            scale: pulseScale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer ring (wind field indicator)
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.getHurricaneCategoryColor(
                                              hurricane.category)
                                          .withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                // Middle ring
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.getHurricaneCategoryColor(
                                            hurricane.category)
                                        .withOpacity(0.2),
                                    border: Border.all(
                                      color: AppTheme.getHurricaneCategoryColor(
                                              hurricane.category)
                                          .withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                // Inner storm eye
                                Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.9),
                                        AppTheme.getHurricaneCategoryColor(
                                            hurricane.category),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selectedStorm == hurricane
                                          ? Colors.yellow
                                          : Colors.white,
                                      width: selectedStorm == hurricane ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppTheme.getHurricaneCategoryColor(
                                                    hurricane.category)
                                                .withOpacity(0.4),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          hurricane.name.isNotEmpty
                                              ? hurricane.name[0]
                                              : '?',
                                          style: TextStyle(
                                            color: AppTheme
                                                .getHurricaneCategoryColor(
                                                    hurricane.category),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            shadows: const [
                                              Shadow(
                                                color: Colors.white,
                                                blurRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          hurricane.category > 0
                                              ? 'H${hurricane.category}'
                                              : 'TS',
                                          style: TextStyle(
                                            color: AppTheme
                                                .getHurricaneCategoryColor(
                                                    hurricane.category),
                                            fontSize: 8,
                                            fontWeight: FontWeight.w600,
                                            shadows: const [
                                              Shadow(
                                                color: Colors.white,
                                                blurRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.red,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Controls overlay (toggleable)
          if (showControls) ...[
            // Top gradient and title
            Positioned(
              top: 0, // Start from the very top of the screen
              left: 0,
              right: 0,
              height: MediaQuery.of(context).padding.top +
                  80, // Extend to cover status bar + content
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top +
                        16, // Position content below notch
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.satellite_alt,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Live Hurricane Tracking',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Weather info (top-right)
            if (widget.currentWeather != null)
              Positioned(
                top: MediaQuery.of(context).padding.top +
                    16, // Account for status bar
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cayman Islands',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${widget.currentWeather!.temperature.round()}°C',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        '${widget.currentWeather!.windSpeed.round()} mph',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom +
                  16, // Account for home indicator
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Forecast timeline
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Forecast:',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _selectedTimeIndex.toDouble(),
                            min: 0,
                            max: 48,
                            divisions: 48,
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

                    // Storm quick info
                    if (widget.hurricanes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              showStormInfo = !showStormInfo;
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: AppTheme.getHurricaneCategoryColor(
                                    widget.hurricanes.first.category),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${widget.hurricanes.length} Active Storm${widget.hurricanes.length > 1 ? 's' : ''} • Tap for more info',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              Icon(
                                showStormInfo
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Storm details panel (expandable)
            if (showStormInfo && widget.hurricanes.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom +
                    120, // Account for home indicator
                left: 16,
                right: 16,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Active Storms',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.hurricanes.length,
                          itemBuilder: (context, index) {
                            final storm = widget.hurricanes[index];
                            final center = _getForecastedCenter(
                              storm,
                              _selectedTimeIndex,
                            );
                            return GestureDetector(
                              onTap: () {
                                // Focus camera on this storm
                                _mapController.move(
                                  LatLng(center.latitude, center.longitude),
                                  6.0,
                                );
                                setState(() {
                                  selectedStorm = storm;
                                  showStormInfo = false;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.getHurricaneCategoryColor(
                                          storm.category)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.getHurricaneCategoryColor(
                                        storm.category),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            AppTheme.getHurricaneCategoryColor(
                                                storm.category),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        AppTheme.getHurricaneCategoryText(
                                            storm.category),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            storm.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            'Wind: ${storm.windSpeed.round()} mph • Pressure: ${storm.pressure.round()} hPa',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: AppTheme.getHurricaneCategoryColor(
                                          storm.category),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          // Storm info panel (when storm selected)
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
      final forecasted = _getForecastedCenter(hurricane, timeIndex);
      final center = LatLng(forecasted.latitude, forecasted.longitude);
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
            .withOpacity(0.08 + (timeIndex / 48) * 0.05),
        borderColor: AppTheme.getHurricaneCategoryColor(hurricane.category)
            .withOpacity(0.3),
        borderStrokeWidth: 1.5,
      ));
    }

    return windFields;
  }

  // Generate realistic wind arrows with counterclockwise motion
  List<Marker> _generateRealisticWindArrows(
      List<Hurricane> hurricanes, int timeIndex, double phase) {
    List<Marker> arrows = [];

    for (final hurricane in hurricanes) {
      final centerLatLng = _getForecastedCenter(hurricane, timeIndex);
      final center = LatLng(centerLatLng.latitude, centerLatLng.longitude);
      final baseRadius = hurricane.windSpeed / 8;
      final timeMultiplier = 1.0 + (timeIndex / 48) * 0.5;
      final radius = baseRadius * timeMultiplier;

      // Generate thin streamlines for realistic wind flow
      for (int ring = 1; ring <= 4; ring++) {
        final ringDistance = radius * (ring / 5);
        final numArrowsInRing =
            8 + (ring * 3); // More streamlines for smoother flow

        for (int j = 0; j < numArrowsInRing; j++) {
          final baseAngle = (j / numArrowsInRing) * 2 * math.pi;
          final spiralOffset = (ring - 1) * (math.pi / 8);
          // Animate particle position around center (counterclockwise)
          final angularSpeed = (0.5 + ring * 0.25); // outer rings move faster
          final animatedAngle =
              baseAngle + spiralOffset - phase * 2 * math.pi * angularSpeed;

          final lat = center.latitude + ringDistance * math.cos(animatedAngle);
          final lng = center.longitude + ringDistance * math.sin(animatedAngle);

          // Wind direction: tangential (counterclockwise)
          final windDirection = animatedAngle + (math.pi / 2);

          arrows.add(Marker(
            point: LatLng(lat, lng),
            width: 2,
            height: 8,
            child: AnimatedBuilder(
              animation: widget.windAnimationController,
              builder: (context, child) {
                // Subtle opacity pulsing with distance-based fading
                final baseOpacity =
                    0.6 - (ring - 1) * 0.12; // Fade with distance
                final opacity = baseOpacity *
                    (0.6 +
                        (0.4 *
                            math.sin(widget.windAnimationController.value *
                                    2 *
                                    math.pi +
                                animatedAngle)));

                // Calculate rotation speed based on wind speed
                final windSpeedFactor =
                    (hurricane.windSpeed / 200.0).clamp(0.2, 2.0);
                final rotationOffset = widget.windAnimationController.value *
                    2 *
                    math.pi *
                    windSpeedFactor *
                    0.5; // Clockwise rotation

                // Color intensity based on wind speed and ring position
                final windIntensity =
                    (hurricane.windSpeed * (ring / 4)) / 150.0;
                final streamlineColor =
                    _getWindSpeedColor(hurricane, windIntensity);

                return Transform.rotate(
                  angle: windDirection +
                      rotationOffset, // Wind direction + rotation
                  child: Container(
                    width: 15.0 + (ring * 2.0), // Varying lengths for realism
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: streamlineColor.withOpacity(opacity),
                      borderRadius: BorderRadius.circular(0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 0.5,
                          spreadRadius: 0.1,
                        ),
                      ],
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

  // Calculate streamline color based on wind speed intensity
  Color _getWindSpeedColor(Hurricane hurricane, double windIntensity) {
    final baseColor = AppTheme.getHurricaneCategoryColor(hurricane.category);

    // Create color variations based on wind intensity
    if (windIntensity < 0.3) {
      // Light winds - cooler colors (blue-green)
      return Color.lerp(Colors.cyan.shade300, baseColor, 0.4) ?? baseColor;
    } else if (windIntensity < 0.6) {
      // Moderate winds - warmer colors (yellow-orange)
      return Color.lerp(Colors.orange.shade300, baseColor, 0.6) ?? baseColor;
    } else {
      // Strong winds - hot colors (red-pink)
      return Color.lerp(Colors.red.shade400, baseColor, 0.8) ?? baseColor;
    }
  }

  // Build asymmetric wind fields using NOAA radii if provided; fallback to circle
  List<Polygon> _generateAsymmetricWindFields(
      List<Hurricane> hurricanes, int timeIndex) {
    final polygons = <Polygon>[];

    for (final h in hurricanes) {
      final center = _getForecastedCenter(h, timeIndex);

      if (h.windFields.isNotEmpty) {
        // Interpret each wind field as a radius with slight quadrant weighting
        for (final wf in h.windFields) {
          // Scale with time index
          final scale = 1.0 + (timeIndex / 48) * 0.3;
          final base = wf.radius * 0.01 * scale; // crude degrees approximation

          // Quadrant multipliers to create asymmetry (NE, SE, SW, NW)
          final quads = [1.2, 1.0, 0.9, 1.1];
          final points = <LatLng>[];
          for (int i = 0; i < 72; i++) {
            final ang = (i / 72) * 2 * math.pi;
            final quadIndex = ((ang / (math.pi / 2)) % 4).floor();
            final radiusDeg = base * quads[quadIndex];
            final lat = center.latitude + radiusDeg * math.cos(ang);
            final lng = center.longitude + radiusDeg * math.sin(ang);
            points.add(LatLng(lat, lng));
          }

          polygons.add(
            Polygon(
              points: points,
              color: AppTheme.getHurricaneCategoryColor(h.category)
                  .withOpacity(0.08),
              borderColor: AppTheme.getHurricaneCategoryColor(h.category)
                  .withOpacity(0.3),
              borderStrokeWidth: 1.5,
            ),
          );
        }
      } else {
        // Fallback to symmetric circle using existing method
        polygons.addAll(_generateTimeBasedWindFields([h], timeIndex));
      }
    }

    return polygons;
  }

  // Forecast cone and uncertainty ellipse (very simplified)
  List<Polygon> _generateForecastCones(
      List<Hurricane> hurricanes, int timeIndex) {
    final cones = <Polygon>[];
    for (final h in hurricanes) {
      if (h.forecastTrack.length < 2) continue;
      final start = LatLng(h.latitude, h.longitude);
      final endPoint = LatLng(
        h.forecastTrack.last.latitude,
        h.forecastTrack.last.longitude,
      );

      // Generate a tapered cone: two offset polylines joined
      final points = <LatLng>[];
      final steps = 20;
      for (int i = 0; i <= steps; i++) {
        final t = i / steps;
        final lat = start.latitude + (endPoint.latitude - start.latitude) * t;
        final lng =
            start.longitude + (endPoint.longitude - start.longitude) * t;

        // Width grows with t (uncertainty increases)
        final width = (0.05 + 0.25 * t) * (1 + timeIndex / 96);
        // Perpendicular offsets
        final angle = math.atan2(endPoint.latitude - start.latitude,
            endPoint.longitude - start.longitude);
        final left = LatLng(
          lat + width * math.sin(angle),
          lng - width * math.cos(angle),
        );
        points.add(left);
      }
      for (int i = steps; i >= 0; i--) {
        final t = i / steps;
        final lat = start.latitude + (endPoint.latitude - start.latitude) * t;
        final lng =
            start.longitude + (endPoint.longitude - start.longitude) * t;
        final width = (0.05 + 0.25 * t) * (1 + timeIndex / 96);
        final angle = math.atan2(endPoint.latitude - start.latitude,
            endPoint.longitude - start.longitude);
        final right = LatLng(
          lat - width * math.sin(angle),
          lng + width * math.cos(angle),
        );
        points.add(right);
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

  // Dashed polylines by splitting into short segments
  List<Polyline> _generateDashedPolylines(List<Hurricane> hurricanes) {
    final result = <Polyline>[];
    for (final h in hurricanes) {
      final track = [
        LatLng(h.latitude, h.longitude),
        ...h.forecastTrack.map((p) => LatLng(p.latitude, p.longitude)),
      ];
      if (track.length < 2) continue;

      const dashLen = 0.4; // degrees length per dash (approx)
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

  // Heading arrows positioned along forecast tracks
  List<Marker> _generateHeadingArrows(
      List<Hurricane> hurricanes, int timeIndex) {
    final markers = <Marker>[];
    for (final h in hurricanes) {
      final path = [
        LatLng(h.latitude, h.longitude),
        ...h.forecastTrack.map((p) => LatLng(p.latitude, p.longitude)),
      ];
      if (path.length < 2) continue;

      // Place arrows at every other segment midpoint
      for (int i = 0; i < path.length - 1; i += 2) {
        final a = path[i];
        final b = path[i + 1];
        final mid = LatLng(
            (a.latitude + b.latitude) / 2, (a.longitude + b.longitude) / 2);
        final angle = math.atan2(
            b.latitude - a.latitude, b.longitude - a.longitude); // radians

        markers.add(
          Marker(
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
          ),
        );
      }
    }
    return markers;
  }

  // Interpolate the storm center along its forecast track based on hour offset
  LatLng _getForecastedCenter(Hurricane hurricane, int hourOffset) {
    if (hurricane.forecastTrack.isEmpty || hourOffset <= 0) {
      return LatLng(hurricane.latitude, hurricane.longitude);
    }

    final targetTime = hurricane.timestamp.add(Duration(hours: hourOffset));

    // Find bounding points
    ForecastPoint? prev;
    ForecastPoint? next;

    for (final point in hurricane.forecastTrack) {
      if (point.timestamp.isBefore(targetTime) ||
          point.timestamp.isAtSameMomentAs(targetTime)) {
        prev = point;
      }
      if (point.timestamp.isAfter(targetTime)) {
        next = point;
        break;
      }
    }

    // If before first or after last, clamp
    prev ??= hurricane.forecastTrack.first;
    next ??= hurricane.forecastTrack.last;

    if (prev.timestamp == next.timestamp) {
      return LatLng(prev.latitude, prev.longitude);
    }

    final total =
        next.timestamp.difference(prev.timestamp).inSeconds.toDouble();
    final done = targetTime
        .difference(prev.timestamp)
        .inSeconds
        .toDouble()
        .clamp(0.0, total);
    final t = (total == 0) ? 0.0 : (done / total);

    final lat = prev.latitude + (next.latitude - prev.latitude) * t;
    final lng = prev.longitude + (next.longitude - prev.longitude) * t;
    return LatLng(lat, lng);
  }

  // (intentionally left unused after refactor)
}
