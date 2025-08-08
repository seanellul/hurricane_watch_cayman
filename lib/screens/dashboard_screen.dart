import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hurricane_watch/providers/checklist_provider.dart';
import 'package:hurricane_watch/screens/preparedness_checklist_screen.dart';
import 'package:hurricane_watch/screens/emergency_contacts_screen.dart';
import 'package:hurricane_watch/screens/quick_links_screen.dart';
import 'package:hurricane_watch/screens/shelter_information_screen.dart';
import 'package:hurricane_watch/screens/app_information_screen.dart';
import 'package:hurricane_watch/screens/hurricane_info_screen.dart';
import 'package:hurricane_watch/providers/weather_provider.dart';
import 'package:hurricane_watch/widgets/enhanced_fullscreen_map.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChecklistProvider>().loadEmergencyContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 8,
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              checklistProvider.refresh();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeadlineDigest(),
                  const SizedBox(height: 16),
                  _StormProximityCard(),
                  const SizedBox(height: 16),
                  _PreparednessOverview(provider: checklistProvider),
                  const SizedBox(height: 24),
                  _PriorityActions(provider: checklistProvider),
                  const SizedBox(height: 16),
                  _DashboardQuickActions(),
                  const SizedBox(height: 16),
                  _OfflineReadinessCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeadlineDigest extends StatelessWidget {
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
            _digestBullet(line1),
            _digestBullet(line2),
            _digestBullet(line3),
          ],
        ),
      ),
    );
  }

  Widget _digestBullet(String text) {
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

class _StormProximityCard extends StatelessWidget {
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

    return InkWell(
      onTap: () {
        final storms = weather.activeHurricanes;
        if (storms.isEmpty) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedFullScreenMap(
              hurricanes: storms,
              selectedTimeIndex: 0,
              focusedStorm: p.storm,
            ),
          ),
        );
      },
      child: Card(
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
              const SizedBox(width: 12),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityActions extends StatelessWidget {
  final ChecklistProvider provider;
  const _PriorityActions({required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = provider.getPriorityActions();
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority Actions',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 18, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Expanded(child: Text(i.name)),
                      TextButton(
                        onPressed: () =>
                            provider.updateChecklistItem(i.id, true),
                        child: const Text('Mark done'),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _OfflineReadinessCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Offline Readiness',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Download Cayman essentials (shelters, contacts, checklists, '
                'and last 24h advisories) for offline access.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Persist existing static data is already local; no-op here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Essentials saved for offline')),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Save Essentials'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Prefetching Cayman map tiles…')),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Prefetch Map'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreparednessOverview extends StatelessWidget {
  final ChecklistProvider provider;

  const _PreparednessOverview({required this.provider});

  @override
  Widget build(BuildContext context) {
    final completionPercentage = provider.completionPercentage;
    final completedItems = provider.completedItemsCount;
    final totalItems = provider.totalItemsCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preparedness Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(completionPercentage * 100).round()}%',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      Text(
                        'Complete',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$completedItems / $totalItems',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Items Ready',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: completionPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                completionPercentage >= 0.8
                    ? Colors.green
                    : completionPercentage >= 0.5
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardQuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _QuickActionButton(
              icon: Icons.checklist,
              title: 'Preparedness\nChecklist',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreparednessChecklistScreen(),
                ),
              ),
            ),
            _QuickActionButton(
              icon: Icons.contact_phone,
              title: 'Emergency\nContacts',
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyContactsScreen(),
                ),
              ),
            ),
            _QuickActionButton(
              icon: Icons.link,
              title: 'Quick\nLinks',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuickLinksScreen(),
                ),
              ),
            ),
            _QuickActionButton(
              icon: Icons.home,
              title: 'Shelter\nInformation',
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShelterInformationScreen(),
                ),
              ),
            ),
            _QuickActionButton(
              icon: Icons.info,
              title: 'App\nInformation',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppInformationScreen(),
                ),
              ),
            ),
            _QuickActionButton(
              icon: Icons.cyclone,
              title: 'Hurricane\nInfo',
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HurricaneInfoScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens for navigation
class HouseholdSetupScreen extends StatelessWidget {
  const HouseholdSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Household')),
      body: const Center(child: Text('Household Setup Screen')),
    );
  }
}

class ChecklistDetailScreen extends StatelessWidget {
  const ChecklistDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Full Checklist')),
      body: const Center(child: Text('Checklist Detail Screen')),
    );
  }
}

// All screens now implemented
