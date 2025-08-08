import 'package:hurricane_watch/models/checklist.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistService {
  static const String _customItemsKey = 'custom_checklist_items';

  static final List<ChecklistItem> _defaultItems = [
    ChecklistItem(
      id: 'water',
      name: 'Drinking Water',
      category: 'Hydration',
      description:
          '1 gallon per person per day for at least 9 days. Store in clean containers away from toxic materials.',
      quantity: 9,
      unit: 'gallons total for household',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'pet_water',
      name: 'Pet Water',
      category: 'Hydration',
      description: '1/2 gallon per pet per day for at least 9 days',
      quantity: 9,
      unit: 'gallons total for all pets',
      isEssential: true,
    ),
    // EXPANDED FOOD SECTION
    ChecklistItem(
      id: 'canned_proteins',
      name: 'Canned Proteins',
      category: 'Food',
      description:
          'Canned meat, fish, chicken, beans, peanut butter. High protein, long shelf life.',
      quantity: 9,
      unit: 'days worth per person',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'canned_vegetables',
      name: 'Canned Vegetables & Fruits',
      category: 'Food',
      description:
          'Canned corn, green beans, tomatoes, fruit in juice. Provides vitamins and fiber.',
      quantity: 9,
      unit: 'days worth per person',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'grains_starches',
      name: 'Grains & Starches',
      category: 'Food',
      description:
          'Rice, pasta, crackers, cereal, instant oatmeal. Energy-providing carbohydrates.',
      quantity: 9,
      unit: 'days worth per person',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'shelf_stable_milk',
      name: 'Shelf-Stable Milk & Dairy',
      category: 'Food',
      description:
          'Powdered milk, UHT milk, canned evaporated milk for calcium and nutrition.',
      quantity: 9,
      unit: 'days worth per person',
      isEssential: false,
    ),
    ChecklistItem(
      id: 'snacks_comfort_foods',
      name: 'Snacks & Comfort Foods',
      category: 'Food',
      description:
          'Nuts, dried fruit, granola bars, cookies. Boost morale and provide quick energy.',
      quantity: 9,
      unit: 'days worth per person',
      isEssential: false,
    ),
    ChecklistItem(
      id: 'baby_food',
      name: 'Baby Food & Formula',
      category: 'Food',
      description:
          'If applicable: baby formula, baby food, snacks for children.',
      quantity: 9,
      unit: 'days worth per child',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'pet_food',
      name: 'Pet Food',
      category: 'Food',
      description:
          'Dry and/or wet pet food. Don\'t forget treats and any special dietary needs.',
      quantity: 9,
      unit: 'days worth per pet',
      isEssential: true,
    ),
    // TOILETRIES & DISPOSABLES
    ChecklistItem(
      id: 'toilet_paper',
      name: 'Toilet Paper',
      category: 'Toiletries',
      description:
          'Essential sanitation supply. Estimate 1 roll per person per 3 days.',
      quantity: 3,
      unit: 'rolls per person',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'tissues',
      name: 'Tissues & Paper Towels',
      category: 'Toiletries',
      description:
          'For cleaning and hygiene. Paper towels for spills and cleaning.',
      quantity: 2,
      unit: 'boxes per household',
      isEssential: false,
    ),
    ChecklistItem(
      id: 'sanitary_items',
      name: 'Sanitary Items',
      category: 'Toiletries',
      description: 'Feminine hygiene products, adult diapers if needed.',
      quantity: 1,
      unit: 'month supply per person',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'soap_hygiene',
      name: 'Soap & Hygiene Items',
      category: 'Toiletries',
      description: 'Hand soap, body wash, toothbrush, toothpaste, deodorant.',
      quantity: 1,
      unit: 'set per person',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'baby_diapers',
      name: 'Baby Diapers & Wipes',
      category: 'Toiletries',
      description: 'If applicable: diapers, baby wipes, diaper rash cream.',
      quantity: 2,
      unit: 'weeks supply per baby',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'garbage_bags',
      name: 'Garbage Bags & Zip-lock Bags',
      category: 'Toiletries',
      description: 'For waste disposal and keeping items dry. Various sizes.',
      quantity: 2,
      unit: 'boxes per household',
      isEssential: false,
    ),
    // KITCHEN ESSENTIALS
    ChecklistItem(
      id: 'can_opener',
      name: 'Manual Can Opener',
      category: 'Kitchen Essentials',
      description:
          'Essential for opening canned food. Get a sturdy, non-electric model.',
      quantity: 2,
      unit: 'openers per household',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'bottle_opener',
      name: 'Bottle Opener',
      category: 'Kitchen Essentials',
      description: 'For opening bottles and cans without pull-tabs.',
      quantity: 1,
      unit: 'opener per household',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'lighters_matches',
      name: 'Lighters & Waterproof Matches',
      category: 'Kitchen Essentials',
      description:
          'For lighting camp stoves, candles. Store in waterproof container.',
      quantity: 3,
      unit: 'lighters per household',
      isEssential: true,
    ),
    ChecklistItem(
      id: 'disposable_plates',
      name: 'Disposable Plates & Utensils',
      category: 'Kitchen Essentials',
      description:
          'Paper plates, plastic cups, disposable utensils to conserve water.',
      quantity: 1,
      unit: 'package per household',
      isEssential: false,
    ),
    ChecklistItem(
      id: 'sharp_knife',
      name: 'Sharp Knife',
      category: 'Kitchen Essentials',
      description: 'For food preparation. Include a cutting board if possible.',
      quantity: 1,
      unit: 'knife per household',
      isEssential: false,
    ),
    ChecklistItem(
      id: 'aluminum_foil',
      name: 'Aluminum Foil & Plastic Wrap',
      category: 'Kitchen Essentials',
      description: 'For food storage and cooking. Heavy-duty foil preferred.',
      quantity: 1,
      unit: 'roll each per household',
      isEssential: false,
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

  Future<List<ChecklistItem>> generateChecklist(
      HouseholdProfile profile) async {
    final List<ChecklistItem> checklist = [];
    final totalPeople = profile.adults + profile.children;

    for (final item in _defaultItems) {
      int quantity = item.quantity;

      // Adjust quantities based on household profile
      switch (item.id) {
        // WATER CALCULATIONS
        case 'water':
          quantity = totalPeople * 9; // 9 gallons per person total
          break;
        case 'pet_water':
          if (profile.pets > 0) {
            quantity = (profile.pets * 9 * 0.5)
                .round(); // 0.5 gallons per pet per day for 9 days
          } else {
            continue; // Skip if no pets
          }
          break;

        // FOOD CALCULATIONS (per person for 9 days)
        case 'canned_proteins':
        case 'canned_vegetables':
        case 'grains_starches':
        case 'shelf_stable_milk':
        case 'snacks_comfort_foods':
          quantity = totalPeople * 9;
          break;
        case 'baby_food':
          if (profile.children > 0) {
            quantity = profile.children * 9;
          } else {
            continue; // Skip if no children
          }
          break;
        case 'pet_food':
          if (profile.pets > 0) {
            quantity = profile.pets * 9;
          } else {
            continue; // Skip if no pets
          }
          break;

        // TOILETRIES CALCULATIONS
        case 'toilet_paper':
          quantity = totalPeople * 3; // 3 rolls per person
          break;
        case 'sanitary_items':
        case 'soap_hygiene':
          quantity = totalPeople * 1;
          break;
        case 'baby_diapers':
          if (profile.children > 0) {
            quantity = profile.children * 2; // 2 weeks supply per baby
          } else {
            continue; // Skip if no children
          }
          break;

        // COMMUNICATION
        case 'phone_charger':
          quantity = totalPeople; // One per person
          break;
        case 'medications':
          quantity = totalPeople * 7; // 7 days per person
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

    // Load and add custom items
    final customItems = await _loadCustomItems();
    checklist.addAll(customItems);

    return checklist;
  }

  // Methods for persistent custom items
  Future<List<ChecklistItem>> _loadCustomItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customItemsJson = prefs.getStringList(_customItemsKey) ?? [];

      return customItemsJson.map((jsonString) {
        final Map<String, dynamic> json = jsonDecode(jsonString);
        return ChecklistItem.fromJson(json);
      }).toList();
    } catch (e) {
      print('Error loading custom items: $e');
      return [];
    }
  }

  Future<void> addCustomItem(ChecklistItem item) async {
    try {
      final customItems = await _loadCustomItems();
      customItems.add(item);
      await _saveCustomItems(customItems);
    } catch (e) {
      print('Error adding custom item: $e');
    }
  }

  Future<void> removeCustomItem(String itemId) async {
    try {
      final customItems = await _loadCustomItems();
      customItems.removeWhere((item) => item.id == itemId);
      await _saveCustomItems(customItems);
    } catch (e) {
      print('Error removing custom item: $e');
    }
  }

  Future<void> _saveCustomItems(List<ChecklistItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customItemsJson =
          items.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_customItemsKey, customItemsJson);
    } catch (e) {
      print('Error saving custom items: $e');
    }
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
