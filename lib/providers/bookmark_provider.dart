import 'package:flutter/foundation.dart';

import '../models/article.dart';

class BookmarkProvider extends ChangeNotifier {
  final Map<String, Article> _articles = {};

  List<Article> get articles => List.unmodifiable(_articles.values);

  bool isBookmarked(Article article) => _articles.containsKey(article.id);

  void toggle(Article article) {
    if (_articles.containsKey(article.id)) {
      _articles.remove(article.id);
    } else {
      _articles[article.id] = article;
    }
    notifyListeners();
  }
}
