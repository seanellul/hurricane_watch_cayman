import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hurricane_watch/providers/checklist_provider.dart';
import 'package:hurricane_watch/models/checklist.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
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
        title: const Text('Emergency Contacts'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          if (checklistProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (checklistProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading contacts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(checklistProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => checklistProvider.loadEmergencyContacts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final emergencyContacts = checklistProvider.emergencyContacts;
          final groupedContacts = _groupContactsByType(emergencyContacts);

          return RefreshIndicator(
            onRefresh: () async {
              checklistProvider.loadEmergencyContacts();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EmergencyBanner(),
                  const SizedBox(height: 24),
                  Text(
                    'Emergency Services',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...groupedContacts.entries.map((entry) => _ContactSection(
                        type: entry.key,
                        contacts: entry.value,
                      )),
                  const SizedBox(height: 24),
                  _ImportantNotesSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, List<EmergencyContact>> _groupContactsByType(
      List<EmergencyContact> contacts) {
    final Map<String, List<EmergencyContact>> grouped = {};

    // Define the order we want to display them
    final typeOrder = [
      'Police',
      'Fire',
      'Hospital',
      'Relief',
      'Government',
      'Other'
    ];

    for (final contact in contacts) {
      final type = contact.type;
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(contact);
    }

    // Sort the groups according to our preferred order
    final sortedGrouped = <String, List<EmergencyContact>>{};
    for (final type in typeOrder) {
      if (grouped.containsKey(type)) {
        sortedGrouped[type] = grouped[type]!;
      }
    }

    // Add any remaining types not in our predefined order
    for (final entry in grouped.entries) {
      if (!typeOrder.contains(entry.key)) {
        sortedGrouped[entry.key] = entry.value;
      }
    }

    return sortedGrouped;
  }
}

class _EmergencyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade700, Colors.red.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emergency,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'In Case of Emergency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dial 911 for immediate life-threatening emergencies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QuickDialButton(
                number: '911',
                label: 'Emergency',
                icon: Icons.phone,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickDialButton extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const _QuickDialButton({
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _makePhoneCall(number),
      icon: Icon(icon),
      label: Text('$label\n$number'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _ContactSection extends StatelessWidget {
  final String type;
  final List<EmergencyContact> contacts;

  const _ContactSection({
    required this.type,
    required this.contacts,
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
              color: _getTypeColor(type).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getTypeIcon(type),
                  color: _getTypeColor(type),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  type,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getTypeColor(type),
                      ),
                ),
              ],
            ),
          ),
          ...contacts.map((contact) => _ContactTile(contact: contact)),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'police':
        return Colors.blue.shade700;
      case 'fire':
        return Colors.red.shade700;
      case 'hospital':
        return Colors.green.shade700;
      case 'relief':
        return Colors.orange.shade700;
      case 'government':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getTypeIcon(String type) {
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
}

class _ContactTile extends StatelessWidget {
  final EmergencyContact contact;

  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTypeColor(contact.type).withOpacity(0.1),
        child: Icon(
          _getTypeIcon(contact.type),
          color: _getTypeColor(contact.type),
        ),
      ),
      title: Text(
        contact.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: contact.description != null ? Text(contact.description!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            contact.phone,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.phone, color: Colors.green.shade600),
            onPressed: () => _makePhoneCall(contact.phone),
            tooltip: 'Call ${contact.name}',
          ),
        ],
      ),
      onTap: () => _showContactDetails(context, contact),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'police':
        return Colors.blue.shade700;
      case 'fire':
        return Colors.red.shade700;
      case 'hospital':
        return Colors.green.shade700;
      case 'relief':
        return Colors.orange.shade700;
      case 'government':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getTypeIcon(String type) {
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

  void _showContactDetails(BuildContext context, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (context) => _ContactDetailsDialog(contact: contact),
    );
  }
}

class _ContactDetailsDialog extends StatelessWidget {
  final EmergencyContact contact;

  const _ContactDetailsDialog({required this.contact});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getTypeIcon(contact.type),
            color: _getTypeColor(contact.type),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(contact.name)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            icon: Icons.category,
            label: 'Type',
            value: contact.type,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.phone,
            label: 'Phone',
            value: contact.phone,
          ),
          if (contact.description != null) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.info,
              label: 'Description',
              value: contact.description!,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            _makePhoneCall(contact.phone);
          },
          icon: const Icon(Icons.phone),
          label: const Text('Call'),
        ),
      ],
    );
  }

  Widget _DetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'police':
        return Colors.blue.shade700;
      case 'fire':
        return Colors.red.shade700;
      case 'hospital':
        return Colors.green.shade700;
      case 'relief':
        return Colors.orange.shade700;
      case 'government':
        return Colors.purple.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _getTypeIcon(String type) {
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

class _ImportantNotesSection extends StatelessWidget {
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
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Important Notes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _NoteItem(
              icon: Icons.warning,
              text: 'Always call 911 for life-threatening emergencies',
              color: Colors.red,
            ),
            _NoteItem(
              icon: Icons.location_on,
              text:
                  'Have your exact location ready when calling emergency services',
              color: Colors.orange,
            ),
            _NoteItem(
              icon: Icons.signal_cellular_4_bar,
              text:
                  'Emergency services are available 24/7 throughout the Cayman Islands',
              color: Colors.green,
            ),
            _NoteItem(
              icon: Icons.language,
              text: 'Emergency services operate in English',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _NoteItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
