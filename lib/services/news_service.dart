import '../models/article.dart';

abstract interface class NewsService {
  Future<List<Article>> fetchArticles();
}

class NewsServiceException implements Exception {
  const NewsServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
