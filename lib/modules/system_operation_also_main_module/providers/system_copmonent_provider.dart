// lib/providers/system_component_provider.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/system_component_repository.dart';
import '../models/system_component.dart';
import '../models/data_point.dart';

class SystemComponentProvider with ChangeNotifier {
  final SystemComponentRepository _repository = SystemComponentRepository();
  final Map<String, SystemComponent> _components = {};

  // cache datapoints
  // final DataPointCache _dataPointCache = DataPointCache();

  // getter for components names
  List<String> get componentNames => _components.keys.toList();
  Map<String, SystemComponent> get components => {..._components};

  Future<void> fetchComponents({String? userId}) async {
    try {
      final loadedComponents = await _repository.getAll(userId: userId);
      _components.clear();
      for (var component in loadedComponents) {
        _components[component.id] = component;
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching components: $e');
      // You might want to handle this error more gracefully
    }
  }

  Future<void> addComponent(SystemComponent component, {String? userId}) async {
    try {
      await _repository.add(component.id, component, userId: userId);
      _components[component.id] = component;
      notifyListeners();
    } catch (e) {
      print('Error adding component: $e');
      // You might want to handle this error more gracefully
    }
  }

  Future<void> removeComponent(String componentId, {String? userId}) async {
    try {
      await _repository.delete(componentId, userId: userId);
      _components.remove(componentId);
      notifyListeners();
    } catch (e) {
      print('Error removing component: $e');
      // You might want to handle this error more gracefully
    }
  }

  SystemComponent? getComponent(String componentId) {
    return _components[componentId];
  }

  Future<void> updateComponentCurrentValues(
      String componentId, Map<String, double> newValues,
      {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      component.updateCurrentValues(newValues);
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> updateComponentSetValues(
      String componentId, Map<String, double> newSetValues,
      {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      component.updateSetValues(newSetValues);
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> activateComponent(String componentId, {String? userId}) async {
    final component = _components[componentId];
    if (component != null && !component.isActivated) {
      component.isActivated = true;
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> deactivateComponent(String componentId, {String? userId}) async {
    final component = _components[componentId];
    if (component != null && component.isActivated) {
      component.isActivated = false;
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> activateComponents(List<String> componentIds,
      {String? userId}) async {
    for (var componentId in componentIds) {
      await activateComponent(componentId, userId: userId);
    }
  }

  Future<void> updateComponentStatus(
      String componentId, ComponentStatus newStatus,
      {String? userId}) async {
    final component = _components[componentId];
    if (component != null && component.status != newStatus) {
      component.status = newStatus;
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> updateComponentValue(
      String componentId, String parameter, double newValue,
      {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      // Update both set and current values
      component.setValues[parameter] = newValue;
      component.updateCurrentValues({parameter: newValue});

      // Add to parameter history
      addParameterDataPoint(
        componentId,
        parameter,
        DataPoint(timestamp: DateTime.now(), value: newValue),
      );

      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> addErrorMessage(String componentId, String message,
      {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      component.addErrorMessage(message);
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> clearErrorMessages(String componentId, {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      component.clearErrorMessages();
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> addParameterDataPoint(
      String componentId, String parameter, DataPoint dataPoint,
      {int maxDataPoints = 1000}) async {
    final component = _components[componentId];
    if (component != null) {
      if (!component.parameterHistory.containsKey(parameter)) {
        component.parameterHistory[parameter] =
            CircularBuffer<DataPoint>(maxDataPoints);
      }
      component.parameterHistory[parameter]!.add(dataPoint);
      if (component.parameterHistory[parameter]!.length > maxDataPoints) {
        component.parameterHistory[parameter]!.removeAt(0);
      }
      component.updateCurrentValues({parameter: dataPoint.value});
      notifyListeners();
    }
  }

  List<String> getSystemIssues() {
    List<String> issues = [];
    checkSystemReadiness(); // This will populate the issues list
    return issues;
  }

  bool checkSystemReadiness() {
    bool isReady = true;
    _components.forEach((key, component) {
      if (component.status != ComponentStatus.ok) {
        isReady = false;
      }
    });
    return isReady;
  }

  Future<void> updateLastCheckDate(String componentId, DateTime date,
      {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      component.updateLastCheckDate(date);
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> updateMinValues(
      String componentId, Map<String, double> minValues,
      {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      component.updateMinValues(minValues);
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> updateMaxValues(
      String componentId, Map<String, double> maxValues,
      {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      component.updateMaxValues(maxValues);
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  Future<void> clearAllComponents({String? userId}) async {
    final componentIds = _components.keys.toList();
    for (var id in componentIds) {
      await _repository.delete(id, userId: userId);
    }
    _components.clear();
    notifyListeners();
  }

  Future<void> setComponentSetValue(
      String componentId, String parameter, double newValue,
      {String? userId}) async {
    final component = _components[componentId];
    if (component != null) {
      component.setValues[parameter] = newValue;
      await _repository.update(componentId, component, userId: userId);
      notifyListeners();
    }
  }

  void updateComponent(SystemComponent component) {
    _components[component.id] = component;
    notifyListeners();
  }
}
