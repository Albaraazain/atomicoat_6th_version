// lib/providers/maintenance_provider.dart
import 'package:flutter/foundation.dart';
import '../models/component.dart';
import '../models/maintenance_procedure.dart';
import '../models/maintenance_task.dart';
import '../services/maintenance_service.dart';

class MaintenanceProvider with ChangeNotifier {
  final MaintenanceService _service = MaintenanceService();
  List<Component> _components = [];
  List<MaintenanceTask> _tasks = [];
  List<MaintenanceProcedure> _procedures = [];
  bool _isLoading = false;
  String? _error;

  List<Component> get components => [..._components];
  List<MaintenanceTask> get tasks => [..._tasks];
  List<MaintenanceProcedure> get procedures => [..._procedures];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMaintenanceProcedures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _procedures = await _service.loadMaintenanceProcedures();
    } catch (error) {
      _error = 'Failed to fetch maintenance procedures. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MaintenanceProcedure?> getMaintenanceProcedure(String componentId, String procedureType) async {
    try {
      return await _service.getMaintenanceProcedure(componentId, procedureType);
    } catch (error) {
      _error = 'Failed to get maintenance procedure. Please try again later.';
      notifyListeners();
      return null;
    }
  }

  Future<void> addMaintenanceProcedure(MaintenanceProcedure procedure) async {
    try {
      await _service.saveMaintenanceProcedure(procedure);
      _procedures.add(procedure);
      notifyListeners();
    } catch (error) {
      _error = 'Failed to add maintenance procedure. Please try again later.';
      notifyListeners();
    }
  }


  Future<void> fetchComponents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedComponents = await _service.loadComponents();
      _components = loadedComponents;
    } catch (error) {
      _error = 'Failed to fetch components. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addComponent(Component component) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.saveComponent(component);
      _components.add(component);
    } catch (error) {
      _error = 'Failed to add component. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateComponentStatus(String componentId, String newStatus) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _components.indexWhere((comp) => comp.id == componentId);
      if (index != -1) {
        final updatedComponent = _components[index].copyWith(status: newStatus);
        await _service.updateComponent(updatedComponent);
        _components[index] = updatedComponent;
      } else {
        _error = 'Component not found.';
      }
    } catch (error) {
      _error = 'Failed to update component status. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loadedTasks = await _service.loadTasks();
      _tasks = loadedTasks;
    } catch (error) {
      _error = 'Failed to fetch maintenance tasks. Please try again later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(MaintenanceTask task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.saveTask(task);
      _tasks.add(task);
    } catch (error) {
      _error = 'Failed to add maintenance task. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTaskCompletion(String taskId, bool isCompleted) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        final updatedTask = _tasks[index].copyWith(isCompleted: isCompleted);
        await _service.updateTask(updatedTask);
        _tasks[index] = updatedTask;
      } else {
        _error = 'Task not found.';
      }
    } catch (error) {
      _error = 'Failed to update task completion status. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MaintenanceTask> getTasksForComponent(String componentId) {
    return _tasks.where((task) => task.componentId == componentId).toList();
  }

  Future<void> deleteTask(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
    } catch (error) {
      _error = 'Failed to delete task. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(MaintenanceTask task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
    } catch (error) {
      _error = 'Failed to update task. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> getComponentName(String componentId) async {
    final component = _components.firstWhere(
          (comp) => comp.id == componentId,
      orElse: () => Component(
        id: componentId,
        name: 'Unknown Component',
        type: 'Unknown',
        lastMaintenanceDate: DateTime.now(),
      ),
    );
    return component.name;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}