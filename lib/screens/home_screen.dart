import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../providers/bookmark_provider.dart';
import '../providers/news_provider.dart';
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
      appBar: AppBar(
        title: Text(
          'Kabar Hari Ini',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () => _openBookmarks(context),
            tooltip: 'Buka favorit',
            icon: Badge(
              isLabelVisible: bookmarks.articles.isNotEmpty,
              label: Text('${bookmarks.articles.length}'),
              child: const Icon(Icons.bookmarks_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Cari berita...',
                  prefixIcon: const Icon(Icons.search),
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
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            SizedBox(
              height: 56,
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
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final article = articles[index];
            return ArticleCard(
              article: article,
              onTap: () => _openArticle(context, article),
              isBookmarked: bookmarks.isBookmarked(article),
              onBookmarkToggle: () => bookmarks.toggle(article),
            );
          },
        );
    }
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
