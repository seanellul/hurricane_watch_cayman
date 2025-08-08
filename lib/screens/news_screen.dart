import 'package:flutter/material.dart';
// removed duplicate import
import 'package:hurricane_watch/providers/news_provider.dart';
import 'package:hurricane_watch/models/news.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:hurricane_watch/providers/weather_provider.dart';
// import 'package:intl/intl.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  String? _selectedSource; // null means All (hurricane-only content)
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadNewsProgressively();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 8,
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading && newsProvider.articles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (newsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading news',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    newsProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      newsProvider.refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (newsProvider.articles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hurricane news available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Always use strict hurricane-only articles
          final allArticles = newsProvider.getStrictHurricaneArticles();
          final List<NewsArticle> displayed = _selectedSource == null
              ? allArticles
              : allArticles.where((a) => a.source == _selectedSource).toList();

          // Build chips from available sources
          final sources = {for (final a in allArticles) a.source}.toList()
            ..sort();

          final filtered = displayed;

          // Choose a featured article: prefer NHC Advisory, else any hurricane-related, else the newest
          NewsArticle? featured;
          if (filtered.isNotEmpty) {
            featured = filtered.firstWhere(
              (a) => a.source == 'NHC Advisories' && a.isHurricaneRelated,
              orElse: () {
                return filtered.firstWhere(
                  (a) => a.isHurricaneRelated,
                  orElse: () => filtered.first,
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await newsProvider.loadNewsProgressively();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                if (newsProvider.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                // Moved from Dashboard: Daily Digest (top of Latest News)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _HeadlineDigestInline(),
                ),
                const SizedBox(height: 12),
                // Moved from Dashboard: Closest System card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _StormProximityInline(),
                ),
                const SizedBox(height: 12),
                // Quick glance: horizontal latest strip
                if (filtered.isNotEmpty)
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) {
                        final a = filtered[i];
                        return SizedBox(
                          width: 260,
                          child: GestureDetector(
                            onTap: () => _openInApp(article: a),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Row(
                                children: [
                                  if (a.imageUrl != null)
                                    SizedBox(
                                      width: 110,
                                      height: double.infinity,
                                      child: CachedNetworkImage(
                                        imageUrl: a.imageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 110,
                                      color: Colors.blueGrey.shade100,
                                      child: const Icon(Icons.image, size: 32),
                                    ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            a.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            a.source,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _relativeTime(a.publishedAt),
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                    color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: filtered.length.clamp(0, 12),
                    ),
                  ),
                const SizedBox(height: 12),
                // Featured article
                if (featured != null)
                  Builder(builder: (context) {
                    final f = featured!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FeaturedNewsCard(
                        article: f,
                        onTap: () => _openInApp(article: f),
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                // Source chips (hurricane-only across all sources)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      final String? source = i == 0 ? null : sources[i - 1];
                      final bool selected = _selectedSource == source;
                      return ChoiceChip(
                        label: Text(source ?? 'All Sources'),
                        selected: selected,
                        onSelected: (_) => setState(() {
                          _selectedSource = source;
                        }),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: sources.length + 1,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                // Rest of the list (skip featured if present)
                ...filtered.where((a) => a != featured).map((a) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: NewsCard(
                        article: a,
                        onTap: () => _openInApp(article: a),
                      ),
                    )),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;

  const NewsCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: article.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.black12,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.black12,
                      ),
                    ),
                  ),
                ),
              if (article.imageUrl != null) const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (article.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _categoryColor(context, article.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.category!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                article.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.source,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    article.source,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(article.publishedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(BuildContext context, String? category) {
    final c = (category ?? '').toLowerCase();
    final scheme = Theme.of(context).colorScheme;
    if (c.contains('advisory') || c.contains('forecast')) return scheme.primary;
    if (c.contains('outlook') || c.contains('weather')) return Colors.blueGrey;
    if (c.contains('education')) return Colors.deepPurple;
    if (c.contains('business')) return Colors.teal;
    if (c.contains('press')) return Colors.blue;
    return scheme.secondary;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now().toUtc();
    final articleDate = date.toUtc();
    final difference = now.difference(articleDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes < 0) {
      // Handle future dates (might happen due to timezone issues)
      return 'Recently';
    } else {
      return 'Just now';
    }
  }

  // Kept for potential future external-opening; currently we open in-app
  // Future<void> _launchUrl(String url) async {
  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   }
  // }
}

class FeaturedNewsCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback? onTap;

  const FeaturedNewsCard({
    super.key,
    required this.article,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: article.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: Colors.blueGrey.shade100),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.05), Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    article.source,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(article.publishedAt),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(date.toUtc());
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    return 'Just now';
  }
}

// Inline widgets ported from Dashboard
class _HeadlineDigestInline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final storms = weather.activeHurricanes;
    final proximity = weather.getClosestStormProximity();
    final String line1 = storms.isEmpty
        ? 'No active systems'
        : '${storms.length} active system${storms.length > 1 ? 's' : ''} in basin';
    final String line2 = storms.isEmpty
        ? 'Chance of Cayman impacts is low'
        : 'Closest system ~${proximity.distanceMiles.round()} mi • ETA ~${proximity.etaHours}h';
    final String line3 = storms.isEmpty
        ? 'Stay prepared: check water and batteries'
        : proximity.confidence >= 0.75
            ? 'Elevated risk: review plan and supplies'
            : 'Monitoring advisories; keep essentials topped up';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Digest', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _digestBullet(context, line1),
            _digestBullet(context, line2),
            _digestBullet(context, line3),
          ],
        ),
      ),
    );
  }

  Widget _digestBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.brightness_1, size: 8, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _StormProximityInline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final p = weather.getClosestStormProximity();
    if (p.storm == null) {
      return const SizedBox.shrink();
    }
    final color = p.confidence >= 0.75
        ? Colors.red
        : p.confidence >= 0.5
            ? Colors.orange
            : Colors.blueGrey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Closest System: ${p.storm!.name}',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${p.distanceMiles.round()} miles away • ETA ~${p.etaHours} hours',
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.confidence.clamp(0, 1),
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
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

class InAppBrowserPage extends StatefulWidget {
  final String initialUrl;
  final String? title;

  const InAppBrowserPage({super.key, required this.initialUrl, this.title});

  @override
  State<InAppBrowserPage> createState() => _InAppBrowserPageState();
}

class _InAppBrowserPageState extends State<InAppBrowserPage> {
  late final WebViewController _controller;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => setState(() => _progress = p),
      ))
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () async {
              final uri = Uri.parse(widget.initialUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: _progress < 100
              ? LinearProgressIndicator(value: _progress / 100)
              : const SizedBox.shrink(),
        ),
      ),
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}

extension _NewsOpenExt on _NewsScreenState {
  String _relativeTime(DateTime date) {
    final now = DateTime.now().toUtc();
    final diff = now.difference(date.toUtc());
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    return 'Just now';
  }

  void _openInApp({required NewsArticle article}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InAppBrowserPage(
          initialUrl: article.link,
          title: article.source,
        ),
      ),
    );
  }
}
