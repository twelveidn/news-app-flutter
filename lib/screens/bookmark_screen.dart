import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import 'detail_screen.dart';
import '../widgets/article_card.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarkProvider>();
    final articles = provider.articles;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorit', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: articles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada berita favorit',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Simpan berita yang menarik agar mudah dibaca lagi.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Jelajahi berita'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: articles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final article = articles[index];
                return ArticleCard(
                  article: article,
                  onTap: () => _openArticle(context, article),
                  isBookmarked: true,
                  onBookmarkToggle: () => provider.toggle(article),
                );
              },
            ),
    );
  }

  void _openArticle(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailScreen(article: article)),
    );
  }
}
