import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/hurricane.dart';
import '../utils/theme.dart';

class StormInfoPanel extends StatelessWidget {
  final Hurricane hurricane;
  final VoidCallback onClose;

  const StormInfoPanel({
    super.key,
    required this.hurricane,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final distanceToCayman = _calculateDistanceToCayman();
    final threatLevel = _calculateThreatLevel(distanceToCayman);
    final movementInfo = _calculateMovementInfo();
    final estimatedArrival = _calculateEstimatedArrival(
        distanceToCayman, movementInfo['speed'] as double);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        AppTheme.getHurricaneCategoryColor(hurricane.category),
                    borderRadius: BorderRadius.circular(20),
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
                  child: Text(
                    hurricane.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Storm details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Current conditions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Conditions',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _StormStat(
                              icon: Icons.air,
                              label: 'Wind Speed',
                              value: '${hurricane.windSpeed.round()} mph',
                            ),
                          ),
                          Expanded(
                            child: _StormStat(
                              icon: Icons.compress,
                              label: 'Pressure',
                              value: '${hurricane.pressure.round()} hPa',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _StormStat(
                              icon: Icons.speed,
                              label: 'Movement',
                              value:
                                  '${(movementInfo['speed'] as double).round()} mph',
                            ),
                          ),
                          Expanded(
                            child: _StormStat(
                              icon: Icons.navigation,
                              label: 'Direction',
                              value: _getCompassDirection(
                                  movementInfo['direction'] as double),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Cayman Islands impact
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getThreatColor(threatLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getThreatColor(threatLevel),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getThreatIcon(threatLevel),
                            color: _getThreatColor(threatLevel),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Cayman Islands Impact',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getThreatColor(threatLevel),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Distance: ${distanceToCayman.round()} km',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Threat Level: ${_getThreatLevelText(threatLevel)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _getThreatColor(threatLevel),
                            ),
                      ),
                      if (estimatedArrival != null)
                        Text(
                          'Est. Arrival: $estimatedArrival',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Add to watch list functionality
                        },
                        icon: const Icon(Icons.newspaper, color: Colors.white),
                        label: Text('${hurricane.name} News',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Share storm info functionality
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateMovementInfo() {
    // Calculate movement based on forecast track if available
    if (hurricane.forecastTrack.isNotEmpty) {
      final currentPos = hurricane.forecastTrack.first;
      final futurePos = hurricane.forecastTrack.length > 1
          ? hurricane.forecastTrack[1]
          : hurricane.forecastTrack.first;

      final distance = _calculateDistance(
        currentPos.latitude,
        currentPos.longitude,
        futurePos.latitude,
        futurePos.longitude,
      );

      final timeDiff =
          futurePos.timestamp.difference(currentPos.timestamp).inHours;
      final speed = timeDiff > 0 ? distance / timeDiff : 0.0;

      // Calculate bearing
      final bearing = _calculateBearing(
        currentPos.latitude,
        currentPos.longitude,
        futurePos.latitude,
        futurePos.longitude,
      );

      return {'speed': speed, 'direction': bearing};
    }

    // Default values if no forecast track
    return {'speed': 15.0, 'direction': 45.0}; // Typical values
  }

  double _calculateDistanceToCayman() {
    // Cayman Islands center coordinates
    return _calculateDistance(
        19.3133, -81.2546, hurricane.latitude, hurricane.longitude);
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final double dLat = (lat2 - lat1) * (math.pi / 180);
    final double dLon = (lon2 - lon1) * (math.pi / 180);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180)) *
            math.cos(lat2 * (math.pi / 180)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final double dLon = (lon2 - lon1) * (math.pi / 180);
    final double lat1Rad = lat1 * (math.pi / 180);
    final double lat2Rad = lat2 * (math.pi / 180);

    final double y = math.sin(dLon) * math.cos(lat2Rad);
    final double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    final double bearing = math.atan2(y, x) * (180 / math.pi);
    return (bearing + 360) % 360; // Normalize to 0-360
  }

  int _calculateThreatLevel(double distance) {
    if (distance < 100) return 4; // Extreme
    if (distance < 200) return 3; // High
    if (distance < 400) return 2; // Moderate
    if (distance < 600) return 1; // Low
    return 0; // Minimal
  }

  String? _calculateEstimatedArrival(double distance, double movementSpeed) {
    if (movementSpeed <= 0) return null;
    final hours = distance / (movementSpeed * 1.60934); // Convert mph to km/h
    if (hours > 72) return null; // Don't show if more than 3 days

    if (hours < 24) {
      return '${hours.round()} hours';
    } else {
      final days = (hours / 24).round();
      return '$days day${days > 1 ? 's' : ''}';
    }
  }

  String _getCompassDirection(double degrees) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW'
    ];
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  String _getThreatLevelText(int level) {
    switch (level) {
      case 4:
        return 'Extreme';
      case 3:
        return 'High';
      case 2:
        return 'Moderate';
      case 1:
        return 'Low';
      default:
        return 'Minimal';
    }
  }

  Color _getThreatColor(int level) {
    switch (level) {
      case 4:
        return Colors.red[700]!;
      case 3:
        return Colors.orange[700]!;
      case 2:
        return Colors.yellow[700]!;
      case 1:
        return Colors.blue[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getThreatIcon(int level) {
    switch (level) {
      case 4:
        return Icons.warning;
      case 3:
        return Icons.error_outline;
      case 2:
        return Icons.info_outline;
      case 1:
        return Icons.check_circle_outline;
      default:
        return Icons.remove_circle_outline;
    }
  }
}

class _StormStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StormStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
