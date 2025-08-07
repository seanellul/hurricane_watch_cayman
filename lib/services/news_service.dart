import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:hurricane_watch/models/news.dart';

class NewsService {
  static final List<NewsSource> _sources = [
    NewsSource(
      name: 'Cayman Compass',
      url: 'https://www.caymancompass.com',
      rssUrl: 'https://www.caymancompass.com/feed/',
    ),
    // NewsSource(
    //   name: 'Loop Cayman',
    //   url: 'https://www.loopcayman.com',
    //   rssUrl: 'https://www.loopcayman.com/feed/',
    // ),
    NewsSource(
      name: 'NHC Advisories',
      url: 'https://www.nhc.noaa.gov',
      rssUrl: 'https://www.nhc.noaa.gov/index-at.xml',
    ),
  ];

  Future<List<NewsArticle>> getHurricaneNews() async {
    // Fetch from all sources concurrently with individual timeouts
    final futures = _sources.map((source) => _fetchRssFeed(source));

    // Wait for all feeds to complete or timeout (max 5 seconds each)
    final results = await Future.wait(
      futures,
      eagerError: false, // Don't stop on first error
    );

    // Combine all successful results
    final List<NewsArticle> allArticles = [];
    for (final articles in results) {
      allArticles.addAll(articles);
    }

    // Filter for hurricane-related articles and sort by date
    final hurricaneArticles = allArticles
        .where((article) => article.isHurricaneRelated)
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return hurricaneArticles;
  }

  Future<List<NewsArticle>> _fetchRssFeed(NewsSource source) async {
    try {
      print('🔄 Fetching RSS feed from ${source.name}...');

      final response = await http.get(
        Uri.parse(source.rssUrl),
        headers: {'User-Agent': 'CaymanHurricaneWatch/1.0'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏰ Timeout fetching RSS feed from ${source.name}');
          throw TimeoutException('Request timeout', const Duration(seconds: 5));
        },
      );

      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        final articles =
            feed.items?.map((item) => _parseRssItem(item, source)).toList() ??
                [];

        print('✅ ${source.name}: Found ${articles.length} articles');
        return articles;
      } else {
        print('❌ ${source.name}: HTTP ${response.statusCode}');
        throw Exception('HTTP ${response.statusCode} from ${source.name}');
      }
    } on TimeoutException catch (e) {
      print('⏰ ${source.name}: $e');
      return []; // Return empty list for timeout
    } catch (e) {
      print('❌ Error fetching RSS feed from ${source.name}: $e');
      return []; // Return empty list instead of throwing
    }
  }

  NewsArticle _parseRssItem(RssItem item, NewsSource source) {
    final title = item.title ?? '';
    final description = item.description ?? '';
    final link = item.link ?? '';
    final pubDate = item.pubDate;

    // Handle NHC advisory timestamps more accurately
    DateTime publishedAt;
    if (source.name == 'NHC Advisories') {
      // For NHC advisories, always try to extract more accurate date from content
      // as RSS pubDate might be incorrect or missing
      final extractedDate = _extractNHCDate(title, description);
      if (extractedDate != null) {
        publishedAt = extractedDate;
        print(
            '📅 Extracted NHC date: $extractedDate for: ${title.length > 50 ? title.substring(0, 50) + '...' : title}');
      } else {
        publishedAt = pubDate ?? DateTime.now();
        print(
            '⚠️ Could not extract NHC date, using pubDate: $pubDate for: ${title.length > 50 ? title.substring(0, 50) + '...' : title}');
      }
    } else {
      publishedAt = pubDate ?? DateTime.now();
    }

    // Extract image URL from description if available
    String? imageUrl;
    if (description.contains('<img')) {
      final imgMatch =
          RegExp(r'<img[^>]+src="([^"]+)"').firstMatch(description);
      if (imgMatch != null) {
        imageUrl = imgMatch.group(1);
      }
    }

    // Determine if article is hurricane-related
    final isHurricaneRelated = _isHurricaneRelated(title, description);

    return NewsArticle(
      title: _improveTitle(title, source),
      description: _improveDescription(description, source),
      link: link,
      imageUrl: imageUrl,
      publishedAt: publishedAt,
      source: source.name,
      category: _extractCategory(item),
      isHurricaneRelated: isHurricaneRelated,
    );
  }

  bool _isHurricaneRelated(String title, String description) {
    final hurricaneKeywords = [
      'hurricane',
      'tropical storm',
      'tropical depression',
      'cyclone',
      'storm',
      'weather warning',
      'weather alert',
      'emergency',
      'evacuation',
      'preparation',
      'preparedness',
      'NHC',
      'National Hurricane Center',
    ];

    final text = '${title.toLowerCase()} ${description.toLowerCase()}';

    return hurricaneKeywords
        .any((keyword) => text.contains(keyword.toLowerCase()));
  }

  String _cleanHtml(String html) {
    // Simple HTML tag removal
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  String? _extractCategory(RssItem item) {
    // Try to extract category from various RSS fields
    if (item.categories?.isNotEmpty == true) {
      return item.categories!.first.value;
    }

    return null;
  }

  DateTime? _extractNHCDate(String title, String description) {
    final text = '$title $description';
    print(
        '🔍 Trying to extract date from: ${text.length > 100 ? text.substring(0, 100) + '...' : text}');

    // Pattern 1: "Thu, 07 Aug 2025 14:49:41 GMT" or "Thu Aug 07 2025 14:49:41 GMT"
    final fullDatePattern = RegExp(
      r'(Mon|Tue|Wed|Thu|Fri|Sat|Sun),?\s+'
      r'(\d{1,2})\s+'
      r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+'
      r'(\d{4})\s+'
      r'(\d{1,2}):(\d{2}):(\d{2})\s+'
      r'(GMT|UTC)',
      caseSensitive: false,
    );

    final fullMatch = fullDatePattern.firstMatch(text);
    if (fullMatch != null) {
      try {
        final day = int.parse(fullMatch.group(2)!);
        final month = _monthNameToNumber(fullMatch.group(3)!);
        final year = int.parse(fullMatch.group(4)!);
        final hour = int.parse(fullMatch.group(5)!);
        final minute = int.parse(fullMatch.group(6)!);
        final second = int.parse(fullMatch.group(7)!);

        final parsed = DateTime.utc(year, month, day, hour, minute, second);
        print('✅ Parsed full date: $parsed');
        return parsed;
      } catch (e) {
        print('❌ Error parsing full NHC date: $e');
      }
    }

    // Pattern 2: "1100 AM AST Thu Aug 07 2025" (time first format)
    final timeFirstPattern = RegExp(
      r'(\d{1,4})\s+(AM|PM)\s+(AST|EST|EDT|CST|CDT|MST|MDT|PST|PDT)\s+'
      r'(Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s+'
      r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+'
      r'(\d{1,2})\s+'
      r'(\d{4})',
      caseSensitive: false,
    );

    final timeFirstMatch = timeFirstPattern.firstMatch(text);
    if (timeFirstMatch != null) {
      try {
        final timeStr = timeFirstMatch.group(1)!;
        final ampm = timeFirstMatch.group(2)!.toLowerCase();
        final timezone = timeFirstMatch.group(3)!.toUpperCase();
        final month = _monthNameToNumber(timeFirstMatch.group(5)!);
        final day = int.parse(timeFirstMatch.group(6)!);
        final year = int.parse(timeFirstMatch.group(7)!);

        // Parse time (handle formats like "1100" or "11")
        int hour = 0;
        int minute = 0;
        if (timeStr.length == 4) {
          // Format like "1100" -> 11:00
          hour = int.parse(timeStr.substring(0, 2));
          minute = int.parse(timeStr.substring(2, 4));
        } else if (timeStr.length == 3) {
          // Format like "100" -> 1:00
          hour = int.parse(timeStr.substring(0, 1));
          minute = int.parse(timeStr.substring(1, 3));
        } else if (timeStr.length <= 2) {
          // Format like "11" -> 11:00
          hour = int.parse(timeStr);
          minute = 0;
        } else {
          print('⚠️ Unexpected time format: $timeStr');
          hour = int.parse(timeStr.substring(0, 2));
          minute = 0;
        }

        // Convert to 24-hour format
        if (ampm == 'pm' && hour != 12) hour += 12;
        if (ampm == 'am' && hour == 12) hour = 0;

        // Convert to UTC based on timezone
        final utcOffset = _getTimezoneOffset(timezone);
        final localDateTime = DateTime(year, month, day, hour, minute);
        final utcDateTime = localDateTime.add(Duration(hours: utcOffset));

        print(
            '✅ Parsed time-first date: $utcDateTime UTC (was ${timeStr} $ampm $timezone -> ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} + $utcOffset hrs)');
        return utcDateTime;
      } catch (e) {
        print('❌ Error parsing time-first NHC date: $e');
      }
    }

    // Pattern 2b: Military time format "KNHC 071727" where 07=day, 1727=time
    final militaryTimePattern = RegExp(
      r'KNHC\s+(\d{2})(\d{4})',
      caseSensitive: false,
    );

    final militaryMatch = militaryTimePattern.firstMatch(text);
    if (militaryMatch != null) {
      try {
        final dayStr = militaryMatch.group(1)!;
        final timeStr = militaryMatch.group(2)!;

        // Parse military time (HHMM format)
        final hour = int.parse(timeStr.substring(0, 2));
        final minute = int.parse(timeStr.substring(2, 4));

        // Find the date context (year/month) from surrounding text
        final dateContext = RegExp(r'(\d{4})')
            .allMatches(text)
            .where((m) => m.group(1)!.startsWith('20'))
            .first;
        final year = int.parse(dateContext.group(1)!);
        final month = DateTime.now().month; // Default to current month
        final day = int.parse(dayStr);

        final parsed = DateTime.utc(year, month, day, hour, minute);
        print('✅ Parsed military time: $parsed (from KNHC $dayStr$timeStr)');
        return parsed;
      } catch (e) {
        print('❌ Error parsing military time: $e');
      }
    }

    // Pattern 2c: "1500 UTC THU AUG 07 2025" (UTC time first format)
    final utcTimeFirstPattern = RegExp(
      r'(\d{1,4})\s+(UTC|GMT)\s+'
      r'(Mon|Tue|Wed|Thu|Fri|Sat|Sun)\s+'
      r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+'
      r'(\d{1,2})\s+'
      r'(\d{4})',
      caseSensitive: false,
    );

    final utcTimeFirstMatch = utcTimeFirstPattern.firstMatch(text);
    if (utcTimeFirstMatch != null) {
      try {
        final timeStr = utcTimeFirstMatch.group(1)!;
        final month = _monthNameToNumber(utcTimeFirstMatch.group(4)!);
        final day = int.parse(utcTimeFirstMatch.group(5)!);
        final year = int.parse(utcTimeFirstMatch.group(6)!);

        // Parse time (handle formats like "1500" -> 15:00)
        int hour = 0;
        int minute = 0;
        if (timeStr.length >= 3) {
          hour = int.parse(timeStr.substring(0, timeStr.length - 2));
          minute = int.parse(timeStr.substring(timeStr.length - 2));
        } else {
          hour = int.parse(timeStr);
        }

        final parsed = DateTime.utc(year, month, day, hour, minute);
        print('✅ Parsed UTC time-first date: $parsed (was ${timeStr} UTC)');
        return parsed;
      } catch (e) {
        print('❌ Error parsing UTC time-first NHC date: $e');
      }
    }

    // Pattern 3: "last updated Thu, 07 Aug 2025 14:49:41 GMT"
    final lastUpdatedPattern = RegExp(
      r'last updated\s+'
      r'(Mon|Tue|Wed|Thu|Fri|Sat|Sun),?\s+'
      r'(\d{1,2})\s+'
      r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+'
      r'(\d{4})\s+'
      r'(\d{1,2}):(\d{2}):(\d{2})\s+'
      r'(GMT|UTC)',
      caseSensitive: false,
    );

    final lastUpdatedMatch = lastUpdatedPattern.firstMatch(text);
    if (lastUpdatedMatch != null) {
      try {
        final day = int.parse(lastUpdatedMatch.group(2)!);
        final month = _monthNameToNumber(lastUpdatedMatch.group(3)!);
        final year = int.parse(lastUpdatedMatch.group(4)!);
        final hour = int.parse(lastUpdatedMatch.group(5)!);
        final minute = int.parse(lastUpdatedMatch.group(6)!);
        final second = int.parse(lastUpdatedMatch.group(7)!);

        final parsed = DateTime.utc(year, month, day, hour, minute, second);
        print('✅ Parsed last-updated date: $parsed');
        return parsed;
      } catch (e) {
        print('❌ Error parsing last-updated NHC date: $e');
      }
    }

    // Pattern 4: Simple date only "07 Aug 2025" or "Aug 07 2025"
    final simpleDatePattern = RegExp(
      r'(\d{1,2})\s+'
      r'(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+'
      r'(\d{4})',
      caseSensitive: false,
    );

    final simpleMatch = simpleDatePattern.firstMatch(text);
    if (simpleMatch != null) {
      try {
        final day = int.parse(simpleMatch.group(1)!);
        final month = _monthNameToNumber(simpleMatch.group(2)!);
        final year = int.parse(simpleMatch.group(3)!);

        final parsed = DateTime.utc(year, month, day);
        print('✅ Parsed simple date: $parsed');
        return parsed;
      } catch (e) {
        print('❌ Error parsing simple NHC date: $e');
      }
    }

    print('❌ No date pattern matched');
    return null;
  }

  int _monthNameToNumber(String monthName) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    return months[monthName.toLowerCase()] ?? 1;
  }

  int _getTimezoneOffset(String timezone) {
    // Return hours to ADD to local time to get UTC
    switch (timezone.toUpperCase()) {
      case 'AST': // Atlantic Standard Time
        return 4;
      case 'EST': // Eastern Standard Time
        return 5;
      case 'EDT': // Eastern Daylight Time
        return 4;
      case 'CST': // Central Standard Time
        return 6;
      case 'CDT': // Central Daylight Time
        return 5;
      case 'MST': // Mountain Standard Time
        return 7;
      case 'MDT': // Mountain Daylight Time
        return 6;
      case 'PST': // Pacific Standard Time
        return 8;
      case 'PDT': // Pacific Daylight Time
        return 7;
      case 'GMT':
      case 'UTC':
        return 0;
      default:
        print('⚠️ Unknown timezone: $timezone, assuming UTC');
        return 0;
    }
  }

  String _improveTitle(String title, NewsSource source) {
    String cleanedTitle = _cleanHtml(title);

    if (source.name == 'NHC Advisories') {
      // Improve NHC advisory titles for better clarity
      cleanedTitle = cleanedTitle
          .replaceAll(RegExp(r'^.*?\s*-\s*'),
              '') // Remove prefixes like "AT4/AL042025 -"
          .replaceAll(RegExp(r'\s*\(AT\d+/AL\d+\)'),
              '') // Remove storm codes in parentheses
          .trim();

      // If title contains storm name, make it more readable
      if (cleanedTitle.toLowerCase().contains('dexter')) {
        cleanedTitle = cleanedTitle.replaceAllMapped(
          RegExp(r'(post-tropical cyclone|tropical storm|hurricane)\s+dexter',
              caseSensitive: false),
          (match) => 'Post-Tropical Cyclone Dexter',
        );
      }

      // Improve common advisory types
      cleanedTitle = cleanedTitle
          .replaceAllMapped(
              RegExp(r'public advisory number (\d+)', caseSensitive: false),
              (match) => 'Advisory #${match.group(1)}')
          .replaceAllMapped(
              RegExp(r'forecast discussion number (\d+)', caseSensitive: false),
              (match) => 'Forecast Discussion #${match.group(1)}');
    }

    return cleanedTitle;
  }

  String _improveDescription(String description, NewsSource source) {
    String cleanedDescription = _cleanHtml(description);

    if (source.name == 'NHC Advisories') {
      // Extract key information from NHC descriptions
      // Remove redundant prefixes and improve readability
      cleanedDescription = cleanedDescription
          .replaceAll(
              RegExp(r'\.\.\..*?BECOMES.*?\.\.\.', caseSensitive: false), '')
          .replaceAll(
              RegExp(r'\.\.\.THIS IS THE FINAL.*?\.\.\.', caseSensitive: false),
              'This is the final advisory.')
          .replaceAll(RegExp(r'\.\.\.'), '')
          .trim();

      // If the description is too technical, provide a more user-friendly summary
      if (cleanedDescription.length > 200) {
        final sentences = cleanedDescription.split(RegExp(r'[.!?]+'));
        if (sentences.isNotEmpty) {
          // Take first meaningful sentence
          cleanedDescription = sentences
              .where((s) => s.trim().length > 20)
              .take(2)
              .join('. ')
              .trim();
          if (!cleanedDescription.endsWith('.')) {
            cleanedDescription += '.';
          }
        }
      }
    }

    return cleanedDescription;
  }

  List<NewsSource> getSources() {
    return _sources;
  }

  Future<List<NewsArticle>> fetchRssFeedForSource(NewsSource source) async {
    return await _fetchRssFeed(source);
  }

  Future<List<NewsArticle>> getMockNews() async {
    // Mock data for development/testing
    return [
      NewsArticle(
        title: 'Hurricane Warning Issued for Cayman Islands',
        description:
            'The National Hurricane Center has issued a hurricane warning for the Cayman Islands as Tropical Storm Maria approaches.',
        link: 'https://example.com/article1',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        source: 'Cayman Compass',
        category: 'Weather',
        isHurricaneRelated: true,
      ),
      NewsArticle(
        title: 'Emergency Preparations Underway',
        description:
            'Local authorities are coordinating emergency preparations as residents stock up on essential supplies.',
        link: 'https://example.com/article2',
        publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
        source: 'Loop Cayman',
        category: 'Emergency',
        isHurricaneRelated: true,
      ),
      NewsArticle(
        title: 'NHC Advisory #15 - Tropical Storm Maria',
        description:
            'Latest advisory from the National Hurricane Center regarding Tropical Storm Maria.',
        link: 'https://example.com/article3',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        source: 'NHC Advisories',
        category: 'Advisory',
        isHurricaneRelated: true,
      ),
    ];
  }
}
