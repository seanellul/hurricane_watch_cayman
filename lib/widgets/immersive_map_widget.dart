import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'package:hurricane_watch/utils/cayman_map_cache.dart';

import '../models/hurricane.dart';
import '../models/weather.dart';
import '../utils/theme.dart';
import 'storm_info_panel.dart';

class ImmersiveLiveMapCard extends StatefulWidget {
  final List<Hurricane> hurricanes;
  final AnimationController windAnimationController;
  final AnimationController cycloneAnimationController;
  final int selectedTimeIndex;
  final ValueChanged<int> onTimeChanged;
  final VoidCallback onFullScreenTap;
  final WeatherData? currentWeather;

  const ImmersiveLiveMapCard({
    super.key,
    required this.hurricanes,
    required this.windAnimationController,
    required this.cycloneAnimationController,
    required this.selectedTimeIndex,
    required this.onTimeChanged,
    required this.onFullScreenTap,
    this.currentWeather,
  });

  @override
  State<ImmersiveLiveMapCard> createState() => _ImmersiveLiveMapCardState();
}

class _ImmersiveLiveMapCardState extends State<ImmersiveLiveMapCard> {
  Hurricane? selectedStorm;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Full-background map
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(19.3133, -81.2546),
                initialZoom: 4.5,
                maxZoom: 8,
                minZoom: 3,
                onTap: (tapPosition, point) => widget.onFullScreenTap(),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  tileProvider: CaymanCachingTileProvider(headers: {
                    'User-Agent': 'CaymanHurricaneWatch/1.0',
                  }),
                ),
                // Dynamic wind fields + cones
                PolygonLayer(
                  polygons: [
                    ..._generateAsymmetricWindFields(
                      widget.hurricanes,
                      widget.selectedTimeIndex,
                    ),
                    ..._generateForecastCones(
                      widget.hurricanes,
                      widget.selectedTimeIndex,
                    ),
                  ],
                ),
                // Animated wind streamlines orbiting storm center
                AnimatedBuilder(
                  animation: widget.windAnimationController,
                  builder: (context, _) {
                    return MarkerLayer(
                      markers: _generateRealisticWindArrows(
                        widget.hurricanes,
                        widget.selectedTimeIndex,
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
                    widget.hurricanes,
                    widget.selectedTimeIndex,
                  ),
                ),
                // Hurricane eye markers with correct rotation
                MarkerLayer(
                  markers: widget.hurricanes.map((hurricane) {
                    final center = _getForecastedCenter(
                      hurricane,
                      widget.selectedTimeIndex,
                    );
                    return Marker(
                      point: LatLng(center.latitude, center.longitude),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedStorm = hurricane;
                          });
                        },
                        child: AnimatedBuilder(
                          animation: widget.cycloneAnimationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              // Counterclockwise rotation for Northern Hemisphere
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
                                  border:
                                      Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.getHurricaneCategoryColor(
                                              hurricane.category)
                                          .withOpacity(0.4 +
                                              (0.3 *
                                                  widget
                                                      .cycloneAnimationController
                                                      .value)),
                                      blurRadius: 20 +
                                          (10 *
                                              widget.cycloneAnimationController
                                                  .value),
                                      spreadRadius: 5 +
                                          (5 *
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
                                          fontSize: 20,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        'Cat ${hurricane.category}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 1,
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
                // Cayman Islands marker with enhanced design
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

            // Title and fullscreen button
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
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
                          'Live Map',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onFullScreenTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Current weather overlay (top-right)
            if (widget.currentWeather != null)
              Positioned(
                top: 70,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                      const SizedBox(height: 4),
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

            // Bottom gradient and controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Forecast timeline
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Forecast:',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Expanded(
                              child: Slider(
                                value: widget.selectedTimeIndex.toDouble(),
                                min: 0,
                                max: 48,
                                divisions: 48,
                                onChanged: (value) =>
                                    widget.onTimeChanged(value.round()),
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
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
                                '+${widget.selectedTimeIndex}h',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Storm summary
                      if (widget.hurricanes.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: AppTheme.getHurricaneCategoryColor(
                                    widget.hurricanes.first.category),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${widget.hurricanes.length} Active Storm${widget.hurricanes.length > 1 ? 's' : ''} Tracked',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              Text(
                                'Tap for details',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
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

            // Storm info panel (shown when storm is selected)
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
      ),
    );
  }

  // Generate wind fields that change based on forecast time
  // Generate realistic wind arrows orbiting the storm
  List<Marker> _generateRealisticWindArrows(
      List<Hurricane> hurricanes, int timeIndex, double phase) {
    List<Marker> arrows = [];

    for (final hurricane in hurricanes) {
      final c = _getForecastedCenter(hurricane, timeIndex);
      final center = LatLng(c.latitude, c.longitude);
      final radius = hurricane.windSpeed / 8 * (1.0 + (timeIndex / 48) * 0.5);

      // Generate wind arrows in concentric rings (much fewer, cleaner pattern)
      for (int ring = 1; ring <= 4; ring++) {
        final ringDistance = radius * (ring / 4);
        final numArrowsInRing = 6 + (ring * 2); // 8, 10, 12, 14 arrows per ring

        for (int j = 0; j < numArrowsInRing; j++) {
          final baseAngle = (j / numArrowsInRing) * 2 * math.pi;

          // Add spiral offset based on ring (creates spiral effect)
          final spiralOffset = (ring - 1) * (math.pi / 6);
          final angle = baseAngle +
              spiralOffset -
              phase * 2 * math.pi * (0.5 + ring * 0.25);

          final lat = center.latitude + ringDistance * math.cos(angle);
          final lng = center.longitude + ringDistance * math.sin(angle);

          // Wind direction: tangential to the spiral (counterclockwise)
          final windDirection = angle + (math.pi / 2); // 90 degrees to radius
          final animationSpeed =
              0.3 + (ring / 4) * 0.7; // Faster in outer rings

          arrows.add(Marker(
            point: LatLng(lat, lng),
            width: 16,
            height: 16,
            child: AnimatedBuilder(
              animation: widget.windAnimationController,
              builder: (context, child) {
                return Transform.rotate(
                  // Counterclockwise rotation with realistic wind direction
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

  // Asymmetric wind fields or fallback
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
          final pts = <LatLng>[];
          for (int i = 0; i < 72; i++) {
            final ang = (i / 72) * 2 * math.pi;
            final q = ((ang / (math.pi / 2)) % 4).floor();
            final r = base * quads[q];
            pts.add(LatLng(
              center.latitude + r * math.cos(ang),
              center.longitude + r * math.sin(ang),
            ));
          }
          polygons.add(Polygon(
            points: pts,
            color:
                AppTheme.getHurricaneCategoryColor(h.category).withOpacity(0.1),
            borderColor: AppTheme.getHurricaneCategoryColor(h.category)
                .withOpacity(0.35),
            borderStrokeWidth: 1.5,
          ));
        }
      } else {
        // Simple circle fallback
        final baseRadius = h.windSpeed / 10;
        final timeMultiplier = 1.0 + (timeIndex / 48) * 0.5;
        final radius = baseRadius * timeMultiplier;
        final pts = <LatLng>[];
        for (int i = 0; i < 36; i++) {
          final ang = i * 10 * math.pi / 180;
          pts.add(LatLng(
            center.latitude + radius * math.cos(ang),
            center.longitude + radius * math.sin(ang),
          ));
        }
        polygons.add(Polygon(
          points: pts,
          color:
              AppTheme.getHurricaneCategoryColor(h.category).withOpacity(0.1),
          borderColor:
              AppTheme.getHurricaneCategoryColor(h.category).withOpacity(0.35),
          borderStrokeWidth: 1.5,
        ));
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
      final end =
          LatLng(h.forecastTrack.last.latitude, h.forecastTrack.last.longitude);
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
      cones.add(Polygon(
        points: points,
        color: Colors.orange.withOpacity(0.08),
        borderColor: Colors.orange.withOpacity(0.25),
        borderStrokeWidth: 1.0,
      ));
    }
    return cones;
  }

  // Dashed polylines
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
            result.add(Polyline(
              points: [
                LatLng(a.latitude + dy * t1, a.longitude + dx * t1),
                LatLng(a.latitude + dy * t2, a.longitude + dx * t2),
              ],
              color: AppTheme.getHurricaneCategoryColor(h.category)
                  .withOpacity(0.8),
              strokeWidth: 2,
            ));
          }
          draw = !draw;
        }
      }
    }
    return result;
  }

  // Heading arrows along path
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

  // Interpolate forecasted position
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
    return LatLng(
      prev.latitude + (next.latitude - prev.latitude) * t,
      prev.longitude + (next.longitude - prev.longitude) * t,
    );
  }
}
