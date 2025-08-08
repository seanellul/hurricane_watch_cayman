import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';

/// TileProvider that persists map tiles to disk using flutter_cache_manager.
/// Works with flutter_map v7 by returning a CachedNetworkImageProvider per tile.
class CaymanCachingTileProvider extends TileProvider {
  CaymanCachingTileProvider({
    Map<String, String>? headers,
    BaseCacheManager? cacheManager,
  })  : _cacheManager = cacheManager ?? DefaultCacheManager(),
        super(
          headers: headers != null
              ? Map<String, String>.from(headers)
              : <String, String>{'User-Agent': 'CaymanHurricaneWatch/1.0'},
        );

  final BaseCacheManager _cacheManager;

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return CachedNetworkImageProvider(
      url,
      headers: headers,
      cacheManager: _cacheManager,
      cacheKey: url,
    );
  }
}

/// Lightweight prefetch for Cayman area to improve first-show latency.
/// This is intentionally conservative to respect tile server ToS.
class CaymanTilePrefetch {
  static bool _started = false;

  // Cayman bounding box (approx): Grand Cayman and surrounds
  static const double _minLat = 18.9;
  static const double _maxLat = 19.8;
  static const double _minLon = -81.9;
  static const double _maxLon = -80.6;

  static const String _tileBase = 'https://tile.openstreetmap.org';
  static const Map<String, String> _headers = {
    'User-Agent': 'CaymanHurricaneWatch/1.0'
  };

  /// Prefetch a tiny set of tiles once per session.
  /// Does nothing if already started.
  static Future<void> prefetchOnce() async {
    if (_started) return;
    _started = true;

    // Run detached to never block UI startup
    // Do not exceed small number of tiles to stay respectful
    // z-levels chosen for regional overview when opening the app
    unawaited(_prefetchTiles(minZoom: 5, maxZoom: 8, maxTiles: 220));
  }

  /// Public helper to prefetch with custom intensity (still Cayman bounds only).
  static Future<void> prefetchQuickRegion({
    int minZoom = 5,
    int maxZoom = 9,
    int maxTiles = 400,
  }) async {
    await _prefetchTiles(
        minZoom: minZoom, maxZoom: maxZoom, maxTiles: maxTiles);
  }

  static Future<void> _prefetchTiles({
    required int minZoom,
    required int maxZoom,
    required int maxTiles,
  }) async {
    try {
      final manager = DefaultCacheManager();
      int scheduled = 0;

      for (int z = minZoom; z <= maxZoom; z++) {
        final xMin = _lon2tile(_minLon, z);
        final xMax = _lon2tile(_maxLon, z);
        final yMin = _lat2tile(_maxLat, z);
        final yMax = _lat2tile(_minLat, z);

        // Throttle concurrency
        const int batchSize = 8;
        final List<Future<void>> batch = [];

        for (int x = xMin; x <= xMax; x++) {
          for (int y = yMin; y <= yMax; y++) {
            if (scheduled >= maxTiles) break;
            final url = '$_tileBase/$z/$x/$y.png';
            scheduled++;
            batch.add(
              manager
                  .getSingleFile(url, headers: _headers)
                  .then((_) {}, onError: (_) {}),
            );

            if (batch.length >= batchSize) {
              await Future.wait(batch, eagerError: false);
              batch.clear();
            }
          }
          if (scheduled >= maxTiles) break;
        }
        if (batch.isNotEmpty) {
          await Future.wait(batch, eagerError: false);
        }

        if (scheduled >= maxTiles) break;
      }
    } catch (_) {
      // Silent failure; prefetch is a best-effort optimization
    }
  }

  static int _lon2tile(double lon, int zoom) {
    return ((lon + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  static int _lat2tile(double lat, int zoom) {
    final rad = lat * math.pi / 180.0;
    final n = math.log(math.tan(rad) + 1 / math.cos(rad));
    return ((1.0 - n / math.pi) / 2.0 * (1 << zoom)).floor();
  }
}
