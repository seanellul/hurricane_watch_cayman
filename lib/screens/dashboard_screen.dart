import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hurricane_watch/providers/checklist_provider.dart';
import 'package:hurricane_watch/screens/preparedness_checklist_screen.dart';
import 'package:hurricane_watch/screens/emergency_contacts_screen.dart';
import 'package:hurricane_watch/screens/quick_links_screen.dart';
import 'package:hurricane_watch/screens/shelter_information_screen.dart';
import 'package:hurricane_watch/screens/app_information_screen.dart';
import 'package:hurricane_watch/screens/hurricane_info_screen.dart';

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
                  _PreparednessOverview(provider: checklistProvider),
                  const SizedBox(height: 24),
                  _DashboardQuickActions(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
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
