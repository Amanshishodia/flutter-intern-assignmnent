import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/datasources/remote/news_api_service.dart';

enum NewsStatus {
  initial,
  loading,
  loaded,
  error,
}

class NewsProvider extends ChangeNotifier {
  final NewsApiService _apiService = NewsApiService();
  final NewsRepositoryImpl _repository = NewsRepositoryImpl();

  NewsStatus _status = NewsStatus.initial;
  List<ArticleModel> _articles = [];
  List<ArticleModel> _bookmarkedArticles = [];
  String? _errorMessage;
  String _currentCategory = '';
  String _searchQuery = '';
  bool _isSearchActive = false;
  Timer? _debounceTimer;
  final _searchController = StreamController<String>.broadcast();

  NewsStatus get status => _status;
  List<ArticleModel> get articles => _articles;
  List<ArticleModel> get bookmarkedArticles => _bookmarkedArticles;
  String? get errorMessage => _errorMessage;
  String get currentCategory => _currentCategory;
  String get searchQuery => _searchQuery;
  bool get isSearchActive => _isSearchActive;

  NewsProvider() {
    // Set up debounced search
    _searchController.stream
        .debounceTime(Duration(milliseconds: 500))
        .listen((query) {
      if (query.isNotEmpty) {
        _searchNews(query);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.close();
    super.dispose();
  }

  void onSearchQueryChanged(String query) {
    _searchQuery = query;
    _isSearchActive = query.isNotEmpty;

    if (query.isEmpty) {
      if (_currentCategory.isNotEmpty) {
        getNewsByCategory(_currentCategory);
      } else {
        getTopHeadlines();
      }
    } else {
      _searchController.add(query);
    }

    notifyListeners();
  }

  Future<void> getTopHeadlines() async {
    try {
      _status = NewsStatus.loading;
      _currentCategory = '';
      _isSearchActive = false;
      notifyListeners();

      final newsResponse = await _apiService.getTopHeadlines();
      _articles = newsResponse.articles;

      // Cache articles
      await _repository.cacheArticles(_articles);

      _status = NewsStatus.loaded;
    } catch (e) {
      _status = NewsStatus.error;
      _errorMessage = e.toString();

      // Try to load cached data
      try {
        _articles = await _repository.getCachedArticles();
      } catch (e) {
        // If no cached data available, keep articles empty
      }
    }
    notifyListeners();
  }

  Future<void> getNewsByCategory(String category) async {
    try {
      _status = NewsStatus.loading;
      _currentCategory = category;
      _isSearchActive = false;
      notifyListeners();

      final newsResponse = await _apiService.getTopHeadlines(category: category);
      _articles = newsResponse.articles;

      // Cache articles by category
      await _repository.cacheArticlesByCategory(category, _articles);

      _status = NewsStatus.loaded;
    } catch (e) {
      _status = NewsStatus.error;
      _errorMessage = e.toString();

      // Try to load cached data for this category
      try {
        _articles = await _repository.getCachedArticlesByCategory(category);
      } catch (e) {
        // If no cached data available, keep articles empty
      }
    }
    notifyListeners();
  }

  Future<void> _searchNews(String query) async {
    try {
      _status = NewsStatus.loading;
      notifyListeners();

      final newsResponse = await _apiService.searchNews(query: query);
      _articles = newsResponse.articles;
      _status = NewsStatus.loaded;
    } catch (e) {
      _status = NewsStatus.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> bookmarkArticle(ArticleModel article) async {
    final isBookmarked = _bookmarkedArticles.any((a) => a.url == article.url);

    if (isBookmarked) {
      _bookmarkedArticles.removeWhere((a) => a.url == article.url);
      await _repository.removeBookmark(article);
    } else {
      _bookmarkedArticles.add(article);
      await _repository.saveBookmark(article);
    }

    notifyListeners();
  }

  bool isArticleBookmarked(String url) {
    return _bookmarkedArticles.any((article) => article.url == url);
  }

  Future<void> loadBookmarks() async {
    try {
      _bookmarkedArticles = await _repository.getBookmarkedArticles();
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}