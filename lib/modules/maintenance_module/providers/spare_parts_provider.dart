// lib/providers/spare_parts_provider.dart
import 'package:flutter/foundation.dart';
import '../models/spare_part.dart';
import '../services/spare_parts_service.dart';

class SparePartsProvider with ChangeNotifier {
  final SparePartsService _service = SparePartsService();
  List<SparePart> _spareParts = [];
  bool _isLoading = false;
  String? _error;

  List<SparePart> get spareParts => [..._spareParts];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSpareParts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedParts = await _service.loadSpareParts();
      _spareParts = loadedParts;
    } catch (error) {
      _error = 'Failed to fetch spare parts. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSparePart(SparePart part) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.saveSparePart(part);
      _spareParts.add(part);
    } catch (error) {
      _error = 'Failed to add spare part. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSparePartQuantity(String partId, int newQuantity) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _spareParts.indexWhere((part) => part.id == partId);
      if (index != -1) {
        final updatedPart = _spareParts[index].copyWith(quantity: newQuantity);
        await _service.updateSparePart(updatedPart);
        _spareParts[index] = updatedPart;
      } else {
        _error = 'Spare part not found.';
      }
    } catch (error) {
      _error = 'Failed to update spare part quantity. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<SparePart> getLowStockParts() {
    return _spareParts.where((part) => part.isLowStock).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}