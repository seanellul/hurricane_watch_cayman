import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hurricane_watch/utils/theme.dart';

class AppInformationScreen extends StatelessWidget {
  const AppInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Credits'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderSection(),
            SizedBox(height: 16),
            _AboutProjectCard(),
            _OpenSourceCard(),
            _FeaturesCard(),
            _DataSourcesCard(),
            _DisclaimerCard(),
            _SupportCard(),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.navy, AppTheme.stormCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.cyclone, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cayman Hurricane Watch',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Community‑built, open‑source hurricane preparedness for the Cayman Islands.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.95),
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _PillTag(label: 'Open Source'),
              _PillTag(label: 'No Ads'),
              _PillTag(label: 'Community Supported'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  final String label;
  const _PillTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AboutProjectCard extends StatelessWidget {
  const _AboutProjectCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About this project',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Cayman Hurricane Watch began as a simple tool for family and friends to receive timely regional weather updates. It\'s a community effort — built locally in the Cayman Islands — and it\'s not an official source of emergency guidance.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'re not preparedness experts. The goal is to make accurate information easier to reach and to encourage good preparedness habits.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenSourceCard extends StatelessWidget {
  const _OpenSourceCard();

  static final Uri _repoUrl =
      Uri.parse('https://github.com/seanellul/hurricane_watch_cayman');
  static final Uri _issuesUrl =
      Uri.parse('https://github.com/seanellul/hurricane_watch_cayman/issues');

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
                const Icon(Icons.code, color: AppTheme.navy),
                const SizedBox(width: 8),
                Text('Open Source',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This app is open source. You can browse the code, report issues, and contribute improvements. New contributors are welcome — even small fixes help.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launch(_repoUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('View source on GitHub'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launch(_issuesUrl),
                    icon: const Icon(Icons.bug_report_outlined),
                    label: const Text('Report an issue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FeaturesCard extends StatelessWidget {
  const _FeaturesCard();

  @override
  Widget build(BuildContext context) {
    final List<_Feature> features = const [
      _Feature(Icons.checklist, 'Preparedness checklist',
          'Customizable items based on your household.'),
      _Feature(Icons.contact_phone, 'Emergency contacts',
          'Quick access to essential services in Cayman.'),
      _Feature(Icons.map, 'Live map', 'Storm tracks and local context.'),
      _Feature(Icons.home, 'Shelter information',
          'Locations and notes including pet policies.'),
      _Feature(Icons.link, 'Quick links',
          'Trusted resources collected in one place.'),
      _Feature(Icons.article, 'News & advisories',
          'Local coverage and NHC updates.'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What\'s inside',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...features.map((f) => _FeatureTile(feature: f)).toList(),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  const _FeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.stormCyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check, color: AppTheme.navy, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(feature.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey.shade700)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Feature {
  final IconData icon; // Reserved for potential future use
  final String title;
  final String description;
  const _Feature(this.icon, this.title, this.description);
}

class _DataSourcesCard extends StatelessWidget {
  const _DataSourcesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data sources & acknowledgements',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _LinkTile(
              icon: Icons.public,
              label: 'NOAA / National Hurricane Center (NHC)',
              url: 'https://www.nhc.noaa.gov',
            ),
            _LinkTile(
              icon: Icons.gps_fixed,
              label: 'Open-Meteo (weather data)',
              url: 'https://open-meteo.com',
            ),
            _LinkTile(
              icon: Icons.account_balance,
              label: 'Cayman Islands Government resources',
              url: 'https://www.gov.ky',
            ),
            _LinkTile(
              icon: Icons.map,
              label: 'OpenStreetMap contributors',
              url: 'https://www.openstreetmap.org',
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  const _LinkTile({required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.navy),
            const SizedBox(width: 12),
            Expanded(
                child:
                    Text(label, style: Theme.of(context).textTheme.bodyMedium)),
            const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.alertOrange.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.alertOrange.withOpacity(0.35)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppTheme.alertOrange),
                const SizedBox(width: 8),
                Text('Important disclaimer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.alertOrange)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This app is for information and preparedness support only. Always follow official guidance from Hazard Management Cayman Islands and other authorized agencies.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'If you are in immediate danger or need help, dial 911.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: Colors.red.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  static final Uri _email = Uri.parse(
      'mailto:sean@hurricanewatch.ky?subject=Hurricane%20Watch%20Feedback');
  static final Uri _website = Uri.parse('https://www.hurricanewatch.ky');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Support & feedback',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Ideas, corrections, and bug reports make this better for everyone in Cayman. Thank you for helping improve it.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _launch(_email),
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email feedback'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launch(_website),
                    icon: const Icon(Icons.language),
                    label: const Text('Project website'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
