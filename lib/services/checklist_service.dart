import 'package:hurricane_watch/models/checklist.dart';

class ChecklistService {
  static final List<ChecklistItem> _defaultItems = [
    ChecklistItem(
      id: 'water',
      name: 'Bottled Water',
      category: 'Hydration',
      description: '1 gallon per person per day for at least 3 days',
      quantity: 1,
      unit: 'gallon per person per day',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'non_perishable_food',
      name: 'Non-perishable Food',
      category: 'Food',
      description: 'Canned goods, dry foods, energy bars',
      quantity: 3,
      unit: 'days worth per person',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'flashlight',
      name: 'Flashlight',
      category: 'Lighting',
      description: 'Battery-powered or hand-crank flashlight',
      quantity: 1,
      unit: 'per household',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'batteries',
      name: 'Batteries',
      category: 'Power',
      description: 'Extra batteries for all devices',
      quantity: 1,
      unit: 'pack per device',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'first_aid',
      name: 'First Aid Kit',
      category: 'Medical',
      description: 'Basic first aid supplies',
      quantity: 1,
      unit: 'kit per household',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'medications',
      name: 'Prescription Medications',
      category: 'Medical',
      description: '7-day supply of all medications',
      quantity: 7,
      unit: 'days per person',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'radio',
      name: 'Battery-powered Radio',
      category: 'Communication',
      description: 'NOAA weather radio or battery-powered radio',
      quantity: 1,
      unit: 'per household',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'phone_charger',
      name: 'Phone Charger',
      category: 'Communication',
      description: 'Portable charger or car charger',
      quantity: 1,
      unit: 'per phone',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'cash',
      name: 'Cash',
      category: 'Financial',
      description: 'Small bills and coins',
      quantity: 100,
      unit: 'dollars per household',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'important_documents',
      name: 'Important Documents',
      category: 'Documents',
      description: 'Insurance, ID, medical records in waterproof container',
      quantity: 1,
      unit: 'set per household',
      isEssential: true,
    ),
  ];

  static final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Cayman Islands Police',
      phone: '+1-345-949-4222',
      type: 'Police',
      description: 'Emergency police services',
    ),
    EmergencyContact(
      name: 'Cayman Islands Fire Service',
      phone: '+1-345-949-2276',
      type: 'Fire',
      description: 'Emergency fire services',
    ),
    EmergencyContact(
      name: 'Cayman Islands Hospital',
      phone: '+1-345-949-8600',
      type: 'Hospital',
      description: 'Emergency medical services',
    ),
    EmergencyContact(
      name: 'Cayman Islands Red Cross',
      phone: '+1-345-949-6785',
      type: 'Relief',
      description: 'Disaster relief services',
    ),
    EmergencyContact(
      name: 'Cayman Islands Government',
      phone: '+1-345-949-7900',
      type: 'Government',
      description: 'Government emergency information',
    ),
  ];

  static final List<VendorItem> _vendorItems = [
    VendorItem(
      id: 'water_1',
      name: 'Bottled Water 24-pack',
      vendor: 'Foster\'s Food Fair',
      price: 12.99,
      currency: 'KYD',
      inStock: true,
      location: 'Grand Cayman',
    ),
    VendorItem(
      id: 'water_2',
      name: 'Bottled Water 24-pack',
      vendor: 'Kirk Market',
      price: 11.99,
      currency: 'KYD',
      inStock: true,
      location: 'Grand Cayman',
    ),
    VendorItem(
      id: 'flashlight_1',
      name: 'LED Flashlight',
      vendor: 'A.L. Thompson',
      price: 15.99,
      currency: 'KYD',
      inStock: true,
      location: 'Grand Cayman',
    ),
    VendorItem(
      id: 'batteries_1',
      name: 'AA Batteries 8-pack',
      vendor: 'Foster\'s Food Fair',
      price: 8.99,
      currency: 'KYD',
      inStock: true,
      location: 'Grand Cayman',
    ),
    VendorItem(
      id: 'first_aid_1',
      name: 'First Aid Kit',
      vendor: 'A.L. Thompson',
      price: 25.99,
      currency: 'KYD',
      inStock: true,
      location: 'Grand Cayman',
    ),
  ];

  List<ChecklistItem> generateChecklist(HouseholdProfile profile) {
    final List<ChecklistItem> checklist = [];

    for (final item in _defaultItems) {
      int quantity = item.quantity;

      // Adjust quantities based on household profile
      switch (item.id) {
        case 'water':
          quantity = (profile.adults + profile.children) * item.quantity;
          break;
        case 'non_perishable_food':
          quantity = (profile.adults + profile.children) * item.quantity;
          break;
        case 'medications':
          quantity = (profile.adults + profile.children) * item.quantity;
          break;
        case 'phone_charger':
          quantity = (profile.adults + profile.children);
          break;
      }

      // Add vendor items for this checklist item
      final vendorItems = _vendorItems
          .where((vendor) =>
              vendor.name.toLowerCase().contains(item.name.toLowerCase()))
          .toList();

      checklist.add(ChecklistItem(
        id: item.id,
        name: item.name,
        category: item.category,
        description: item.description,
        quantity: quantity,
        unit: item.unit,
        isEssential: item.isEssential,
        vendorItems: vendorItems,
      ));
    }

    return checklist;
  }

  List<EmergencyContact> getEmergencyContacts() {
    return _emergencyContacts;
  }

  List<VendorItem> getVendorItems() {
    return _vendorItems;
  }

  List<VendorItem> searchVendorItems(String query) {
    return _vendorItems
        .where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()) ||
            item.vendor.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void updateChecklistItem(String itemId, bool isCompleted) {
    // This would typically update a database or state management
    // For now, we'll just print the update
    print('Updated item $itemId to completed: $isCompleted');
  }
}
