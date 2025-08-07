// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsArticle _$NewsArticleFromJson(Map<String, dynamic> json) => NewsArticle(
      title: json['title'] as String,
      description: json['description'] as String,
      link: json['link'] as String,
      imageUrl: json['imageUrl'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      source: json['source'] as String,
      category: json['category'] as String?,
      isHurricaneRelated: json['isHurricaneRelated'] as bool,
    );

Map<String, dynamic> _$NewsArticleToJson(NewsArticle instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'link': instance.link,
      'imageUrl': instance.imageUrl,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'source': instance.source,
      'category': instance.category,
      'isHurricaneRelated': instance.isHurricaneRelated,
    };

NewsSource _$NewsSourceFromJson(Map<String, dynamic> json) => NewsSource(
      name: json['name'] as String,
      url: json['url'] as String,
      rssUrl: json['rssUrl'] as String,
      logoUrl: json['logoUrl'] as String?,
    );

Map<String, dynamic> _$NewsSourceToJson(NewsSource instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'rssUrl': instance.rssUrl,
      'logoUrl': instance.logoUrl,
    };
