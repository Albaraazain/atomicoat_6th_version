// lib/modules/system_operation_also_main_module/providers/safety_error_provider.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/safety_error_repository.dart';
import '../models/safety_error.dart';
import '../../../services/auth_service.dart';

class SafetyErrorProvider with ChangeNotifier {
  final SafetyErrorRepository _safetyErrorRepository = SafetyErrorRepository();
  final AuthService _authService;
  List<SafetyError> _safetyErrors = [];

  List<SafetyError> get safetyErrors => _safetyErrors;

  SafetyErrorProvider(this._authService) {
    loadSafetyErrors();
  }

  Future<void> loadSafetyErrors() async {
    try {
      String? userId = _authService.currentUserId;
      if (userId != null) {
        _safetyErrors = await _safetyErrorRepository.getAll(userId: userId);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading safety errors: $e');
    }
  }

  Future<void> addSafetyError(SafetyError safetyError) async {
    try {
      String? userId = _authService.currentUserId;
      if (userId != null) {
        await _safetyErrorRepository.add(safetyError.id, safetyError, userId: userId);
        _safetyErrors.add(safetyError);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding safety error: $e');
      rethrow;
    }
  }

  Future<void> updateSafetyError(SafetyError updatedSafetyError) async {
    try {
      String? userId = _authService.currentUserId;
      if (userId != null) {
        await _safetyErrorRepository.update(updatedSafetyError.id, updatedSafetyError, userId: userId);
        int index = _safetyErrors.indexWhere((safetyError) => safetyError.id == updatedSafetyError.id);
        if (index != -1) {
          _safetyErrors[index] = updatedSafetyError;
          notifyListeners();
        } else {
          throw Exception('Safety error not found for update');
        }
      }
    } catch (e) {
      print('Error updating safety error: $e');
      rethrow;
    }
  }

  Future<void> deleteSafetyError(String id) async {
    try {
      String? userId = _authService.currentUserId;
      if (userId != null) {
        await _safetyErrorRepository.delete(id, userId: userId);
        _safetyErrors.removeWhere((safetyError) => safetyError.id == id);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting safety error: $e');
      rethrow;
    }
  }

  SafetyError? getSafetyErrorById(String id) {
    try {
      return _safetyErrors.firstWhere((safetyError) => safetyError.id == id);
    } catch (e) {
      print('Safety error not found: $e');
      return null;
    }
  }
}