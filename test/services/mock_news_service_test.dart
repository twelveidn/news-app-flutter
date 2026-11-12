import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/services/news_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('returns parsed fixture articles in success mode', () async {
    final service = MockNewsService(delay: Duration.zero);

    final articles = await service.fetchArticles();

    expect(articles, hasLength(4));
    expect(articles.first.title, contains('Kota-kota'));
    expect(articles.every((article) => article.urlToImage != null), isTrue);
  });

  test('returns an empty list in empty mode', () async {
    final service = MockNewsService(
      response: MockResponse.empty,
      delay: Duration.zero,
    );

    expect(await service.fetchArticles(), isEmpty);
  });

  test('throws a service error in error mode', () async {
    final service = MockNewsService(
      response: MockResponse.error,
      delay: Duration.zero,
    );

    await expectLater(
      service.fetchArticles(),
      throwsA(isA<NewsServiceException>()),
    );
  });
}
