import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';
import 'news_exception.dart';
import 'news_service.dart';

class ApiNewsService implements NewsService {
  static const _apiKey = String.fromEnvironment('NEWS_API_KEY');
  @override
  Future<List<Article>> fetchArticles({String? query, String? category}) async {
    if (_apiKey.isEmpty) {
      throw const NewsException(
        'API key belum diisi. Jalankan dengan --dart-define-fromfile=env.json',
      );
    }
    final uri = Uri.https('newsapi.org', '/v2/top-headlines', {
      'country': 'us',
      'page': '1',
      'pageSize': '20',
      'category': category,
      if (query != null && query.isNotEmpty) 'q': query,
    });
    final response = await http
        .get(uri, headers: {'X-Api-Key': _apiKey})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw NewsException(_pesanError(response.statusCode));
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['articles'] as List<dynamic>? ?? [];
    return items
        .map((item) => Article.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String _pesanError(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid. Periksa parameter yang dikirim.';
      case 401:
        return 'API key salah atau tidak terkirim.';
      case 429:
        return 'Terlalu banyak permintaan atau kuota harian habis. Coba lagi nanti.';
      default:
        return 'Server bermasalah (kode $statusCode). Coba lagi nanti.';
    }
  }
}
