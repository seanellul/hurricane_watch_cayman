// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChecklistItem _$ChecklistItemFromJson(Map<String, dynamic> json) =>
    ChecklistItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unit: json['unit'] as String,
      isEssential: json['isEssential'] as bool,
      isCompleted: json['isCompleted'] as bool? ?? false,
      vendorItems: (json['vendorItems'] as List<dynamic>?)
              ?.map((e) => VendorItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ChecklistItemToJson(ChecklistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'description': instance.description,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'isEssential': instance.isEssential,
      'isCompleted': instance.isCompleted,
      'vendorItems': instance.vendorItems,
    };

VendorItem _$VendorItemFromJson(Map<String, dynamic> json) => VendorItem(
      id: json['id'] as String,
      name: json['name'] as String,
      vendor: json['vendor'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      imageUrl: json['imageUrl'] as String?,
      productUrl: json['productUrl'] as String?,
      inStock: json['inStock'] as bool,
      location: json['location'] as String?,
    );

Map<String, dynamic> _$VendorItemToJson(VendorItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'vendor': instance.vendor,
      'price': instance.price,
      'currency': instance.currency,
      'imageUrl': instance.imageUrl,
      'productUrl': instance.productUrl,
      'inStock': instance.inStock,
      'location': instance.location,
    };

HouseholdProfile _$HouseholdProfileFromJson(Map<String, dynamic> json) =>
    HouseholdProfile(
      adults: (json['adults'] as num).toInt(),
      children: (json['children'] as num).toInt(),
      pets: (json['pets'] as num).toInt(),
      dietaryRestrictions: (json['dietaryRestrictions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      hasGenerator: json['hasGenerator'] as bool? ?? false,
      hasMedicalNeeds: json['hasMedicalNeeds'] as bool? ?? false,
      specialNeeds: json['specialNeeds'] as String?,
    );

Map<String, dynamic> _$HouseholdProfileToJson(HouseholdProfile instance) =>
    <String, dynamic>{
      'adults': instance.adults,
      'children': instance.children,
      'pets': instance.pets,
      'dietaryRestrictions': instance.dietaryRestrictions,
      'hasGenerator': instance.hasGenerator,
      'hasMedicalNeeds': instance.hasMedicalNeeds,
      'specialNeeds': instance.specialNeeds,
    };

EmergencyContact _$EmergencyContactFromJson(Map<String, dynamic> json) =>
    EmergencyContact(
      name: json['name'] as String,
      phone: json['phone'] as String,
      type: json['type'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$EmergencyContactToJson(EmergencyContact instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'type': instance.type,
      'description': instance.description,
    };
