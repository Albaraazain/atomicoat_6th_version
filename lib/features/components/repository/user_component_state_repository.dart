import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/shared/base/base_repository.dart';
import '../models/system_component.dart';
import '../../../core/exceptions/bloc_exception.dart';

class UserComponentStateRepository extends BaseRepository<SystemComponent> {
  static const int HISTORY_LIMIT = 1000;
  final _firestore = FirebaseFirestore.instance;

  UserComponentStateRepository() : super('component_states');

  @override
  SystemComponent fromJson(Map<String, dynamic> json) =>
      SystemComponent.fromJson(json);

  Future<void> saveComponentState(
    SystemComponent component,
    {required String userId}
  ) async {
    try {
      _validateComponent(component);
      await add(component.name, component, userId: userId);

      // Save historical data
      await getUserCollection(userId)
          .doc(component.name)
          .collection('history')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'currentValues': component.currentValues,
        'setValues': component.setValues,
        'isActivated': component.isActivated,
      });
    } catch (e) {
      throw BlocException('Failed to save component state: ${e.toString()}');
    }
  }

  Future<void> updateComponentValues(
    String componentName,
    Map<String, double> values,
    {required String userId}
  ) async {
    try {
      final doc = await getUserCollection(userId).doc(componentName).get();
      if (!doc.exists) {
        throw BlocException('Component state not found: $componentName');
      }

      final component = fromJson(doc.data() as Map<String, dynamic>);
      component.updateCurrentValues(values);
      await saveComponentState(component, userId: userId);
    } catch (e) {
      throw BlocException('Failed to update component values: ${e.toString()}');
    }
  }

  Future<List<SystemComponent>> getActiveComponents(String userId) async {
    try {
      final snapshot = await getUserCollection(userId)
          .where('isActivated', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw BlocException('Failed to get active components: ${e.toString()}');
    }
  }

  Stream<SystemComponent?> watch(String componentName, {required String userId}) {
    return getUserCollection(userId)
        .doc(componentName)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  void _validateComponent(SystemComponent component) {
    if (component.name.isEmpty) {
      throw BlocException('Component name cannot be empty');
    }

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

  // Watch user-specific component states
  Stream<List<SystemComponent>> watchUserComponents(String userId) {
    return _firestore
        .collection('users/$userId/components')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SystemComponent.fromJson(doc.data()))
            .toList());
  }

  // Initialize user component from global definition
  Future<void> initializeUserComponent(
    String userId,
    SystemComponent globalComponent
  ) async {
    final docRef = _firestore
        .collection('users/$userId/components')
        .doc(globalComponent.id);

    final userComponent = globalComponent.copyWith(
      currentValues: Map.from(globalComponent.currentValues),
      setValues: Map.from(globalComponent.setValues),
      isActivated: false,  // Start deactivated
    );

    await docRef.set(userComponent.toJson());
  }

  // Update user component state
  Future<void> updateComponentState(
    String userId,
    String componentId,
    Map<String, dynamic> updates
  ) async {
    await _firestore
        .collection('users/$userId/components')
        .doc(componentId)
        .update(updates);
  }
}