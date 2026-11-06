class Article {
  const Article({
    required this.title,
    this.sourceName,
    this.author,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.category,
  });

  final String title;
  final String? sourceName;
  final String? author;
  final String? description;
  final String? url;
  final String? urlToImage;
  final DateTime? publishedAt;
  final String? content;
  final String? category;

  String get id => url ?? title;

  factory Article.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    final sourceName = source is Map<String, dynamic>
        ? source['name'] as String?
        : null;
    final publishedAt = json['publishedAt'];

    return Article(
      title: json['title'] as String? ?? 'Tanpa judul',
      sourceName: sourceName,
      author: json['author'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: publishedAt is String
          ? DateTime.tryParse(publishedAt)
          : null,
      content: json['content'] as String?,
      category: json['category'] as String?,
    );
  }
}
