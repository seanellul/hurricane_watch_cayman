import 'package:json_annotation/json_annotation.dart';

part 'checklist.g.dart';

@JsonSerializable()
class ChecklistItem {
  final String id;
  final String name;
  final String category;
  final String description;
  final int quantity;
  final String unit;
  final bool isEssential;
  final bool isCompleted;
  final List<VendorItem> vendorItems;

  ChecklistItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.isEssential,
    this.isCompleted = false,
    this.vendorItems = const [],
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemFromJson(json);
  Map<String, dynamic> toJson() => _$ChecklistItemToJson(this);
}

@JsonSerializable()
class VendorItem {
  final String id;
  final String name;
  final String vendor;
  final double price;
  final String currency;
  final String? imageUrl;
  final String? productUrl;
  final bool inStock;
  final String? location;

  VendorItem({
    required this.id,
    required this.name,
    required this.vendor,
    required this.price,
    required this.currency,
    this.imageUrl,
    this.productUrl,
    required this.inStock,
    this.location,
  });

  factory VendorItem.fromJson(Map<String, dynamic> json) =>
      _$VendorItemFromJson(json);
  Map<String, dynamic> toJson() => _$VendorItemToJson(this);
}

@JsonSerializable()
class HouseholdProfile {
  final int adults;
  final int children;
  final int pets;
  final List<String> dietaryRestrictions;
  final bool hasGenerator;
  final bool hasMedicalNeeds;
  final String? specialNeeds;

  HouseholdProfile({
    required this.adults,
    required this.children,
    required this.pets,
    this.dietaryRestrictions = const [],
    this.hasGenerator = false,
    this.hasMedicalNeeds = false,
    this.specialNeeds,
  });

  factory HouseholdProfile.fromJson(Map<String, dynamic> json) =>
      _$HouseholdProfileFromJson(json);
  Map<String, dynamic> toJson() => _$HouseholdProfileToJson(this);
}

@JsonSerializable()
class EmergencyContact {
  final String name;
  final String phone;
  final String type; // Police, Fire, Hospital, etc.
  final String? description;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.type,
    this.description,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactFromJson(json);
  Map<String, dynamic> toJson() => _$EmergencyContactToJson(this);
}
