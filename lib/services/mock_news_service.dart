import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/article.dart';
import 'news_service.dart';

enum MockResponse { success, error, empty }

class MockNewsService implements NewsService {
  MockNewsService({
    this.response = MockResponse.success,
    this.delay = const Duration(seconds: 1),
  });

  final MockResponse response;
  final Duration delay;

  @override
  Future<List<Article>> fetchArticles() async {
    await Future<void>.delayed(delay);

    switch (response) {
      case MockResponse.error:
        throw const NewsServiceException(
          'Berita gagal dimuat. Silakan coba lagi.',
        );
      case MockResponse.empty:
        return [];
      case MockResponse.success:
        final json = jsonDecode(
          await rootBundle.loadString('assets/mock/articles.json'),
        );
        if (json is! Map<String, dynamic>) {
          throw const FormatException(
            'Respons berita harus berupa objek JSON.',
          );
        }
        final articles = json['articles'];
        if (articles is! List) {
          throw const FormatException(
            'Respons berita harus memiliki daftar articles.',
          );
        }
        return articles
            .map((item) => Article.fromJson(item as Map<String, dynamic>))
            .toList();
    }
  }
}
