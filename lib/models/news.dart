import 'package:json_annotation/json_annotation.dart';

part 'news.g.dart';

@JsonSerializable()
class NewsArticle {
  final String title;
  final String description;
  final String link;
  final String? imageUrl;
  final DateTime publishedAt;
  final String source;
  final String? category;
  final bool isHurricaneRelated;

  NewsArticle({
    required this.title,
    required this.description,
    required this.link,
    this.imageUrl,
    required this.publishedAt,
    required this.source,
    this.category,
    required this.isHurricaneRelated,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) =>
      _$NewsArticleFromJson(json);
  Map<String, dynamic> toJson() => _$NewsArticleToJson(this);
}

@JsonSerializable()
class NewsSource {
  final String name;
  final String url;
  final String rssUrl;
  final String? logoUrl;

  NewsSource({
    required this.name,
    required this.url,
    required this.rssUrl,
    this.logoUrl,
  });

  factory NewsSource.fromJson(Map<String, dynamic> json) =>
      _$NewsSourceFromJson(json);
  Map<String, dynamic> toJson() => _$NewsSourceToJson(this);
}
