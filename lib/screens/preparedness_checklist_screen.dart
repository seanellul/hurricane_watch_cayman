import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hurricane_watch/providers/checklist_provider.dart';
import 'package:hurricane_watch/models/checklist.dart';

class PreparednessChecklistScreen extends StatefulWidget {
  const PreparednessChecklistScreen({super.key});

  @override
  State<PreparednessChecklistScreen> createState() =>
      _PreparednessChecklistScreenState();
}

class _PreparednessChecklistScreenState
    extends State<PreparednessChecklistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChecklistProvider>();
      if (provider.householdProfile == null) {
        _showSetupDialog();
      }
    });
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const HouseholdSetupDialog(),
    );
  }

  void _editHouseholdSize() {
    showDialog(
      context: context,
      builder: (context) => const HouseholdSetupDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preparedness Checklist'),
        actions: [
          Consumer<ChecklistProvider>(
            builder: (context, provider, child) {
              if (provider.householdProfile != null) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Household Size',
                  onPressed: _editHouseholdSize,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ChecklistProvider>(
        builder: (context, checklistProvider, child) {
          if (checklistProvider.householdProfile == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Setup your household profile first',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              checklistProvider.refresh();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HouseholdInfoCard(
                      profile: checklistProvider.householdProfile!),
                  const SizedBox(height: 16),
                  _PreparednessProgressCard(provider: checklistProvider),
                  const SizedBox(height: 16),
                  _ChecklistSection(provider: checklistProvider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<ChecklistProvider>(
        builder: (context, provider, child) {
          if (provider.householdProfile != null) {
            return FloatingActionButton(
              onPressed: () => _showAddItemDialog(),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddChecklistItemDialog(),
    );
  }
}

class _HouseholdInfoCard extends StatelessWidget {
  final HouseholdProfile profile;

  const _HouseholdInfoCard({required this.profile});

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
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Household Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.person,
                    label: 'Adults',
                    value: '${profile.adults}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.child_care,
                    label: 'Children',
                    value: '${profile.children}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.pets,
                    label: 'Pets',
                    value: '${profile.pets}',
                  ),
                ),
              ],
            ),
            if (profile.dietaryRestrictions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: profile.dietaryRestrictions
                    .map((restriction) => Chip(
                          label: Text(restriction),
                          backgroundColor: Colors.orange.shade100,
                        ))
                    .toList(),
              ),
            ],
            if (profile.hasGenerator || profile.hasMedicalNeeds) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  if (profile.hasGenerator)
                    const Chip(
                      label: Text('Generator Available'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  if (profile.hasMedicalNeeds)
                    const Chip(
                      label: Text('Medical Needs'),
                      backgroundColor: Colors.red,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PreparednessProgressCard extends StatelessWidget {
  final ChecklistProvider provider;

  const _PreparednessProgressCard({required this.provider});

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
              'Preparedness Progress',
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

class _ChecklistSection extends StatelessWidget {
  final ChecklistProvider provider;

  const _ChecklistSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final categories = provider.checklistItems
        .map((item) => item.category)
        .toSet()
        .toList()
      ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Checklist Items',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...categories.map((category) => _CategorySection(
              category: category,
              items: provider.getItemsByCategory(category),
              provider: provider,
            )),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<ChecklistItem> items;
  final ChecklistProvider provider;

  const _CategorySection({
    required this.category,
    required this.items,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = items.where((item) => item.isCompleted).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: _getCategoryIcon(category),
            title: Text(
              category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text('$completedCount / ${items.length} completed'),
            trailing: CircularProgressIndicator(
              value: completedCount / items.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                completedCount == items.length ? Colors.green : Colors.orange,
              ),
            ),
          ),
          ...items.map((item) => _ChecklistItemTile(
                item: item,
                onChanged: (value) {
                  if (value != null) {
                    provider.updateChecklistItem(item.id, value);
                  }
                },
                onTap: () => _showItemDetails(context, item),
              )),
        ],
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color color = Colors.blue;

    switch (category.toLowerCase()) {
      case 'hydration':
        iconData = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'food':
        iconData = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'toiletries':
        iconData = Icons.soap;
        color = Colors.pink;
        break;
      case 'kitchen essentials':
        iconData = Icons.kitchen;
        color = Colors.brown;
        break;
      case 'lighting':
        iconData = Icons.flashlight_on;
        color = Colors.yellow.shade700;
        break;
      case 'power':
        iconData = Icons.battery_charging_full;
        color = Colors.green;
        break;
      case 'medical':
        iconData = Icons.medical_services;
        color = Colors.red;
        break;
      case 'communication':
        iconData = Icons.radio;
        color = Colors.purple;
        break;
      case 'safety':
        iconData = Icons.security;
        color = Colors.indigo;
        break;
      case 'tools':
        iconData = Icons.build;
        color = Colors.deepOrange;
        break;
      case 'personal':
        iconData = Icons.person;
        color = Colors.teal;
        break;
      case 'documents':
        iconData = Icons.folder;
        color = Colors.grey;
        break;
      default:
        iconData = Icons.checklist;
        color = Colors.blue;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(iconData, color: color),
    );
  }

  void _showItemDetails(BuildContext context, ChecklistItem item) {
    showDialog(
      context: context,
      builder: (context) => ChecklistItemDetailsDialog(item: item),
    );
  }
}

class _ChecklistItemTile extends StatelessWidget {
  final ChecklistItem item;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const _ChecklistItemTile({
    required this.item,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCustomItem = item.id.startsWith('custom_');

    return CheckboxListTile(
      value: item.isCompleted,
      onChanged: onChanged,
      title: Text(item.name),
      subtitle: Text('${item.quantity} ${item.unit}'),
      secondary: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.isEssential)
            Container(
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
            ),
          if (isCustomItem)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Custom',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: onTap,
            iconSize: 20,
          ),
          if (isCustomItem)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context),
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Custom Item'),
        content: Text(
            'Are you sure you want to delete "${item.name}" from your checklist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<ChecklistProvider>()
                  .removeCustomChecklistItem(item.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${item.name}" from checklist'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Dialog for setting up household information
class HouseholdSetupDialog extends StatefulWidget {
  const HouseholdSetupDialog({super.key});

  @override
  State<HouseholdSetupDialog> createState() => _HouseholdSetupDialogState();
}

class _HouseholdSetupDialogState extends State<HouseholdSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  int _adults = 2;
  int _children = 0;
  int _pets = 0;
  bool _hasGenerator = false;
  bool _hasMedicalNeeds = false;
  final List<String> _dietaryRestrictions = [];
  final _specialNeedsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Household Setup'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NumberSelector(
                  label: 'Adults',
                  value: _adults,
                  onChanged: (value) => setState(() => _adults = value),
                ),
                const SizedBox(height: 16),
                _NumberSelector(
                  label: 'Children',
                  value: _children,
                  onChanged: (value) => setState(() => _children = value),
                ),
                const SizedBox(height: 16),
                _NumberSelector(
                  label: 'Pets',
                  value: _pets,
                  onChanged: (value) => setState(() => _pets = value),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Has Generator'),
                  value: _hasGenerator,
                  onChanged: (value) =>
                      setState(() => _hasGenerator = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text('Has Medical Needs'),
                  value: _hasMedicalNeeds,
                  onChanged: (value) =>
                      setState(() => _hasMedicalNeeds = value ?? false),
                ),
                if (_hasMedicalNeeds) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _specialNeedsController,
                    decoration: const InputDecoration(
                      labelText: 'Special Medical Needs',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveProfile,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = HouseholdProfile(
        adults: _adults,
        children: _children,
        pets: _pets,
        hasGenerator: _hasGenerator,
        hasMedicalNeeds: _hasMedicalNeeds,
        specialNeeds:
            _hasMedicalNeeds ? _specialNeedsController.text.trim() : null,
        dietaryRestrictions: _dietaryRestrictions,
      );

      context.read<ChecklistProvider>().generateChecklist(profile);
      Navigator.of(context).pop();
    }
  }
}

class _NumberSelector extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _NumberSelector({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: value < 20 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

// Dialog for showing item details
class ChecklistItemDetailsDialog extends StatelessWidget {
  final ChecklistItem item;

  const ChecklistItemDetailsDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(item.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(item.description),
            const SizedBox(height: 16),
            Text(
              'Quantity Required',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('${item.quantity} ${item.unit}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  item.isEssential ? Icons.warning : Icons.info,
                  color: item.isEssential ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  item.isEssential ? 'Essential Item' : 'Recommended Item',
                  style: TextStyle(
                    color: item.isEssential ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (item.vendorItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Where to Buy',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...item.vendorItems.take(3).map((vendor) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(vendor.name),
                    subtitle: Text(
                        '${vendor.vendor} - ${vendor.currency} ${vendor.price.toStringAsFixed(2)}'),
                    trailing: vendor.inStock
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.red),
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// Dialog for adding custom checklist items
class AddChecklistItemDialog extends StatefulWidget {
  const AddChecklistItemDialog({super.key});

  @override
  State<AddChecklistItemDialog> createState() => _AddChecklistItemDialogState();
}

class _AddChecklistItemDialogState extends State<AddChecklistItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  String _selectedCategory = 'Personal';
  bool _isEssential = false;

  final List<String> _categories = [
    'Hydration',
    'Food',
    'Toiletries',
    'Kitchen Essentials',
    'Lighting',
    'Power',
    'Medical',
    'Communication',
    'Safety',
    'Tools',
    'Personal',
    'Documents',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Item'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty == true ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Required';
                          if (int.tryParse(value!) == null)
                            return 'Invalid number';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Please enter a unit'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Essential Item'),
                  value: _isEssential,
                  onChanged: (value) =>
                      setState(() => _isEssential = value ?? false),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addItem,
          child: const Text('Add Item'),
        ),
      ],
    );
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      final customItem = ChecklistItem(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim().isEmpty
            ? 'Custom item added by user'
            : _descriptionController.text.trim(),
        quantity: int.parse(_quantityController.text),
        unit: _unitController.text.trim(),
        isEssential: _isEssential,
        vendorItems: [],
      );

      context.read<ChecklistProvider>().addCustomChecklistItem(customItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${customItem.name}" to your checklist'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
