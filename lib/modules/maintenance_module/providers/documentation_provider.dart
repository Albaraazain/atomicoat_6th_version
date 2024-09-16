// lib/providers/documentation_provider.dart
import 'package:flutter/foundation.dart';
import '../models/documentation.dart';
import '../services/documentation_service.dart';

class DocumentationProvider with ChangeNotifier {
  final DocumentationService _service = DocumentationService();
  List<Documentation> _documents = [];
  bool _isLoading = false;
  String? _error;

  List<Documentation> get documents => [..._documents];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDocuments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedDocuments = await _service.loadDocuments();
      _documents = loadedDocuments;
    } catch (error) {
      _error = 'Failed to fetch documents. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDocument(Documentation document) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.saveDocument(document);
      _documents.add(document);
    } catch (error) {
      _error = 'Failed to add document. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDocument(Documentation document) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateDocument(document);
      final index = _documents.indexWhere((doc) => doc.id == document.id);
      if (index != -1) {
        _documents[index] = document;
      }
    } catch (error) {
      _error = 'Failed to update document. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteDocument(id);
      _documents.removeWhere((doc) => doc.id == id);
    } catch (error) {
      _error = 'Failed to delete document. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}