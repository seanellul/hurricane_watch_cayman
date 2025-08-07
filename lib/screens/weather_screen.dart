import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hurricane_watch/providers/weather_provider.dart';
import 'package:hurricane_watch/models/weather.dart';
import 'package:hurricane_watch/models/hurricane.dart';
import 'package:hurricane_watch/utils/theme.dart';
import 'package:hurricane_watch/widgets/enhanced_fullscreen_map.dart';
import 'package:hurricane_watch/widgets/core_live_map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  late AnimationController _windAnimationController;
  late AnimationController _cycloneAnimationController;

  @override
  void initState() {
    super.initState();
    _windAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _cycloneAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = context.read<WeatherProvider>();
      weatherProvider.loadWeatherData();
      weatherProvider.loadHurricaneData();
    });
  }

  @override
  void dispose() {
    _windAnimationController.dispose();
    _cycloneAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (weatherProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading weather data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weatherProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      weatherProvider.refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await weatherProvider.refresh();
            },
            child: weatherProvider.activeHurricanes.isNotEmpty
                ? CoreLiveMap(
                    hurricanes: weatherProvider.activeHurricanes,
                    windAnimationController: _windAnimationController,
                    cycloneAnimationController: _cycloneAnimationController,
                    currentWeather: weatherProvider.currentWeather,
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No active hurricanes',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class WindfinderMapCard extends StatelessWidget {
  final List<Hurricane> hurricanes;
  final AnimationController windAnimationController;
  final AnimationController cycloneAnimationController;
  final int selectedTimeIndex;
  final ValueChanged<int> onTimeChanged;
  final VoidCallback onMapTap;
  final WeatherData? currentWeather;

  const WindfinderMapCard({
    super.key,
    required this.hurricanes,
    required this.windAnimationController,
    required this.cycloneAnimationController,
    required this.selectedTimeIndex,
    required this.onTimeChanged,
    required this.onMapTap,
    this.currentWeather,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Live Map',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Icon(
                      Icons.air,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Forecast Time: ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Expanded(
                      child: Slider(
                        value: selectedTimeIndex.toDouble(),
                        min: 0,
                        max: 48,
                        divisions: 48,
                        label: '${selectedTimeIndex}h',
                        onChanged: (value) {
                          onTimeChanged(value.round());
                        },
                      ),
                    ),
                    Text(
                      '${selectedTimeIndex}h',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onMapTap,
            child: SizedBox(
              height: 400,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter:
                      const LatLng(19.3133, -81.2546), // Cayman Islands
                  initialZoom: 5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.hurricane_watch',
                  ),
                  // Wind field visualization
                  PolygonLayer(
                    polygons: _generateWindFields(hurricanes),
                  ),
                  // Animated wind arrows
                  MarkerLayer(
                    markers: _generateWindArrows(hurricanes),
                  ),
                  // Hurricane markers with cyclone animation
                  MarkerLayer(
                    markers: hurricanes.map((hurricane) {
                      return Marker(
                        point: LatLng(hurricane.latitude, hurricane.longitude),
                        width: 60,
                        height: 60,
                        child: AnimatedBuilder(
                          animation: cycloneAnimationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: cycloneAnimationController.value *
                                  2 *
                                  math.pi,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.getHurricaneCategoryColor(
                                          hurricane.category)
                                      .withOpacity(0.8 +
                                          (0.2 *
                                              cycloneAnimationController
                                                  .value)),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.getHurricaneCategoryColor(
                                              hurricane.category)
                                          .withOpacity(0.3 +
                                              (0.2 *
                                                  cycloneAnimationController
                                                      .value)),
                                      blurRadius: 10 +
                                          (5 *
                                              cycloneAnimationController.value),
                                      spreadRadius: 2 +
                                          (3 *
                                              cycloneAnimationController.value),
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
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Cat ${hurricane.category}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  // Cayman Islands marker
                  MarkerLayer(
                    markers: [
                      const Marker(
                        point: LatLng(19.3133, -81.2546),
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Polygon> _generateWindFields(List<Hurricane> hurricanes) {
    List<Polygon> windFields = [];

    for (final hurricane in hurricanes) {
      // Create wind field polygons around each hurricane
      final center = LatLng(hurricane.latitude, hurricane.longitude);
      final radius =
          hurricane.windSpeed / 10; // Scale radius based on wind speed

      // Generate circular wind field
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
            .withOpacity(0.2),
        borderColor: AppTheme.getHurricaneCategoryColor(hurricane.category),
        borderStrokeWidth: 2,
      ));
    }

    return windFields;
  }

  List<Marker> _generateWindArrows(List<Hurricane> hurricanes) {
    List<Marker> arrows = [];

    for (final hurricane in hurricanes) {
      final center = LatLng(hurricane.latitude, hurricane.longitude);
      final radius = hurricane.windSpeed / 8;

      // Generate wind arrows in a spiral pattern with different speeds
      for (int i = 0; i < 16; i++) {
        final angle = i * 22.5 * math.pi / 180; // 22.5 degrees apart
        final distance = radius * (0.2 + 0.8 * (i / 16));
        final lat = center.latitude + distance * math.cos(angle);
        final lng = center.longitude + distance * math.sin(angle);

        // Different animation speeds based on distance from center
        final animationSpeed = 1.0 + (i / 16) * 2.0; // Faster further out

        arrows.add(Marker(
          point: LatLng(lat, lng),
          width: 24,
          height: 24,
          child: AnimatedBuilder(
            animation: windAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: angle +
                    (windAnimationController.value *
                        2 *
                        math.pi *
                        animationSpeed),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        AppTheme.getHurricaneCategoryColor(hurricane.category)
                            .withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              );
            },
          ),
        ));
      }
    }

    return arrows;
  }
}

class LiveMapFullScreen extends StatefulWidget {
  final List<Hurricane> hurricanes;
  final AnimationController windAnimationController;
  final AnimationController cycloneAnimationController;
  final int selectedTimeIndex;
  final WeatherData? currentWeather;

  const LiveMapFullScreen({
    super.key,
    required this.hurricanes,
    required this.windAnimationController,
    required this.cycloneAnimationController,
    required this.selectedTimeIndex,
    this.currentWeather,
  });

  @override
  State<LiveMapFullScreen> createState() => _LiveMapFullScreenState();
}

class _LiveMapFullScreenState extends State<LiveMapFullScreen> {
  int _selectedTimeIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedTimeIndex = widget.selectedTimeIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Map'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
            options: MapOptions(
              initialCenter: const LatLng(19.3133, -81.2546), // Cayman Islands
              initialZoom: 4,
              maxZoom: 10,
              minZoom: 2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hurricane_watch',
              ),
              // Wind field visualization
              PolygonLayer(
                polygons: _generateWindFields(widget.hurricanes),
              ),
              // Animated wind arrows
              MarkerLayer(
                markers: _generateWindArrows(widget.hurricanes),
              ),
              // Hurricane markers with cyclone animation
              MarkerLayer(
                markers: widget.hurricanes.map((hurricane) {
                  return Marker(
                    point: LatLng(hurricane.latitude, hurricane.longitude),
                    width: 80,
                    height: 80,
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
                              color: AppTheme.getHurricaneCategoryColor(
                                      hurricane.category)
                                  .withOpacity(0.8 +
                                      (0.2 *
                                          widget.cycloneAnimationController
                                              .value)),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.getHurricaneCategoryColor(
                                          hurricane.category)
                                      .withOpacity(0.3 +
                                          (0.2 *
                                              widget.cycloneAnimationController
                                                  .value)),
                                  blurRadius: 15 +
                                      (8 *
                                          widget.cycloneAnimationController
                                              .value),
                                  spreadRadius: 3 +
                                      (4 *
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
                                    ),
                                  ),
                                  Text(
                                    'Cat ${hurricane.category}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
              // Cayman Islands marker
              MarkerLayer(
                markers: [
                  const Marker(
                    point: LatLng(19.3133, -81.2546),
                    width: 40,
                    height: 40,
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Forecast time slider at top
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
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
                        ),
                      ),
                      Text(
                        '${_selectedTimeIndex}h',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Floating storm details at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Active Storms',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...widget.hurricanes.map(
                      (hurricane) => _StormDetailItem(hurricane: hurricane)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Polygon> _generateWindFields(List<Hurricane> hurricanes) {
    List<Polygon> windFields = [];

    for (final hurricane in hurricanes) {
      final center = LatLng(hurricane.latitude, hurricane.longitude);
      final radius = hurricane.windSpeed / 10;

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
            .withOpacity(0.2),
        borderColor: AppTheme.getHurricaneCategoryColor(hurricane.category),
        borderStrokeWidth: 2,
      ));
    }

    return windFields;
  }

  List<Marker> _generateWindArrows(List<Hurricane> hurricanes) {
    List<Marker> arrows = [];

    for (final hurricane in hurricanes) {
      final center = LatLng(hurricane.latitude, hurricane.longitude);
      final radius = hurricane.windSpeed / 8;

      for (int i = 0; i < 16; i++) {
        final angle = i * 22.5 * math.pi / 180;
        final distance = radius * (0.2 + 0.8 * (i / 16));
        final lat = center.latitude + distance * math.cos(angle);
        final lng = center.longitude + distance * math.sin(angle);
        final animationSpeed = 1.0 + (i / 16) * 2.0;

        arrows.add(Marker(
          point: LatLng(lat, lng),
          width: 24,
          height: 24,
          child: AnimatedBuilder(
            animation: widget.windAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: angle +
                    (widget.windAnimationController.value *
                        2 *
                        math.pi *
                        animationSpeed),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        AppTheme.getHurricaneCategoryColor(hurricane.category)
                            .withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              );
            },
          ),
        ));
      }
    }

    return arrows;
  }
}

class _StormDetailItem extends StatelessWidget {
  final Hurricane hurricane;

  const _StormDetailItem({required this.hurricane});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getHurricaneCategoryColor(hurricane.category)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.getHurricaneCategoryColor(hurricane.category),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.getHurricaneCategoryColor(hurricane.category),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppTheme.getHurricaneCategoryText(hurricane.category),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hurricane.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Wind: ${hurricane.windSpeed.round()} mph • Pressure: ${hurricane.pressure.round()} hPa',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HurricaneListCard extends StatelessWidget {
  final List<Hurricane> hurricanes;

  const HurricaneListCard({
    super.key,
    required this.hurricanes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storm Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...hurricanes
                .map((hurricane) => _HurricaneItem(hurricane: hurricane)),
          ],
        ),
      ),
    );
  }
}

class _HurricaneItem extends StatelessWidget {
  final Hurricane hurricane;

  const _HurricaneItem({
    required this.hurricane,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Access the parent widget's animation controllers through context
        final weatherScreen =
            context.findAncestorStateOfType<_WeatherScreenState>();
        if (weatherScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnhancedFullScreenMap(
                hurricanes: [hurricane],
                windAnimationController: weatherScreen._windAnimationController,
                cycloneAnimationController:
                    weatherScreen._cycloneAnimationController,
                selectedTimeIndex: 0,
                focusedStorm: hurricane,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.getHurricaneCategoryColor(hurricane.category)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.getHurricaneCategoryColor(hurricane.category),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.getHurricaneCategoryColor(hurricane.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    AppTheme.getHurricaneCategoryText(hurricane.category),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hurricane.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Wind: ${hurricane.windSpeed.round()} mph',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Pressure: ${hurricane.pressure.round()} hPa',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Location: ${hurricane.latitude.toStringAsFixed(2)}°, ${hurricane.longitude.toStringAsFixed(2)}°',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.getHurricaneCategoryColor(hurricane.category),
                ),
                Text(
                  'Tap to view on map',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.getHurricaneCategoryColor(
                            hurricane.category),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
