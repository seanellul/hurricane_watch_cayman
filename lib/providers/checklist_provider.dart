import 'package:flutter/foundation.dart';
import 'package:hurricane_watch/models/checklist.dart';
import 'package:hurricane_watch/services/checklist_service.dart';

class ChecklistProvider with ChangeNotifier {
  final ChecklistService _checklistService = ChecklistService();

  List<ChecklistItem> _checklistItems = [];
  HouseholdProfile? _householdProfile;
  List<EmergencyContact> _emergencyContacts = [];
  bool _isLoading = false;
  String? _error;

  List<ChecklistItem> get checklistItems => _checklistItems;
  HouseholdProfile? get householdProfile => _householdProfile;
  List<EmergencyContact> get emergencyContacts => _emergencyContacts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get completedItemsCount =>
      _checklistItems.where((item) => item.isCompleted).length;
  int get totalItemsCount => _checklistItems.length;
  double get completionPercentage =>
      totalItemsCount > 0 ? completedItemsCount / totalItemsCount : 0.0;

  Future<void> loadEmergencyContacts() async {
    _setLoading(true);
    _clearError();

    try {
      _emergencyContacts = _checklistService.getEmergencyContacts();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load emergency contacts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> generateChecklist(HouseholdProfile profile) async {
    _setLoading(true);
    _clearError();

    try {
      _householdProfile = profile;
      _checklistItems = await _checklistService.generateChecklist(profile);
      notifyListeners();
    } catch (e) {
      _setError('Failed to generate checklist: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCustomChecklistItem(ChecklistItem item) async {
    try {
      await _checklistService.addCustomItem(item);
      // Regenerate checklist to include the new item
      if (_householdProfile != null) {
        await generateChecklist(_householdProfile!);
      }
    } catch (e) {
      _setError('Failed to add custom item: $e');
    }
  }

  Future<void> removeCustomChecklistItem(String itemId) async {
    try {
      await _checklistService.removeCustomItem(itemId);
      // Regenerate checklist to remove the item
      if (_householdProfile != null) {
        await generateChecklist(_householdProfile!);
      }
    } catch (e) {
      _setError('Failed to remove custom item: $e');
    }
  }

  void updateChecklistItem(String itemId, bool isCompleted) {
    final index = _checklistItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      final item = _checklistItems[index];
      _checklistItems[index] = ChecklistItem(
        id: item.id,
        name: item.name,
        category: item.category,
        description: item.description,
        quantity: item.quantity,
        unit: item.unit,
        isEssential: item.isEssential,
        isCompleted: isCompleted,
        vendorItems: item.vendorItems,
      );
      _checklistService.updateChecklistItem(itemId, isCompleted);
      notifyListeners();
    }
  }

  List<ChecklistItem> getItemsByCategory(String category) {
    return _checklistItems.where((item) => item.category == category).toList();
  }

  List<ChecklistItem> getEssentialItems() {
    return _checklistItems.where((item) => item.isEssential).toList();
  }

  List<ChecklistItem> getCompletedItems() {
    return _checklistItems.where((item) => item.isCompleted).toList();
  }

  List<ChecklistItem> getIncompleteItems() {
    return _checklistItems.where((item) => !item.isCompleted).toList();
  }

  List<VendorItem> searchVendorItems(String query) {
    return _checklistService.searchVendorItems(query);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    if (_householdProfile != null) {
      generateChecklist(_householdProfile!);
    }
    loadEmergencyContacts();
  }
}
