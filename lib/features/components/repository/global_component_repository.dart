import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/core/exceptions/bloc_exception.dart';
import '../models/system_component.dart';

// For global component definitions/templates
class GlobalComponentRepository {
  final _firestore = FirebaseFirestore.instance;

  // Get global component definitions
  Stream<List<SystemComponent>> watchAllComponents() {
    return _firestore
        .collection('system_components')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SystemComponent.fromJson(doc.data()))
            .toList());
  }

  // Get single component definition
  Future<SystemComponent?> getComponentDefinition(String componentId) {
    return _firestore
        .collection('system_components')
        .doc(componentId)
        .get()
        .then((doc) => doc.exists
            ? SystemComponent.fromJson(doc.data()!)
            : null);
  }

  Future<void> saveComponentDefinition(SystemComponent component) async {
    try {
      await _firestore.collection('system_components').doc(component.name).set(
        component.toJson(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw BlocException('Failed to save component definition: ${e.toString()}');
    }
  }

  Future<List<SystemComponent>> getAllComponentDefinitions() async {
    try {
      final snapshot = await _firestore.collection('system_components').get();
      return snapshot.docs.map((doc) {
        return SystemComponent.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'name': doc.id,
        });
      }).toList();
    } catch (e) {
      throw BlocException('Failed to get component definitions: ${e.toString()}');
    }
  }
}