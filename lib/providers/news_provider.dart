import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../services/news_service.dart';

enum NewsStatus { loading, success, error, empty }

class NewsProvider extends ChangeNotifier {
  NewsProvider(this._service);

  final NewsService _service;
  List<Article> _articles = [];
  NewsStatus _status = NewsStatus.loading;
  String? _errorMessage;

  List<Article> get articles => List.unmodifiable(_articles);
  NewsStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> loadArticles() async {
    _status = NewsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _articles = await _service.fetchArticles();
      _status = _articles.isEmpty ? NewsStatus.empty : NewsStatus.success;
    } on Exception catch (error, stackTrace) {
      debugPrint('NewsProvider.loadArticles failed: $error\n$stackTrace');
      _errorMessage = error is NewsServiceException
          ? error.message
          : 'Terjadi kesalahan saat memuat berita.';
      _status = NewsStatus.error;
    }

    notifyListeners();
  }
}
