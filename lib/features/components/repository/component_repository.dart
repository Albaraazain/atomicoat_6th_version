

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/core/exceptions/bloc_exception.dart';
import '../models/system_component.dart';
import '../../../core/utils/data_point_cache.dart';

class ComponentRepository {
  final FirebaseFirestore _firestore;

  ComponentRepository()
      : _firestore = FirebaseFirestore.instance;

  CollectionReference get componentsCollection =>
      _firestore.collection('system_components');

  Future<SystemComponent?> getComponent(String name) async {
    try {
      final doc = await componentsCollection.doc(name).get();
      if (!doc.exists) return null;
      return SystemComponent.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'name': doc.id,
      });
    } catch (e) {
      throw BlocException('Failed to get component: ${e.toString()}');
    }
  }

  Stream<List<SystemComponent>> watchAllComponents() {
    return componentsCollection.snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) {
          return SystemComponent.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'name': doc.id,
          });
        }).toList();
      } catch (e) {
        throw BlocException('Failed to process components update: ${e.toString()}');
      }
    });
  }

  Future<List<SystemComponent>> getAllComponents() async {
    try {
      final snapshot = await componentsCollection.get();
      return snapshot.docs.map((doc) {
        return SystemComponent.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'name': doc.id,
        });
      }).toList();
    } catch (e) {
      throw BlocException('Failed to get all components: ${e.toString()}');
    }
  }

  Stream<SystemComponent?> watchComponent(String componentName) {
    return componentsCollection
        .doc(componentName)
        .snapshots()
        .map((snapshot) {
          try {
            if (!snapshot.exists) return null;

            return SystemComponent.fromJson({
              ...snapshot.data() as Map<String, dynamic>,
              'name': snapshot.id,
            });
          } catch (e) {
            throw BlocException('Failed to process component update: ${e.toString()}');
          }
        });
  }

  Future<void> saveComponentState(SystemComponent component) async {
    try {
      // Validate component before saving
      _validateComponent(component);

      // Save to Firestore
      await componentsCollection.doc(component.name).set(
        component.toJson(),
        SetOptions(merge: true),
      );
    } catch (e) {
      throw BlocException('Failed to save component state: ${e.toString()}');
    }
  }

  Future<void> updateComponentValues(
    String componentName,
    Map<String, double> values,
  ) async {
    try {
      final component = await getComponent(componentName);
      if (component == null) {
        throw BlocException('Component not found: $componentName');
      }

      component.updateCurrentValues(values);
      await saveComponentState(component);
    } catch (e) {
      throw BlocException('Failed to update component values: ${e.toString()}');
    }
  }

  Future<void> updateComponentSetValues(
    String componentName,
    Map<String, double> setValues,
  ) async {
    try {
      final component = await getComponent(componentName);
      if (component == null) {
        throw BlocException('Component not found: $componentName');
      }

      component.updateSetValues(setValues);
      await saveComponentState(component);
    } catch (e) {
      throw BlocException('Failed to update component set values: ${e.toString()}');
    }
  }

  void _validateComponent(SystemComponent component) {
    if (component.name.isEmpty) {
      throw BlocException('Component name cannot be empty');
    }

    // Validate current values against min/max
    for (final entry in component.currentValues.entries) {
      final parameter = entry.key;
      final value = entry.value;

      if (component.minValues.containsKey(parameter) &&
          value < component.minValues[parameter]!) {
        throw BlocException(
          'Value for $parameter is below minimum: $value < ${component.minValues[parameter]}',
        );
      }

      if (component.maxValues.containsKey(parameter) &&
          value > component.maxValues[parameter]!) {
        throw BlocException(
          'Value for $parameter is above maximum: $value > ${component.maxValues[parameter]}',
        );
      }
    }
  }

  Future<void> clearComponentErrors(String componentName) async {
    try {
      final component = await getComponent(componentName);
      if (component == null) return;

      component.clearErrorMessages();
      await saveComponentState(component);
    } catch (e) {
      throw BlocException('Failed to clear component errors: ${e.toString()}');
    }
  }
}