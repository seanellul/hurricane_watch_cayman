import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hurricane_watch/models/news.dart';
import 'package:hurricane_watch/services/news_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();

  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
    _articles = []; // Clear existing articles
    notifyListeners();

    try {
      // Start all RSS feed fetches concurrently
      final newsService = NewsService();
      final sources = newsService.getSources();

      // Create a list to track completed feeds
      final List<Future<void>> feedFutures = [];

      for (final source in sources) {
        final future = _fetchAndUpdateFromSource(newsService, source);
        feedFutures.add(future);
      }

      // Wait for all feeds to complete
      await Future.wait(feedFutures, eagerError: false);

      // If no articles were loaded, fall back to mock data
      if (_articles.isEmpty) {
        final mockArticles = await newsService.getMockNews();
        _articles = mockArticles;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to load news: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchAndUpdateFromSource(
      NewsService newsService, source) async {
    try {
      final articles = await newsService.fetchRssFeedForSource(source);
      if (articles.isNotEmpty) {
        // Add new articles and re-sort
        _articles
            .addAll(articles.where((article) => article.isHurricaneRelated));
        _articles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching from ${source.name}: $e');
      // Continue with other sources
    }
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
