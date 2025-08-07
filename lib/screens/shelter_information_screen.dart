import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShelterInformationScreen extends StatefulWidget {
  const ShelterInformationScreen({super.key});

  @override
  State<ShelterInformationScreen> createState() =>
      _ShelterInformationScreenState();
}

class _ShelterInformationScreenState extends State<ShelterInformationScreen> {
  final List<HurricaneShelter> _shelters = [
    HurricaneShelter(
      name: 'John Gray High School',
      address: 'P.O. Box 30637, Grand Cayman KY1-1203',
      district: 'George Town',
      capacity: 300,
      isPetFriendly: false,
      hasGenerator: true,
      hasKitchen: true,
      hasNursery: true,
      accessibility: ['Wheelchair accessible', 'Accessible restrooms'],
      amenities: [
        'Cafeteria',
        'Gymnasium',
        'Multiple classrooms',
        'Air conditioning'
      ],
      contactPhone: '345-949-9006',
      coordinates: {'lat': 19.3026, 'lng': -81.3857},
      specialNotes:
          'Main evacuation center for George Town area. Medical personnel on-site during emergencies.',
    ),
    HurricaneShelter(
      name: 'Clifton Hunter High School',
      address: 'Frank Sound Road, North Side',
      district: 'North Side',
      capacity: 250,
      isPetFriendly: false,
      hasGenerator: true,
      hasKitchen: true,
      hasNursery: false,
      accessibility: ['Wheelchair accessible'],
      amenities: ['Cafeteria', 'Multiple classrooms', 'Sports facilities'],
      contactPhone: '345-947-1111',
      coordinates: {'lat': 19.3500, 'lng': -81.2000},
      specialNotes: 'Serves eastern districts of Grand Cayman.',
    ),
    HurricaneShelter(
      name: 'West Bay Primary School',
      address: 'West Bay Road, West Bay',
      district: 'West Bay',
      capacity: 150,
      isPetFriendly: true,
      hasGenerator: true,
      hasKitchen: false,
      hasNursery: true,
      accessibility: ['Limited accessibility'],
      amenities: ['Multiple classrooms', 'Playground area'],
      contactPhone: '345-949-3233',
      coordinates: {'lat': 19.3667, 'lng': -81.4167},
      specialNotes: 'Pet-friendly shelter with designated pet areas.',
    ),
    HurricaneShelter(
      name: 'Bodden Town Primary School',
      address: 'Bodden Town Road, Bodden Town',
      district: 'Bodden Town',
      capacity: 100,
      isPetFriendly: false,
      hasGenerator: false,
      hasKitchen: false,
      hasNursery: false,
      accessibility: ['Basic accessibility'],
      amenities: ['Classrooms', 'Assembly hall'],
      contactPhone: '345-947-2394',
      coordinates: {'lat': 19.2833, 'lng': -81.2500},
      specialNotes: 'Backup shelter for Bodden Town district.',
    ),
    HurricaneShelter(
      name: 'East End Primary School',
      address: 'Gun Bay, East End',
      district: 'East End',
      capacity: 75,
      isPetFriendly: true,
      hasGenerator: true,
      hasKitchen: false,
      hasNursery: false,
      accessibility: ['Basic accessibility'],
      amenities: ['Classrooms', 'Community room'],
      contactPhone: '345-947-7519',
      coordinates: {'lat': 19.3333, 'lng': -81.1000},
      specialNotes: 'Serves the easternmost communities of Grand Cayman.',
    ),
    HurricaneShelter(
      name: 'Cayman Brac High School',
      address: 'West End, Cayman Brac',
      district: 'Cayman Brac',
      capacity: 200,
      isPetFriendly: true,
      hasGenerator: true,
      hasKitchen: true,
      hasNursery: true,
      accessibility: ['Wheelchair accessible', 'Accessible restrooms'],
      amenities: ['Cafeteria', 'Gymnasium', 'Library', 'Science labs'],
      contactPhone: '345-948-2223',
      coordinates: {'lat': 19.7500, 'lng': -79.8833},
      specialNotes:
          'Primary shelter for Cayman Brac. Strong concrete construction.',
    ),
    HurricaneShelter(
      name: 'Little Cayman Community Centre',
      address: 'Blossom Village, Little Cayman',
      district: 'Little Cayman',
      capacity: 50,
      isPetFriendly: true,
      hasGenerator: true,
      hasKitchen: true,
      hasNursery: false,
      accessibility: ['Wheelchair accessible'],
      amenities: ['Community hall', 'Kitchen facilities', 'Meeting rooms'],
      contactPhone: '345-948-1033',
      coordinates: {'lat': 19.7000, 'lng': -80.0833},
      specialNotes:
          'Only shelter on Little Cayman. Serves entire island population.',
    ),
  ];

  String _selectedDistrict = 'All';
  bool _showPetFriendlyOnly = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredShelters = _getFilteredShelters();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hurricane Shelters'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _ShelterSummaryCard(
            totalShelters: _shelters.length,
            petFriendlyShelters: _shelters.where((s) => s.isPetFriendly).length,
            totalCapacity:
                _shelters.fold(0, (sum, shelter) => sum + shelter.capacity),
          ),
          _SearchAndFiltersBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: filteredShelters.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredShelters.length,
                      itemBuilder: (context, index) {
                        final shelter = filteredShelters[index];
                        return _ShelterCard(shelter: shelter);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<HurricaneShelter> _getFilteredShelters() {
    return _shelters.where((shelter) {
      final matchesDistrict =
          _selectedDistrict == 'All' || shelter.district == _selectedDistrict;
      final matchesPetFriendly = !_showPetFriendlyOnly || shelter.isPetFriendly;
      final matchesSearch = _searchQuery.isEmpty ||
          shelter.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          shelter.district.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesDistrict && matchesPetFriendly && matchesSearch;
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedDistrict: _selectedDistrict,
        showPetFriendlyOnly: _showPetFriendlyOnly,
        onFiltersChanged: (district, petFriendly) {
          setState(() {
            _selectedDistrict = district;
            _showPetFriendlyOnly = petFriendly;
          });
        },
      ),
    );
  }

  Widget _SearchAndFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search shelters...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          if (_selectedDistrict != 'All' || _showPetFriendlyOnly) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                if (_selectedDistrict != 'All')
                  Chip(
                    label: Text('District: $_selectedDistrict'),
                    onDeleted: () => setState(() => _selectedDistrict = 'All'),
                  ),
                if (_showPetFriendlyOnly)
                  Chip(
                    label: const Text('Pet Friendly'),
                    onDeleted: () =>
                        setState(() => _showPetFriendlyOnly = false),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _EmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No shelters found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
}

class _ShelterSummaryCard extends StatelessWidget {
  final int totalShelters;
  final int petFriendlyShelters;
  final int totalCapacity;

  const _ShelterSummaryCard({
    required this.totalShelters,
    required this.petFriendlyShelters,
    required this.totalCapacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade600, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.home,
              value: totalShelters.toString(),
              label: 'Total\nShelters',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.pets,
              value: petFriendlyShelters.toString(),
              label: 'Pet\nFriendly',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _SummaryItem(
              icon: Icons.people,
              value: totalCapacity.toString(),
              label: 'Total\nCapacity',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ShelterCard extends StatelessWidget {
  final HurricaneShelter shelter;

  const _ShelterCard({required this.shelter});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: Icon(
                Icons.home,
                color: Colors.orange.shade700,
              ),
            ),
            title: Text(
              shelter.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:
                Text('${shelter.district} • Capacity: ${shelter.capacity}'),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showShelterDetails(context, shelter),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              shelter.address,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (shelter.isPetFriendly)
                  _FeatureChip(
                    icon: Icons.pets,
                    label: 'Pet Friendly',
                    color: Colors.green,
                  ),
                if (shelter.hasGenerator)
                  _FeatureChip(
                    icon: Icons.electrical_services,
                    label: 'Generator',
                    color: Colors.blue,
                  ),
                if (shelter.hasKitchen)
                  _FeatureChip(
                    icon: Icons.restaurant,
                    label: 'Kitchen',
                    color: Colors.orange,
                  ),
                if (shelter.hasNursery)
                  _FeatureChip(
                    icon: Icons.child_care,
                    label: 'Nursery',
                    color: Colors.purple,
                  ),
              ],
            ),
          ),
          ButtonBar(
            children: [
              TextButton.icon(
                onPressed: () => _makePhoneCall(shelter.contactPhone),
                icon: const Icon(Icons.phone),
                label: const Text('Call'),
              ),
              TextButton.icon(
                onPressed: () => _openMaps(shelter.coordinates),
                icon: const Icon(Icons.directions),
                label: const Text('Directions'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showShelterDetails(BuildContext context, HurricaneShelter shelter) {
    showDialog(
      context: context,
      builder: (context) => _ShelterDetailsDialog(shelter: shelter),
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMaps(Map<String, double> coordinates) async {
    final lat = coordinates['lat'];
    final lng = coordinates['lng'];
    final uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDialog extends StatefulWidget {
  final String selectedDistrict;
  final bool showPetFriendlyOnly;
  final Function(String, bool) onFiltersChanged;

  const _FilterDialog({
    required this.selectedDistrict,
    required this.showPetFriendlyOnly,
    required this.onFiltersChanged,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String _selectedDistrict;
  late bool _showPetFriendlyOnly;

  final List<String> _districts = [
    'All',
    'George Town',
    'West Bay',
    'Bodden Town',
    'North Side',
    'East End',
    'Cayman Brac',
    'Little Cayman',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDistrict = widget.selectedDistrict;
    _showPetFriendlyOnly = widget.showPetFriendlyOnly;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Shelters'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'District',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedDistrict,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: _districts
                .map((district) => DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Pet Friendly Only'),
            value: _showPetFriendlyOnly,
            onChanged: (value) {
              setState(() {
                _showPetFriendlyOnly = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedDistrict = 'All';
              _showPetFriendlyOnly = false;
            });
          },
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onFiltersChanged(_selectedDistrict, _showPetFriendlyOnly);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _ShelterDetailsDialog extends StatelessWidget {
  final HurricaneShelter shelter;

  const _ShelterDetailsDialog({required this.shelter});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(shelter.name),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailSection(
                title: 'Location',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shelter.address),
                    Text('District: ${shelter.district}'),
                  ],
                ),
              ),
              _DetailSection(
                title: 'Capacity & Features',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Maximum Capacity: ${shelter.capacity} people'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (shelter.isPetFriendly)
                          _FeatureChip(
                            icon: Icons.pets,
                            label: 'Pet Friendly',
                            color: Colors.green,
                          ),
                        if (shelter.hasGenerator)
                          _FeatureChip(
                            icon: Icons.electrical_services,
                            label: 'Generator',
                            color: Colors.blue,
                          ),
                        if (shelter.hasKitchen)
                          _FeatureChip(
                            icon: Icons.restaurant,
                            label: 'Kitchen',
                            color: Colors.orange,
                          ),
                        if (shelter.hasNursery)
                          _FeatureChip(
                            icon: Icons.child_care,
                            label: 'Nursery',
                            color: Colors.purple,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (shelter.accessibility.isNotEmpty)
                _DetailSection(
                  title: 'Accessibility',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: shelter.accessibility
                        .map((item) => Text('• $item'))
                        .toList(),
                  ),
                ),
              if (shelter.amenities.isNotEmpty)
                _DetailSection(
                  title: 'Amenities',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: shelter.amenities
                        .map((item) => Text('• $item'))
                        .toList(),
                  ),
                ),
              if (shelter.specialNotes.isNotEmpty)
                _DetailSection(
                  title: 'Special Notes',
                  content: Text(shelter.specialNotes),
                ),
              _DetailSection(
                title: 'Contact',
                content: Text('Phone: ${shelter.contactPhone}'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            _makePhoneCall(shelter.contactPhone);
          },
          icon: const Icon(Icons.phone),
          label: const Text('Call'),
        ),
      ],
    );
  }

  Widget _DetailSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        content,
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

// Data model for hurricane shelters
class HurricaneShelter {
  final String name;
  final String address;
  final String district;
  final int capacity;
  final bool isPetFriendly;
  final bool hasGenerator;
  final bool hasKitchen;
  final bool hasNursery;
  final List<String> accessibility;
  final List<String> amenities;
  final String contactPhone;
  final Map<String, double> coordinates;
  final String specialNotes;

  HurricaneShelter({
    required this.name,
    required this.address,
    required this.district,
    required this.capacity,
    required this.isPetFriendly,
    required this.hasGenerator,
    required this.hasKitchen,
    required this.hasNursery,
    required this.accessibility,
    required this.amenities,
    required this.contactPhone,
    required this.coordinates,
    required this.specialNotes,
  });
}
