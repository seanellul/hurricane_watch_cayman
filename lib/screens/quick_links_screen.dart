import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class QuickLinksScreen extends StatefulWidget {
  const QuickLinksScreen({super.key});

  @override
  State<QuickLinksScreen> createState() => _QuickLinksScreenState();
}

class _QuickLinksScreenState extends State<QuickLinksScreen> {
  final List<LinkCategory> _linkCategories = [
    LinkCategory(
      title: 'Government Websites',
      icon: Icons.account_balance,
      color: Colors.blue,
      links: [
        QuickLink(
          title: 'Cayman Islands Government',
          description: 'Official government portal for the Cayman Islands',
          url: 'https://www.gov.ky',
          icon: Icons.language,
        ),
        QuickLink(
          title: 'Hazard Management Cayman Islands',
          description: 'Official emergency management and preparedness',
          url: 'https://www.hazardmanagement.ky',
          icon: Icons.security,
        ),
        QuickLink(
          title: 'Department of Environment',
          description: 'Environmental information and weather updates',
          url: 'https://www.doe.ky',
          icon: Icons.eco,
        ),
        QuickLink(
          title: 'Health Services Authority',
          description: 'Public health information and services',
          url: 'https://www.hsa.ky',
          icon: Icons.local_hospital,
        ),
        QuickLink(
          title: 'Royal Cayman Islands Police',
          description: 'Police services and community safety',
          url: 'https://www.rcips.ky',
          icon: Icons.local_police,
        ),
      ],
    ),
    LinkCategory(
      title: 'Weather & Hurricane Info',
      icon: Icons.cloud,
      color: Colors.orange,
      links: [
        QuickLink(
          title: 'National Hurricane Center',
          description: 'Official hurricane forecasts and warnings',
          url: 'https://www.nhc.noaa.gov',
          icon: Icons.cyclone,
        ),
        QuickLink(
          title: 'Cayman Islands National Weather Service',
          description: 'Local weather forecasts and marine conditions',
          url: 'https://www.weather.gov.ky',
          icon: Icons.wb_sunny,
        ),
        QuickLink(
          title: 'Caribbean Hurricane Network',
          description: 'Caribbean-wide hurricane tracking and news',
          url: 'https://www.stormcarib.com',
          icon: Icons.radar,
        ),
        QuickLink(
          title: 'Weather Underground',
          description: 'Detailed weather conditions and forecasts',
          url: 'https://www.wunderground.com/weather/ky/george-town',
          icon: Icons.thermostat,
        ),
      ],
    ),
    LinkCategory(
      title: 'Preparedness Resources',
      icon: Icons.checklist,
      color: Colors.green,
      links: [
        QuickLink(
          title: 'Ready.gov Hurricane Guide',
          description: 'Comprehensive hurricane preparedness guide',
          url: 'https://www.ready.gov/hurricanes',
          icon: Icons.menu_book,
        ),
        QuickLink(
          title: 'Red Cross Hurricane Safety',
          description: 'Hurricane safety tips and emergency planning',
          url:
              'https://www.redcross.org/get-help/how-to-prepare-for-emergencies/types-of-emergencies/hurricane',
          icon: Icons.healing,
        ),
        QuickLink(
          title: 'FEMA Preparedness',
          description: 'Federal emergency preparedness resources',
          url:
              'https://www.fema.gov/emergency-managers/risk-management/hurricanes',
          icon: Icons.shield,
        ),
        QuickLink(
          title: 'Cayman Compass Weather',
          description: 'Local news and weather updates',
          url: 'https://www.caymancompass.com/weather/',
          icon: Icons.newspaper,
        ),
      ],
    ),
    LinkCategory(
      title: 'Utilities & Services',
      icon: Icons.business,
      color: Colors.purple,
      links: [
        QuickLink(
          title: 'Caribbean Utilities Company',
          description: 'Power outage reports and service updates',
          url: 'https://www.cuc.ky',
          icon: Icons.electrical_services,
        ),
        QuickLink(
          title: 'Water Authority - Cayman',
          description: 'Water service information and advisories',
          url: 'https://www.waterauthority.ky',
          icon: Icons.water_drop,
        ),
        QuickLink(
          title: 'Logic Communications',
          description: 'Internet and telecommunications services',
          url: 'https://www.logic.ky',
          icon: Icons.wifi,
        ),
        QuickLink(
          title: 'Digicel Cayman',
          description: 'Mobile and telecommunications services',
          url: 'https://www.digicelcayman.com',
          icon: Icons.phone,
        ),
      ],
    ),
    LinkCategory(
      title: 'Community & Relief',
      icon: Icons.volunteer_activism,
      color: Colors.red,
      links: [
        QuickLink(
          title: 'Cayman Islands Red Cross',
          description: 'Disaster relief and community support',
          url: 'https://www.redcross.org.ky',
          icon: Icons.favorite,
        ),
        QuickLink(
          title: 'Cayman Islands Crisis Centre',
          description: 'Crisis support and counseling services',
          url: 'https://www.cicc.ky',
          icon: Icons.support,
        ),
        QuickLink(
          title: 'United Way Cayman Islands',
          description: 'Community assistance and volunteer opportunities',
          url: 'https://www.unitedway.ky',
          icon: Icons.handshake,
        ),
        QuickLink(
          title: 'Cayman Islands Chamber of Commerce',
          description: 'Business resources and community information',
          url: 'https://www.caymanchamber.ky',
          icon: Icons.business_center,
        ),
      ],
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _filterCategories();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Links'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _SearchBar(
            onSearchChanged: (query) {
              setState(() {
                _searchQuery = query.toLowerCase();
              });
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Simulate refresh
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return _CategorySection(
                    category: category,
                    searchQuery: _searchQuery,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<LinkCategory> _filterCategories() {
    if (_searchQuery.isEmpty) {
      return _linkCategories;
    }

    return _linkCategories
        .map((category) {
          final filteredLinks = category.links
              .where((link) =>
                  link.title.toLowerCase().contains(_searchQuery) ||
                  link.description.toLowerCase().contains(_searchQuery))
              .toList();

          if (filteredLinks.isNotEmpty) {
            return LinkCategory(
              title: category.title,
              icon: category.icon,
              color: category.color,
              links: filteredLinks,
            );
          }
          return null;
        })
        .where((category) => category != null)
        .cast<LinkCategory>()
        .toList();
  }
}

class _SearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;

  const _SearchBar({required this.onSearchChanged});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search links...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: widget.onSearchChanged,
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final LinkCategory category;
  final String searchQuery;

  const _CategorySection({
    required this.category,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  category.icon,
                  color: category.color,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  category.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: category.color,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: category.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${category.links.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...category.links.map((link) => _LinkTile(
                link: link,
                searchQuery: searchQuery,
              )),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final QuickLink link;
  final String searchQuery;

  const _LinkTile({
    required this.link,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(
          link.icon,
          color: Colors.blue.shade700,
        ),
      ),
      title: _HighlightedText(
        text: link.title,
        highlight: searchQuery,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: _HighlightedText(
        text: link.description,
        highlight: searchQuery,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      trailing: const Icon(Icons.open_in_new),
      onTap: () => _launchUrl(link.url),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle? style;

  const _HighlightedText({
    required this.text,
    required this.highlight,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: style);
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerHighlight = highlight.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerHighlight);

    while (index != -1) {
      // Add text before the highlight
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }

      // Add highlighted text
      spans.add(TextSpan(
        text: text.substring(index, index + highlight.length),
        style: style?.copyWith(
              backgroundColor: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              backgroundColor: Colors.yellow.shade200,
              fontWeight: FontWeight.bold,
            ),
      ));

      start = index + highlight.length;
      index = lowerText.indexOf(lowerHighlight, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

// Data models
class LinkCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<QuickLink> links;

  LinkCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.links,
  });
}

class QuickLink {
  final String title;
  final String description;
  final String url;
  final IconData icon;

  QuickLink({
    required this.title,
    required this.description,
    required this.url,
    required this.icon,
  });
}
