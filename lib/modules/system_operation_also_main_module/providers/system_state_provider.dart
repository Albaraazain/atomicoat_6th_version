// lib/providers/system_state_provider.dart

import 'dart:async';
import 'package:experiment_planner/modules/system_operation_also_main_module/providers/system_copmonent_provider.dart';
import 'package:flutter/foundation.dart';
import '../../../repositories/system_state_repository.dart';
import '../../../services/auth_service.dart';
import '../models/data_point.dart';
import '../models/recipe.dart';
import '../models/alarm.dart';
import '../models/system_component.dart';
import '../models/system_log_entry.dart';
import '../models/safety_error.dart';
import '../services/ald_system_simulation_service.dart';
import 'recipe_provider.dart';
import 'alarm_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SystemStateProvider with ChangeNotifier {
  final SystemStateRepository _systemStateRepository;
  final AuthService _authService;
  final SystemComponentProvider _componentProvider;
  Recipe? _activeRecipe;
  int _currentRecipeStepIndex = 0;
  Recipe? _selectedRecipe;
  bool _isSystemRunning = false;
  final List<SystemLogEntry> _systemLog = [];
  late AldSystemSimulationService _simulationService;
  late RecipeProvider _recipeProvider;
  late AlarmProvider _alarmProvider;
  Timer? _stateUpdateTimer;

  // Add a constant for the maximum number of log entries to keep
  static const int MAX_LOG_ENTRIES = 1000;

  // Add a constant for the maximum number of data points per parameter
  static const int MAX_DATA_POINTS_PER_PARAMETER = 1000;


  SystemStateProvider(
      this._componentProvider,
      this._recipeProvider,
      this._alarmProvider,
      this._systemStateRepository,
      this._authService,
      ) {
    _initializeComponents();
    _loadSystemLog();
    _simulationService =
        AldSystemSimulationService(systemStateProvider: this);
  }

  // Getters
  Recipe? get activeRecipe => _activeRecipe;
  int get currentRecipeStepIndex => _currentRecipeStepIndex;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool get isSystemRunning => _isSystemRunning;
  List<SystemLogEntry> get systemLog => List.unmodifiable(_systemLog);
  List<Alarm> get activeAlarms => _alarmProvider.activeAlarms;

  get components => _componentProvider.components;

  // Initialize all system components with their parameters
  void _initializeComponents() {
    _componentProvider.addComponent(SystemComponent(
      name: 'Nitrogen Generator',
      description: 'Generates nitrogen gas for the system',
      isActivated: true,
      currentValues: {
        'flow_rate': 0.0,
        'purity': 99.9,
      },
      setValues: {
        'flow_rate': 50.0, // Default setpoint
        'purity': 99.9,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 30)),
      minValues: {
        'flow_rate': 10.0,
        'purity': 90.0,
      },
      maxValues: {
        'flow_rate': 100.0,
        'purity': 100.0,
      },
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'MFC',
      description: 'Mass Flow Controller for precursor gas',
      isActivated: true,
      currentValues: {
        'flow_rate': 50.0,
        'pressure': 1.0,
        'percent_correction': 0.0,
      },
      setValues: {
        'flow_rate': 50.0,
        'pressure': 1.0,
        'percent_correction': 0.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 45)),
      minValues: {
        'flow_rate': 0.0,
        'pressure': 0.5,
        'percent_correction': -10.0,
      },
      maxValues: {
        'flow_rate': 100.0,
        'pressure': 2.0,
        'percent_correction': 10.0,
      },
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'Reaction Chamber',
      description: 'Main chamber for chemical reactions',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
        'pressure': 1.0,
      },
      setValues: {
        'temperature': 150.0,
        'pressure': 1.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 60)),
      minValues: {
        'temperature': 100.0,
        'pressure': 0.8,
      },
      maxValues: {
        'temperature': 200.0,
        'pressure': 1.2,
      },
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'Valve 1',
      description: 'Valve for precursor gas',
      isActivated: false,
      currentValues: {
        'status': 0.0, // 0: Closed, 1: Open
      },
      setValues: {
        'status': 1.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 20)),
      minValues: {},
      maxValues: {},
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'Valve 2',
      description: 'Valve for nitrogen gas',
      isActivated: false,
      currentValues: {
        'status': 0.0,
      },
      setValues: {
        'status': 1.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 25)),
      minValues: {},
      maxValues: {},
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'Pressure Control System',
      description: 'Controls the pressure in the reaction chamber',
      isActivated: true,
      currentValues: {
        'pressure': 1.0,
      },
      setValues: {
        'pressure': 1.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 35)),
      minValues: {
        'pressure': 0.5,
      },
      maxValues: {
        'pressure': 1.5,
      },
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'Vacuum Pump',
      description: 'Pumps out gas from the reaction chamber',
      isActivated: true,
      currentValues: {
        'flow_rate': 0.0,
        'power': 50.0,
      },
      setValues: {
        'flow_rate': 0.0,
        'power': 50.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 40)),
      minValues: {
        'flow_rate': 0.0,
        'power': 30.0,
      },
      maxValues: {
        'flow_rate': 100.0,
        'power': 100.0,
      },
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'Precursor Heater 1',
      description: 'Heats precursor gas before entering the chamber',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
      },
      setValues: {
        'temperature': 150.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 15)),
      minValues: {
        'temperature': 100.0,
      },
      maxValues: {
        'temperature': 200.0,
      },
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'Precursor Heater 2',
      description: 'Heats precursor gas before entering the chamber',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
      },
      setValues: {
        'temperature': 150.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 18)),
      minValues: {
        'temperature': 100.0,
      },
      maxValues: {
        'temperature': 200.0,
      },
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'Frontline Heater',
      description: 'Heats the front of the chamber',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
      },
      setValues: {
        'temperature': 150.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 22)),
      minValues: {
        'temperature': 100.0,
      },
      maxValues: {
        'temperature': 200.0,
      },
    ));
    _componentProvider.addComponent(SystemComponent(
      name: 'Backline Heater',
      description: 'Heats the back of the chamber',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
      },
      setValues: {
        'temperature': 150.0,
      },
      lastCheckDate: DateTime.now().subtract(Duration(days: 28)),
      minValues: {
        'temperature': 100.0,
      },
      maxValues: {
        'temperature': 200.0,
      },
    ));
  }

  // Load system log from repository
  Future<void> _loadSystemLog() async {
    String? userId = _authService.currentUser?.uid;
    if (userId != null) {
      final logs = await _systemStateRepository.getSystemLog(userId);
      _systemLog.addAll(logs.take(MAX_LOG_ENTRIES));
      if (_systemLog.length > MAX_LOG_ENTRIES) {
        _systemLog.removeRange(0, _systemLog.length - MAX_LOG_ENTRIES);
      }
      notifyListeners();
    }
  }

  void batchUpdateComponentValues(Map<String, Map<String, double>> updates) {
    updates.forEach((componentName, newStates) {
      final component = _componentProvider.getComponent(componentName);
      if (component != null) {
        component.updateCurrentValues(newStates);
      }
    });
    notifyListeners();
  }

  // Add a log entry
  void addLogEntry(String message, ComponentStatus status) {
    String? userId = _authService.currentUser?.uid;
    if (userId == null) return;

    SystemLogEntry logEntry = SystemLogEntry(
      timestamp: DateTime.now(),
      message: message,
      severity: status,
    );
    _systemLog.add(logEntry);
    if (_systemLog.length > MAX_LOG_ENTRIES) {
      _systemLog.removeAt(0);
    }
    _systemStateRepository.addLogEntry(userId, logEntry);
    notifyListeners();
  }

  // Retrieve a component by name
  SystemComponent? getComponentByName(String componentName) {
    return _componentProvider.getComponent(componentName);
  }

  // Start the simulation
  void startSimulation() {
    if (!_isSystemRunning) {
      _isSystemRunning = true;
      _simulationService.startSimulation();
      addLogEntry('Simulation started', ComponentStatus.normal);
      notifyListeners();
    }
  }

  // Stop the simulation
  void stopSimulation() {
    if (_isSystemRunning) {
      _isSystemRunning = false;
      _simulationService.stopSimulation();
      addLogEntry('Simulation stopped', ComponentStatus.normal);
      notifyListeners();
    }
  }

  // Toggle simulation state
  void toggleSimulation() {
    if (_isSystemRunning) {
      stopSimulation();
    } else {
      startSimulation();
    }
  }

  /// Fetch historical data for a specific component and update the `parameterHistory`
  Future<void> fetchComponentHistory(String componentName) async {
    String? userId = _authService.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final start = now.subtract(Duration(hours: 24));

    try {
      List<Map<String, dynamic>> historyData =
      await _systemStateRepository.getComponentHistory(
        userId,
        componentName,
        start,
        now,
      );

      final component = _componentProvider.getComponent(componentName);
      if (component != null) {
        // Parse historical data and populate the parameterHistory
        for (var data in historyData.take(MAX_DATA_POINTS_PER_PARAMETER)) {
          final timestamp = (data['timestamp'] as Timestamp).toDate();
          final currentValues =
          Map<String, double>.from(data['currentValues']);

          currentValues.forEach((parameter, value) {
            component.updateCurrentValues({parameter: value});
            _componentProvider.addParameterDataPoint(
              componentName,
              parameter,
              DataPoint(timestamp: timestamp, value: value),
              maxDataPoints: MAX_DATA_POINTS_PER_PARAMETER,
            );
          });
        }
      }
    } catch (e) {
      print("Error fetching component history for $componentName: $e");
    }
  }

  // Start the system
  void startSystem() {
    if (!_isSystemRunning && isSystemReadyForRecipe()) {
      _isSystemRunning = true;
      _simulationService.startSimulation();
      _startContinuousStateLogging();
      addLogEntry('System started', ComponentStatus.normal);
      notifyListeners();
    } else {
      _alarmProvider.addAlarm(Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'System not ready to start',
        severity: AlarmSeverity.warning,
        timestamp: DateTime.now(),
      ));
    }
  }

  // Stop the system
  void stopSystem() {
    _isSystemRunning = false;
    _activeRecipe = null;
    _currentRecipeStepIndex = 0;
    _simulationService.stopSimulation();
    _stopContinuousStateLogging();
    _deactivateAllValves();
    addLogEntry('System stopped', ComponentStatus.normal);
    notifyListeners();
  }

  // Start continuous state logging
  void _startContinuousStateLogging() {
    _stateUpdateTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _saveCurrentState();
    });
  }

  // Stop continuous state logging
  void _stopContinuousStateLogging() {
    _stateUpdateTimer?.cancel();
    _stateUpdateTimer = null;
  }

  // Save current state to repository
  void _saveCurrentState() {
    String? userId = _authService.currentUser?.uid;
    if (userId == null) return;

    for (var component in _componentProvider.components.values) {
      _systemStateRepository.saveComponentState(userId, component);
    }
    _systemStateRepository.saveSystemState(userId, {
      'isRunning': _isSystemRunning,
      'activeRecipeId': _activeRecipe?.id,
      'currentRecipeStepIndex': _currentRecipeStepIndex,
    });
  }

  // Log a parameter value
  void logParameterValue(String componentName, String parameter, double value) {
    _componentProvider.addParameterDataPoint(
        componentName,
        parameter,
        DataPoint.reducedPrecision(timestamp: DateTime.now(), value: value)
    );
  }

  // Run diagnostic on a component
  void runDiagnostic(String componentName) {
    final component = _componentProvider.getComponent(componentName);
    if (component != null) {
      addLogEntry('Running diagnostic for ${component.name}', ComponentStatus.normal);
      Future.delayed(const Duration(seconds: 2), () {
        addLogEntry(
            '${component.name} diagnostic completed: All systems nominal',
            ComponentStatus.normal);
        notifyListeners();
      });
    }
  }

  // Update providers if needed
  void updateProviders(
      RecipeProvider recipeProvider, AlarmProvider alarmProvider) {
    if (_recipeProvider != recipeProvider) {
      _recipeProvider = recipeProvider;
    }
    if (_alarmProvider != alarmProvider) {
      _alarmProvider = alarmProvider;
    }
    notifyListeners();
  }

  // Check if system is ready for a recipe
  bool isSystemReadyForRecipe() {
    return _componentProvider.components.values.every((component) =>
    component.isActivated ||
        component.name.toLowerCase().contains('valve'));
  }

  // Execute a recipe
  Future<void> executeRecipe(Recipe recipe) async {
    print("Executing recipe: ${recipe.name}");
    if (isSystemReadyForRecipe()) {
      _activeRecipe = recipe;
      _currentRecipeStepIndex = 0;
      _isSystemRunning = true;
      addLogEntry('Executing recipe: ${recipe.name}', ComponentStatus.normal);
      _simulationService.startSimulation();
      notifyListeners();
      await _executeSteps(recipe.steps);
      completeRecipe();
    } else {
      _alarmProvider.addAlarm(Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'System not ready to start',
        severity: AlarmSeverity.warning,
        timestamp: DateTime.now(),
      ));
    }
  }

  // Select a recipe
  void selectRecipe(String id) {
    _selectedRecipe = _recipeProvider.getRecipeById(id);
    if (_selectedRecipe != null) {
      addLogEntry(
          'Recipe selected: ${_selectedRecipe!.name}', ComponentStatus.normal);
    } else {
      _alarmProvider.addAlarm(Alarm(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: 'Failed to select recipe: Recipe not found',
        severity: AlarmSeverity.warning,
        timestamp: DateTime.now(),
      ));
    }
    notifyListeners();
  }

  // Emergency stop
  void emergencyStop() {
    stopSystem();
    for (var component in _componentProvider.components.values) {
      if (component.isActivated) {
        _componentProvider.deactivateComponent(component.name);
        _systemStateRepository.saveComponentState(
            _authService.currentUser!.uid, component);
      }
    }
    _alarmProvider.addAlarm(Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: 'Emergency stop activated',
      severity: AlarmSeverity.critical,
      timestamp: DateTime.now(),
    ));
    addLogEntry('Emergency stop activated', ComponentStatus.error);
    notifyListeners();
  }

  // Check reactor pressure
  bool isReactorPressureNormal() {
    final pressure =
        _componentProvider.getComponent('Reaction Chamber')?.currentValues['pressure'] ?? 0.0;
    return pressure >= 0.9 && pressure <= 1.1;
  }

  // Check reactor temperature
  bool isReactorTemperatureNormal() {
    final temperature =
        _componentProvider.getComponent('Reaction Chamber')?.currentValues['temperature'] ?? 0.0;
    return temperature >= 145 && temperature <= 155;
  }

  // Check precursor temperature
  bool isPrecursorTemperatureNormal(String precursor) {
    final component = _componentProvider.getComponent(precursor);
    if (component != null) {
      final temperature = component.currentValues['temperature'] ?? 0.0;
      return temperature >= 28 && temperature <= 32;
    }
    return false;
  }

  // Increment recipe step index
  void incrementRecipeStepIndex() {
    if (_activeRecipe != null &&
        _currentRecipeStepIndex < _activeRecipe!.steps.length - 1) {
      _currentRecipeStepIndex++;
      notifyListeners();
    }
  }

  // Complete the recipe
  void completeRecipe() {
    addLogEntry(
        'Recipe completed: ${_activeRecipe?.name}', ComponentStatus.normal);
    _activeRecipe = null;
    _currentRecipeStepIndex = 0;
    _isSystemRunning = false;
    _simulationService.stopSimulation();
    notifyListeners();
  }

  // Trigger safety alert
  void triggerSafetyAlert(SafetyError error) {
    _alarmProvider.addAlarm(Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: error.description,
      severity: _mapSeverityToAlarmSeverity(error.severity),
      timestamp: DateTime.now(),
    ));
    addLogEntry('Safety Alert: ${error.description}',
        _mapSeverityToComponentStatus(error.severity));
  }

  // Map safety severity to alarm severity
  AlarmSeverity _mapSeverityToAlarmSeverity(SafetyErrorSeverity severity) {
    switch (severity) {
      case SafetyErrorSeverity.warning:
        return AlarmSeverity.warning;
      case SafetyErrorSeverity.critical:
        return AlarmSeverity.critical;
      default:
        return AlarmSeverity.info;
    }
  }

  // Map safety severity to component status
  ComponentStatus _mapSeverityToComponentStatus(SafetyErrorSeverity severity) {
    switch (severity) {
      case SafetyErrorSeverity.warning:
        return ComponentStatus.warning;
      case SafetyErrorSeverity.critical:
        return ComponentStatus.error;
      default:
        return ComponentStatus.normal;
    }
  }

  // Get all recipes
  List<Recipe> getAllRecipes() {
    return _recipeProvider.recipes;
  }

  // Refresh recipes
  void refreshRecipes() {
    _recipeProvider.loadRecipes();
    notifyListeners();
  }

  // Execute multiple steps
  Future<void> _executeSteps(List<RecipeStep> steps,
      {double? inheritedTemperature, double? inheritedPressure}) async {
    for (var step in steps) {
      if (!_isSystemRunning) break;
      await _executeStep(step,
          inheritedTemperature: inheritedTemperature,
          inheritedPressure: inheritedPressure);
      incrementRecipeStepIndex();
    }
  }

  // Execute a single step
  Future<void> _executeStep(RecipeStep step,
      {double? inheritedTemperature, double? inheritedPressure}) async {
    addLogEntry(
        'Executing step: ${_getStepDescription(step)}', ComponentStatus.normal);
    switch (step.type) {
      case StepType.valve:
        await _executeValveStep(step);
        break;
      case StepType.purge:
        await _executePurgeStep(step);
        break;
      case StepType.loop:
        await _executeLoopStep(step, inheritedTemperature, inheritedPressure);
        break;
      case StepType.setParameter:
        await _executeSetParameterStep(step);
        break;
    }
  }

  // Deactivate all valves
  void _deactivateAllValves() {
    _componentProvider.components.keys
        .where((name) => name.toLowerCase().contains('valve'))
        .forEach((valveName) {
      _componentProvider.deactivateComponent(valveName);
      addLogEntry('$valveName deactivated', ComponentStatus.normal);
    });
  }

  // Activate a component
  void _activateComponent(String componentName) {
    _componentProvider.activateComponent(componentName);
    addLogEntry('$componentName activated', ComponentStatus.normal);
  }

  // Get step description
  String _getStepDescription(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        return 'Open ${step.parameters['valveType']} for ${step.parameters['duration']} seconds';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']} seconds';
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.setParameter:
        return 'Set ${step.parameters['parameter']} of ${step.parameters['component']} to ${step.parameters['value']}';
      default:
        return 'Unknown step type';
    }
  }

  // Execute a valve step
  Future<void> _executeValveStep(RecipeStep step) async {
    ValveType valveType = step.parameters['valveType'] as ValveType;
    int duration = step.parameters['duration'] as int;
    String valveName = valveType == ValveType.valveA ? 'Valve 1' : 'Valve 2';

    _componentProvider.addParameterDataPoint(
        valveName,
        'status',
        DataPoint(timestamp: DateTime.now(), value: 1.0)
    );
    addLogEntry('$valveName opened for $duration seconds', ComponentStatus.normal);

    await Future.delayed(Duration(seconds: duration));

    _componentProvider.addParameterDataPoint(
        valveName,
        'status',
        DataPoint(timestamp: DateTime.now(), value: 0.0)
    );
    addLogEntry('$valveName closed after $duration seconds', ComponentStatus.normal);
  }

  // Execute a purge step
  Future<void> _executePurgeStep(RecipeStep step) async {
    int duration = step.parameters['duration'] as int;

    _componentProvider.updateComponentCurrentValues('Valve 1', {'status': 0.0});
    _componentProvider.updateComponentCurrentValues('Valve 2', {'status': 0.0});
    _componentProvider.updateComponentCurrentValues('MFC', {'flow_rate': 100.0}); // Assume max flow rate for purge
    addLogEntry('Purge started for $duration seconds', ComponentStatus.normal);

    await Future.delayed(Duration(seconds: duration));

    _componentProvider.updateComponentCurrentValues('MFC', {'flow_rate': 0.0});
    addLogEntry('Purge completed after $duration seconds', ComponentStatus.normal);
  }

  // Execute a loop step
  Future<void> _executeLoopStep(RecipeStep step, double? parentTemperature,
      double? parentPressure) async {
    int iterations = step.parameters['iterations'] as int;
    double? loopTemperature = step.parameters['temperature'] as double?;
    double? loopPressure = step.parameters['pressure'] as double?;

    double effectiveTemperature = loopTemperature ??
        // inheritedTemperature ??
        _componentProvider.getComponent('Reaction Chamber')!.currentValues['temperature']!;
    double effectivePressure = loopPressure ??
        // inheritedPressure ??
        _componentProvider.getComponent('Reaction Chamber')!.currentValues['pressure']!;

    for (int i = 0; i < iterations; i++) {
      if (!_isSystemRunning) break;
      addLogEntry('Starting loop iteration ${i + 1} of $iterations',
          ComponentStatus.normal);

      await _setReactionChamberParameters(
          effectiveTemperature, effectivePressure);

      await _executeSteps(step.subSteps ?? [],
          inheritedTemperature: effectiveTemperature,
          inheritedPressure: effectivePressure);
    }
  }



  // Execute a set parameter step
  Future<void> _executeSetParameterStep(RecipeStep step) async {
    String componentName = step.parameters['component'] as String;
    String parameterName = step.parameters['parameter'] as String;
    double value = step.parameters['value'] as double;

    if (_componentProvider.getComponent(componentName) != null) {
      _componentProvider.updateComponentSetValues(
          componentName, {parameterName: value});
      addLogEntry('Set $parameterName of $componentName to $value',
          ComponentStatus.normal);
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      addAlarm('Unknown component: $componentName', AlarmSeverity.warning);
    }
  }

  // Set reaction chamber parameters
  Future<void> _setReactionChamberParameters(
      double temperature, double pressure) async {
    _componentProvider.updateComponentSetValues('Reaction Chamber', {
      'temperature': temperature,
      'pressure': pressure,
    });
    addLogEntry(
        'Setting chamber temperature to $temperature°C and pressure to $pressure atm',
        ComponentStatus.normal);

    await Future.delayed(const Duration(seconds: 5));

    _componentProvider.updateComponentCurrentValues('Reaction Chamber', {
      'temperature': temperature,
      'pressure': pressure,
    });
    addLogEntry('Chamber reached target temperature and pressure',
        ComponentStatus.normal);
  }

  // Add an alarm
  void addAlarm(String message, AlarmSeverity severity) async {
    final newAlarm = Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
    );

    await _alarmProvider.addAlarm(newAlarm);

    // Log the alarm creation
    addLogEntry('New alarm: ${newAlarm.message}', ComponentStatus.warning);

    notifyListeners();
  }

  // Acknowledge an alarm
  void acknowledgeAlarm(String alarmId) async {
    await _alarmProvider.acknowledgeAlarm(alarmId);

    // Log the alarm acknowledgement
    addLogEntry('Alarm acknowledged: $alarmId', ComponentStatus.normal);

    notifyListeners();
  }

  // Clear an alarm
  void clearAlarm(String alarmId) async {
    await _alarmProvider.clearAlarm(alarmId);

    // Log the alarm clearance
    addLogEntry('Alarm cleared: $alarmId', ComponentStatus.normal);

    notifyListeners();
  }

  // Clear all acknowledged alarms
  void clearAllAcknowledgedAlarms() async {
    await _alarmProvider.clearAllAcknowledgedAlarms();

    // Log the action
    addLogEntry('All acknowledged alarms cleared', ComponentStatus.normal);

    notifyListeners();
  }

  // Dispose resources
  @override
  void dispose() {
    _stopContinuousStateLogging();
    _simulationService.stopSimulation();
    super.dispose();
  }

  void updateComponentCurrentValues(String componentName, Map<String, double> newStates) {
    _componentProvider.updateComponentCurrentValues(componentName, newStates);
  }
}
