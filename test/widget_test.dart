import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app/main.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/services/news_service.dart';

void main() {
  testWidgets('shows the loading state while news is fetched', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      NewsApp(newsService: MockNewsService(delay: const Duration(seconds: 1))),
    );

    expect(find.bySemanticsLabel('Memuat berita'), findsOneWidget);
    expect(find.text('Kabar Hari Ini'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('shows the article list after a successful fetch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(NewsApp(newsService: _StaticNewsService()));
    await tester.pumpAndSettle();

    expect(find.text('Contoh berita'), findsOneWidget);
  });

  testWidgets('opens the article detail from the home list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(NewsApp(newsService: _StaticNewsService()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contoh berita'));
    await tester.pumpAndSettle();

    expect(find.text('Detail berita'), findsOneWidget);
    expect(find.text('Baca selengkapnya'), findsOneWidget);
  });

  testWidgets('keeps bookmarks consistent between home and favorites', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(NewsApp(newsService: _StaticNewsService()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Simpan ke favorit'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Hapus dari favorit'), findsOneWidget);

    await tester.tap(find.byTooltip('Buka favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Contoh berita'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus dari favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada berita favorit'), findsOneWidget);
  });

  testWidgets('can bookmark an article from its detail screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(NewsApp(newsService: _StaticNewsService()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contoh berita'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Simpan ke favorit'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Buka favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Contoh berita'), findsOneWidget);
  });

  testWidgets('shows a retry action when loading fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      NewsApp(
        newsService: MockNewsService(
          response: MockResponse.error,
          delay: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Berita belum bisa dimuat'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });

  testWidgets('shows the empty state when no articles are returned', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      NewsApp(
        newsService: MockNewsService(
          response: MockResponse.empty,
          delay: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada berita'), findsOneWidget);
  });

  testWidgets('search and category chips filter the article list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      NewsApp(
        newsService: _StaticNewsService(
          articles: const [
            Article(title: 'Berita Inovasi', category: 'Teknologi'),
            Article(title: 'Pasar Lokal', category: 'Bisnis'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'pasar');
    await tester.pumpAndSettle();
    expect(find.text('Pasar Lokal'), findsOneWidget);
    expect(find.text('Berita Inovasi'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Teknologi'));
    await tester.pumpAndSettle();
    expect(find.text('Berita Inovasi'), findsOneWidget);
    expect(find.text('Pasar Lokal'), findsNothing);
  });

  testWidgets('offers a clear action when filters have no matches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(NewsApp(newsService: _StaticNewsService()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'tidak ada');
    await tester.pumpAndSettle();
    expect(find.text('Berita tidak ditemukan'), findsOneWidget);

    await tester.tap(find.text('Hapus filter'));
    await tester.pumpAndSettle();
    expect(find.text('Contoh berita'), findsOneWidget);
  });
}

class _StaticNewsService implements NewsService {
  const _StaticNewsService({
    this.articles = const [
      Article(title: 'Contoh berita', category: 'Teknologi'),
    ],
  });

  final List<Article> articles;

  @override
  Future<List<Article>> fetchArticles() async => articles;
}
