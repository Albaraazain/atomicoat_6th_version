// lib/providers/maintenance_provider.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/system_component_repository.dart';
import '../../system_operation_also_main_module/models/system_component.dart';
import '../../system_operation_also_main_module/providers/system_copmonent_provider.dart';
import '../models/maintenance_procedure.dart';
import '../models/maintenance_task.dart';
import '../services/maintenance_service.dart';

class MaintenanceProvider with ChangeNotifier {
  final MaintenanceService _service = MaintenanceService();
  final SystemComponentProvider _componentProvider;
  final SystemComponentRepository _componentRepository = SystemComponentRepository();

  List<MaintenanceTask> _tasks = [];
  List<MaintenanceProcedure> _procedures = [];
  bool _isLoading = false;
  String? _error;

  MaintenanceProvider(this._componentProvider);

  // Access components directly from SystemComponentProvider
  Map<String, SystemComponent> get components => _componentProvider.components;

  List<MaintenanceTask> get tasks => [..._tasks];
  List<MaintenanceProcedure> get procedures => [..._procedures];
  bool get isLoading => _isLoading;
  String? get error => _error;

  // get component name method
  Future<String> getComponentName(String id) async {
    final component = await _componentProvider.getComponent(id);
    return component?.name ?? 'Unknown';
  }
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

  Future<MaintenanceProcedure?> getMaintenanceProcedure(
      String componentName, String procedureType) async {
    try {
      return await _service.getMaintenanceProcedure(componentName, procedureType);
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

  List<MaintenanceTask> getTasksForComponent(String componentName) {
    return _tasks
        .where((task) => task.componentName == componentName)
        .toList();
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

  // Update the last check date of a component
  Future<void> updateLastCheckDate(String componentId, DateTime date, {String? userId}) async {
    await _componentProvider.updateLastCheckDate(componentId, date, userId: userId);
  }

  Future<void> updateComponentStatus(String componentId, ComponentStatus newStatus, {String? userId}) async {
    await _componentProvider.updateComponentStatus(componentId, newStatus, userId: userId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void update(MaintenanceProvider maintenance) {
    _tasks = maintenance.tasks;
    _procedures = maintenance.procedures;
    _isLoading = maintenance.isLoading;
    _error = maintenance.error;
  }


  Future<void> fetchComponents({String? userId}) async {
    try {
      await _componentProvider.fetchComponents(userId: userId);
      notifyListeners();
    } catch (error) {
      _error = 'Failed to fetch components. Please try again later.';
      notifyListeners();
    }
  }
}