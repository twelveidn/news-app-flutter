import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses all articles from the NewsAPI-shaped sample asset', () async {
    final json = jsonDecode(
      await rootBundle.loadString('assets/mock/articles.json'),
    ) as Map<String, dynamic>;

    final articles = (json['articles'] as List<dynamic>)
        .map((item) => Article.fromJson(item as Map<String, dynamic>))
        .toList();

    expect(json['status'], 'ok');
    expect(json['totalResults'], articles.length);
    expect(articles, hasLength(4));
    expect(articles.first.title, contains('Kota-kota'));
    expect(articles.first.sourceName, 'Ruang Sains');
    expect(articles.first.publishedAt, DateTime.parse('2026-11-05T08:30:00Z'));
    expect(articles[2].description, isNull);
    expect(
      articles[2].urlToImage,
      'https://images.unsplash.com/photo-1552674605-db6ffd4facb5',
    );
  });

  test('uses a safe title when the response omits it', () {
    final article = Article.fromJson(const <String, dynamic>{});

    expect(article.title, 'Tanpa judul');
    expect(article.sourceName, isNull);
    expect(article.publishedAt, isNull);
  });
}
