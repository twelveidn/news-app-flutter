import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/bookmark_provider.dart';
import 'providers/news_provider.dart';
import 'screens/home_screen.dart';
import 'services/api_news_services.dart';
import 'services/news_service.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key, this.newsService});

  final NewsService? newsService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NewsService>(create: (_) => newsService ?? ApiNewsService()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              NewsProvider(context.read<NewsService>())..loadArticles(),
        ),
      ],
      child: MaterialApp(
        title: 'Kabar',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
