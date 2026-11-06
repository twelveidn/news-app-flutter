import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../theme/app_theme.dart';
import '../utils/article_formatters.dart';
import '../widgets/article_image.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBookmarked = context.select<BookmarkProvider, bool>(
      (provider) => provider.isBookmarked(article),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail berita'),
        actions: [
          IconButton(
            onPressed: () => context.read<BookmarkProvider>().toggle(article),
            tooltip: isBookmarked ? 'Hapus dari favorit' : 'Simpan ke favorit',
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArticleImage(
              imageUrl: article.urlToImage,
              width: double.infinity,
              height: 260,
              borderRadius: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category ?? article.sourceName ?? 'Berita',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(article.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Text(
                    [
                      article.sourceName ?? 'Sumber tidak diketahui',
                      if (article.author != null) article.author!,
                      formatPublishedAt(article.publishedAt),
                    ].join(' · '),
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (article.description != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      article.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.ink,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (article.content != null) ...[
                    const SizedBox(height: 16),
                    Text(article.content!, style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tautan aktif setelah integrasi API.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Baca selengkapnya'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
