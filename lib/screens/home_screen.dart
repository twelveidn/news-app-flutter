import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';
import '../utils/article_formatters.dart';
import '../widgets/article_image.dart';
import 'bookmark_screen.dart';
import 'detail_screen.dart';
import '../widgets/article_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categories = [
    'Semua',
    'Bisnis',
    'Olahraga',
    'Teknologi',
    'Lingkungan',
  ];

  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsProvider>();
    final bookmarks = context.watch<BookmarkProvider>();
    final articles = _filterArticles(provider.articles);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EDISI DIGITAL  ·  BERITA TERPILIH',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kabar Hari Ini',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontSize: 30, letterSpacing: -1),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openBookmarks(context),
                    tooltip: 'Buka favorit',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.ink,
                      side: const BorderSide(color: AppTheme.divider),
                    ),
                    icon: Badge(
                      isLabelVisible: bookmarks.articles.isNotEmpty,
                      label: Text('${bookmarks.articles.length}'),
                      child: const Icon(Icons.bookmarks_outlined),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(height: 1, color: AppTheme.divider),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Cari berita...',
                  prefixIcon: const Icon(Icons.search),
                  prefixIconColor: AppTheme.accent,
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _clearQuery,
                          tooltip: 'Hapus pencarian',
                          icon: const Icon(Icons.close),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppTheme.accent,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            SizedBox(
              height: 54,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    showCheckmark: false,
                    selectedColor: AppTheme.ink,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: _selectedCategory == category
                          ? AppTheme.ink
                          : AppTheme.divider,
                    ),
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? Colors.white
                          : AppTheme.ink,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.loadArticles,
                child: _buildArticles(context, provider, bookmarks, articles),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Article> _filterArticles(List<Article> articles) {
    final query = _query.trim().toLowerCase();
    return articles.where((article) {
      final matchesCategory =
          _selectedCategory == 'Semua' ||
          article.category?.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          [
            article.title,
            article.description,
            article.sourceName,
            article.category,
          ].any((value) => value?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Widget _buildArticles(
    BuildContext context,
    NewsProvider provider,
    BookmarkProvider bookmarks,
    List<Article> articles,
  ) {
    switch (provider.status) {
      case NewsStatus.loading:
        return _stateList(
          context,
          const CircularProgressIndicator(semanticsLabel: 'Memuat berita'),
        );
      case NewsStatus.error:
        return _stateList(
          context,
          _MessageState(
            icon: Icons.cloud_off_outlined,
            title: 'Berita belum bisa dimuat',
            message: provider.errorMessage ?? 'Silakan coba lagi.',
            action: FilledButton.icon(
              onPressed: provider.loadArticles,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ),
        );
      case NewsStatus.empty:
        return _stateList(
          context,
          const _MessageState(
            icon: Icons.article_outlined,
            title: 'Belum ada berita',
            message: 'Coba muat ulang beberapa saat lagi.',
          ),
        );
      case NewsStatus.success:
        if (articles.isEmpty) {
          return _stateList(
            context,
            _MessageState(
              icon: Icons.search_off,
              title: 'Berita tidak ditemukan',
              message: 'Coba kata kunci atau kategori lain.',
              action: TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Hapus filter'),
              ),
            ),
          );
        }
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _sectionHeading(context, 'BERITA PILIHAN'),
            const SizedBox(height: 12),
            _FeaturedArticle(
              article: articles.first,
              isBookmarked: bookmarks.isBookmarked(articles.first),
              onTap: () => _openArticle(context, articles.first),
              onBookmarkToggle: () => bookmarks.toggle(articles.first),
            ),
            if (articles.length > 1) ...[
              const SizedBox(height: 24),
              _sectionHeading(context, 'BERITA LAINNYA'),
              const SizedBox(height: 12),
              for (final article in articles.skip(1)) ...[
                ArticleCard(
                  article: article,
                  onTap: () => _openArticle(context, article),
                  isBookmarked: bookmarks.isBookmarked(article),
                  onBookmarkToggle: () => bookmarks.toggle(article),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ],
        );
    }
  }

  Widget _sectionHeading(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.ink,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(height: 1, color: AppTheme.divider)),
      ],
    );
  }

  Widget _stateList(BuildContext context, Widget state) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.5,
          child: Center(child: state),
        ),
      ],
    );
  }

  void _clearQuery() {
    setState(() {
      _searchController.clear();
      _query = '';
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _query = '';
      _selectedCategory = 'Semua';
    });
  }

  void _openArticle(BuildContext context, Article article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DetailScreen(article: article)),
    );
  }

  void _openBookmarks(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const BookmarkScreen()));
  }
}

class _FeaturedArticle extends StatelessWidget {
  const _FeaturedArticle({
    required this.article,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  final Article article;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: AppTheme.ink,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              height: 330,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: ArticleImage(
                      imageUrl: article.urlToImage,
                      width: double.infinity,
                      height: 330,
                      borderRadius: 0,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x0010253F), Color(0xF210253F)],
                        stops: [0.2, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: onBookmarkToggle,
                      tooltip: isBookmarked
                          ? 'Hapus dari favorit'
                          : 'Simpan ke favorit',
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xAA10253F),
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          article.category?.toUpperCase() ??
                              article.sourceName?.toUpperCase() ??
                              'BERITA',
                          style: const TextStyle(
                            color: Color(0xFFB8D9FA),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 9),
                        Text(
                          article.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Georgia',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.12,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (article.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            article.description!,
                            style: const TextStyle(
                              color: Color(0xFFE0EAF5),
                              fontSize: 13,
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 10),
                        Text(
                          [
                            article.sourceName ?? 'Kabar Hari Ini',
                            formatPublishedAt(article.publishedAt),
                          ].join('  ·  '),
                          style: const TextStyle(
                            color: Color(0xFFCFDCEC),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}
