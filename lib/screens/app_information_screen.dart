import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInformationScreen extends StatelessWidget {
  const AppInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Information'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AppHeaderCard(),
            const SizedBox(height: 24),
            _DeveloperCard(),
            const SizedBox(height: 24),
            _FeaturesList(),
            const SizedBox(height: 24),
            _TechnicalInfoCard(),
            const SizedBox(height: 24),
            _DisclaimerCard(),
            const SizedBox(height: 24),
            _ContactSupportCard(),
          ],
        ),
      ),
    );
  }
}

class _AppHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade600, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.cyclone,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cayman Hurricane Watch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your comprehensive hurricane preparedness companion for the Cayman Islands',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.purple.shade100,
                  child: Icon(
                    Icons.person,
                    size: 36,
                    color: Colors.purple.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About the Developer',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sean Ellul',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'This app was developed with a passion for community safety and hurricane preparedness in the Cayman Islands. As someone who understands the importance of being prepared for natural disasters, I created this app to help residents and visitors stay informed and ready.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DeveloperSkillChip(
                  icon: Icons.phone_android,
                  label: 'Flutter Development',
                ),
                _DeveloperSkillChip(
                  icon: Icons.security,
                  label: 'Emergency Planning',
                ),
                _DeveloperSkillChip(
                  icon: Icons.public,
                  label: 'Community Focus',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launchEmail(),
                    icon: const Icon(Icons.email),
                    label: const Text('Contact Developer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse(
        'mailto:sean@hurricanewatch.ky?subject=Hurricane Watch App Feedback');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _DeveloperSkillChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DeveloperSkillChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.purple.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.purple.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturesList extends StatelessWidget {
  final List<AppFeature> features = [
    AppFeature(
      icon: Icons.checklist,
      title: 'Preparedness Checklist',
      description:
          'Customizable hurricane preparedness checklist based on household size and needs',
    ),
    AppFeature(
      icon: Icons.contact_phone,
      title: 'Emergency Contacts',
      description:
          'Quick access to all essential emergency services in the Cayman Islands',
    ),
    AppFeature(
      icon: Icons.cloud,
      title: 'Live Weather Map',
      description:
          'Real-time hurricane tracking with detailed meteorological information',
    ),
    AppFeature(
      icon: Icons.home,
      title: 'Shelter Information',
      description:
          'Comprehensive details about hurricane shelters including pet-friendly options',
    ),
    AppFeature(
      icon: Icons.link,
      title: 'Quick Links',
      description:
          'Fast access to government websites and preparedness resources',
    ),
    AppFeature(
      icon: Icons.article,
      title: 'News & Updates',
      description:
          'Latest hurricane-related news and official government announcements',
    ),
    AppFeature(
      icon: Icons.cyclone,
      title: 'Hurricane Education',
      description:
          'Learn about hurricane formation and the impact of Saharan dust on Caribbean weather',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...features.map((feature) => _FeatureItem(feature: feature)),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final AppFeature feature;

  const _FeatureItem({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              feature.icon,
              color: Colors.purple.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicalInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _TechnicalInfoRow(
              icon: Icons.phone_android,
              label: 'Framework',
              value: 'Flutter',
            ),
            _TechnicalInfoRow(
              icon: Icons.code,
              label: 'Language',
              value: 'Dart',
            ),
            _TechnicalInfoRow(
              icon: Icons.update,
              label: 'Last Updated',
              value: 'December 2024',
            ),
            _TechnicalInfoRow(
              icon: Icons.security,
              label: 'Data Sources',
              value: 'NOAA, NHC, Cayman Government',
            ),
            _TechnicalInfoRow(
              icon: Icons.devices,
              label: 'Platform',
              value: 'iOS & Android',
            ),
            _TechnicalInfoRow(
              icon: Icons.storage,
              label: 'Data Storage',
              value: 'Local & Cloud Sync',
            ),
          ],
        ),
      ),
    );
  }
}

class _TechnicalInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TechnicalInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.purple.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Important Disclaimer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This app is designed to assist with hurricane preparedness and should not be your only source of emergency information. Always follow official guidance from the Cayman Islands Hazard Management Agency and other authorized sources.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'In case of immediate emergency, dial 911.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSupportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Support & Feedback',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your feedback is valuable and helps improve this app for the entire Cayman Islands community. If you encounter any issues, have suggestions, or would like to report inaccurate information, please get in touch.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchEmail(),
                    icon: const Icon(Icons.email),
                    label: const Text('Send Feedback'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _launchWebsite(),
                    icon: const Icon(Icons.language),
                    label: const Text('Visit Website'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'sean@hurricanewatch.ky',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.language,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'www.hurricanewatch.ky',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse(
        'mailto:sean@hurricanewatch.ky?subject=Hurricane Watch App Feedback');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWebsite() async {
    final uri = Uri.parse('https://www.hurricanewatch.ky');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// Data model for app features
class AppFeature {
  final IconData icon;
  final String title;
  final String description;

  AppFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}
