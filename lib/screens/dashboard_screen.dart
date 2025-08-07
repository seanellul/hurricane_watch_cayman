import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hurricane_watch/providers/checklist_provider.dart';
import 'package:hurricane_watch/models/checklist.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChecklistProvider>().refresh();
            },
          ),
        ],
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
                  const SizedBox(height: 16),
                  _EmergencyContactsCard(
                      contacts: checklistProvider.emergencyContacts),
                  const SizedBox(height: 16),
                  _HurricaneInfoCard(),
                  const SizedBox(height: 16),
                  if (checklistProvider.householdProfile != null)
                    _ChecklistCard(provider: checklistProvider)
                  else
                    _SetupProfileCard(),
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

class _EmergencyContactsCard extends StatelessWidget {
  final List<EmergencyContact> contacts;

  const _EmergencyContactsCard({required this.contacts});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Contacts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...contacts.map((contact) => _ContactItem(contact: contact)),
          ],
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final EmergencyContact contact;

  const _ContactItem({required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          _getContactIcon(contact.type),
          color: Colors.white,
        ),
      ),
      title: Text(contact.name),
      subtitle: Text(contact.description ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.phone),
        onPressed: () => _makePhoneCall(contact.phone),
      ),
    );
  }

  IconData _getContactIcon(String type) {
    switch (type.toLowerCase()) {
      case 'police':
        return Icons.local_police;
      case 'fire':
        return Icons.local_fire_department;
      case 'hospital':
        return Icons.local_hospital;
      case 'relief':
        return Icons.volunteer_activism;
      case 'government':
        return Icons.account_balance;
      default:
        return Icons.phone;
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _HurricaneInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hurricane Preparedness',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _InfoItem(
              icon: Icons.water_drop,
              title: 'Water',
              description:
                  'Store 1 gallon per person per day for at least 3 days',
            ),
            _InfoItem(
              icon: Icons.restaurant,
              title: 'Food',
              description: 'Non-perishable food for 3 days per person',
            ),
            _InfoItem(
              icon: Icons.flashlight_on,
              title: 'Lighting',
              description: 'Flashlights, batteries, and portable chargers',
            ),
            _InfoItem(
              icon: Icons.medical_services,
              title: 'Medical',
              description: 'First aid kit and 7-day supply of medications',
            ),
            _InfoItem(
              icon: Icons.radio,
              title: 'Communication',
              description: 'Battery-powered radio for emergency updates',
            ),
            _InfoItem(
              icon: Icons.attach_money,
              title: 'Cash',
              description: 'Small bills and coins for emergencies',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Setup Your Household',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a personalized hurricane preparedness checklist based on your household size and needs.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HouseholdSetupScreen(),
                  ),
                );
              },
              child: const Text('Setup Household Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final ChecklistProvider provider;

  const _ChecklistCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your Checklist',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChecklistDetailScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...provider.checklistItems.take(3).map((item) => _ChecklistItemTile(
                  item: item,
                  onChanged: (value) {
                    if (value != null) {
                      provider.updateChecklistItem(item.id, value);
                    }
                  },
                )),
            if (provider.checklistItems.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'And ${provider.checklistItems.length - 3} more items...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool?> onChanged;

  const _ChecklistItemTile({
    required this.item,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: item.isCompleted,
      onChanged: onChanged,
      title: Text(item.name),
      subtitle: Text('${item.quantity} ${item.unit}'),
      secondary: item.isEssential
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Essential',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
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
