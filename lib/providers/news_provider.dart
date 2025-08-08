import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hurricane_watch/models/news.dart';
import 'package:hurricane_watch/services/news_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();

  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  static const _cacheKey = 'news_cache_v1';
  static const _cacheTimestampKey = 'news_cache_ts_v1';
  static const _cacheTtl = Duration(minutes: 10);
  static const _imgCacheKey = 'news_img_cache_v1';
  static const _imgCacheTsKey = 'news_img_cache_ts_v1';
  static const _imgCacheTtl = Duration(hours: 8);

  Map<String, String> _imageUrlCache = {};

  Future<void> loadFromCacheIfFresh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getInt(_cacheTimestampKey);
      if (ts == null) return;
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts, isUtc: true);
      if (DateTime.now().toUtc().difference(cachedAt) > _cacheTtl) return;
      final data = prefs.getString(_cacheKey);
      if (data == null) return;
      final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
      _articles = jsonList
          .map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
          .toList();
      _articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      _lastUpdated = cachedAt;
      // Load image URL cache if fresh
      final imgTs = prefs.getInt(_imgCacheTsKey);
      if (imgTs != null) {
        final imgCachedAt =
            DateTime.fromMillisecondsSinceEpoch(imgTs, isUtc: true);
        if (DateTime.now().toUtc().difference(imgCachedAt) <= _imgCacheTtl) {
          final imgData = prefs.getString(_imgCacheKey);
          if (imgData != null) {
            final Map<String, dynamic> m = json.decode(imgData);
            _imageUrlCache = m.map((k, v) => MapEntry(k, v as String));
          }
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _articles.map((e) => e.toJson()).toList();
      await prefs.setString(_cacheKey, json.encode(jsonList));
      await prefs.setInt(
          _cacheTimestampKey, DateTime.now().toUtc().millisecondsSinceEpoch);
      // Persist image URL cache
      await prefs.setString(_imgCacheKey, json.encode(_imageUrlCache));
      await prefs.setInt(
          _imgCacheTsKey, DateTime.now().toUtc().millisecondsSinceEpoch);
    } catch (_) {}
  }

  Future<void> loadNews() async {
    _setLoading(true);
    _clearError();

    try {
      final articles = await _newsService.getHurricaneNews();
      _articles = articles;
      notifyListeners();
    } catch (e) {
      // If RSS feeds fail, fall back to mock data
      try {
        final mockArticles = await _newsService.getMockNews();
        _articles = mockArticles;
        notifyListeners();
      } catch (mockError) {
        _setError('Failed to load news: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNewsProgressively() async {
    _setLoading(true);
    _clearError();
    if (_articles.isEmpty) {
      await loadFromCacheIfFresh();
    } else {
      notifyListeners();
    }

    try {
      // Start all RSS feed fetches concurrently
      final newsService = NewsService();
      final sources = newsService.getSources();

      // Create a list to track completed feeds
      final List<Future<void>> feedFutures = [];

      for (final source in sources) {
        feedFutures.add(_fetchAndMergeFromSource(newsService, source));
      }

      // Wait for all feeds to complete
      await Future.wait(feedFutures, eagerError: false);

      // If no articles were loaded (fresh startup), fall back to mock data
      if (_articles.isEmpty) {
        final mockArticles = await newsService.getMockNews();
        _articles = _dedupeAndMerge(_articles, mockArticles);
        notifyListeners();
      }
      _lastUpdated = DateTime.now().toUtc();
      await _saveCache();
    } catch (e) {
      _setError('Failed to load news: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchAndMergeFromSource(NewsService newsService, source) async {
    try {
      final articles = await newsService.fetchRssFeedForSource(source);
      if (articles.isNotEmpty) {
        _articles = _dedupeAndMerge(_articles, articles);
        // Opportunistically backfill missing images for top items
        // Backfill missing images for top items (non-blocking per item)
        final int limit = _articles.length < 12 ? _articles.length : 12;
        final List<Future<void>> backfills = [];
        for (int i = 0; i < limit; i++) {
          final a = _articles[i];
          if (a.imageUrl == null) {
            backfills.add(_backfillImage(newsService, i, a));
          }
        }
        // Fire and wait in background but don't block UI updates
        unawaited(Future.wait(backfills));
        _articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching from ${source.name}: $e');
      // Continue with other sources
    }
  }

  Future<void> _backfillImage(
      NewsService newsService, int index, NewsArticle a) async {
    try {
      // Check cache first
      final cached = _imageUrlCache[NewsService.canonicalizeUrl(a.link)];
      String? img = cached;
      img ??= await newsService.fetchOpenGraphImage(a.link);
      if (img != null) {
        _imageUrlCache[NewsService.canonicalizeUrl(a.link)] = img;
        _articles[index] = NewsArticle(
          title: a.title,
          description: a.description,
          link: a.link,
          imageUrl: img,
          publishedAt: a.publishedAt,
          source: a.source,
          category: a.category,
          isHurricaneRelated: a.isHurricaneRelated,
        );
        notifyListeners();
        await _saveCache();
      }
    } catch (_) {}
  }

  List<NewsArticle> _dedupeAndMerge(
      List<NewsArticle> current, List<NewsArticle> incoming) {
    final Map<String, NewsArticle> byKey = {
      for (final a in current) NewsService.canonicalizeUrl(a.link): a,
    };
    for (final a in incoming) {
      final key = NewsService.canonicalizeUrl(a.link);
      final existing = byKey[key];
      if (existing == null || a.publishedAt.isAfter(existing.publishedAt)) {
        byKey[key] = a;
      }
    }
    return byKey.values.toList();
  }

  List<NewsArticle> getArticlesBySource(String source) {
    return _articles.where((article) => article.source == source).toList();
  }

  List<NewsArticle> getArticlesByCategory(String category) {
    return _articles.where((article) => article.category == category).toList();
  }

  List<NewsArticle> searchArticles(String query) {
    if (query.isEmpty) return _articles;

    return _articles
        .where((article) =>
            article.title.toLowerCase().contains(query.toLowerCase()) ||
            article.description.toLowerCase().contains(query.toLowerCase()) ||
            article.source.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Strict filter for hurricane-only mode
  List<NewsArticle> getStrictHurricaneArticles() {
    return _articles
        .where((a) => NewsService.isStrictArticle(a))
        .toList(growable: false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    loadNewsProgressively();
  }
}
