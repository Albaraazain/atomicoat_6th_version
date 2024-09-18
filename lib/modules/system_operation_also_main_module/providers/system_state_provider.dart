// lib/providers/system_state_provider.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../repositories/system_state_repository.dart';
import '../../../services/auth_service.dart';
import '../models/data_point.dart';
import '../models/safety_error.dart';
import '../models/system_component.dart';
import '../models/recipe.dart';
import '../models/alarm.dart';
import '../models/system_log_entry.dart';
import '../services/ald_system_simulation_service.dart';
import 'recipe_provider.dart';
import 'alarm_provider.dart';

class SystemStateProvider with ChangeNotifier {
  final SystemStateRepository _systemStateRepository;
  final AuthService _authService;
  final Map<String, SystemComponent> _components = {};
  Recipe? _activeRecipe;
  int _currentRecipeStepIndex = 0;
  Recipe? _selectedRecipe;
  bool _isSystemRunning = false;
  final List<SystemLogEntry> _systemLog = [];
  late AldSystemSimulationService _simulationService;
  late RecipeProvider _recipeProvider;
  late AlarmProvider _alarmProvider;
  Timer? _stateUpdateTimer;

  SystemStateProvider(
      this._recipeProvider,
      this._alarmProvider,
      this._systemStateRepository,
      this._authService,
      ) {
    _initializeComponents();
    _loadSystemLog();
    _simulationService = AldSystemSimulationService(systemStateProvider: this);
  }

  // Getters
  Map<String, SystemComponent> get components => _components;
  Recipe? get activeRecipe => _activeRecipe;
  int get currentRecipeStepIndex => _currentRecipeStepIndex;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool get isSystemRunning => _isSystemRunning;
  List<SystemLogEntry> get systemLog => _systemLog;
  List<Alarm> get activeAlarms => _alarmProvider.activeAlarms;

  // Initialize all system components with their parameters
  void _initializeComponents() {
    _components['Nitrogen Generator'] = SystemComponent(
      name: 'Nitrogen Generator',
      isActivated: true,
      currentValues: {
        'flow_rate': 0.0,
        'purity': 99.9,
      },
      setValues: {
        'flow_rate': 50.0, // Default setpoint
        'purity': 99.9,
      }, description: 'Generates nitrogen gas for the system',
    );
    _components['MFC'] = SystemComponent(
      name: 'MFC',
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
      }, description: 'Mass Flow Controller for precursor gas',
    );
    _components['Reaction Chamber'] = SystemComponent(
      name: 'Reaction Chamber',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
        'pressure': 1.0,
      },
      setValues: {
        'temperature': 150.0,
        'pressure': 1.0,
      }, description: 'Main chamber for chemical reactions',
    );
    _components['Valve 1'] = SystemComponent(
      name: 'Valve 1',
      isActivated: false,
      currentValues: {
        'status': 0.0, // 0: Closed, 1: Open
      },
      setValues: {
        'status': 1.0,
      }, description: 'Valve for precursor gas',
    );
    _components['Valve 2'] = SystemComponent(
      name: 'Valve 2',
      isActivated: false,
      currentValues: {
        'status': 0.0,
      },
      setValues: {
        'status': 1.0,
      }, description: 'Valve for nitrogen gas',
    );
    _components['Pressure Control System'] = SystemComponent(
      name: 'Pressure Control System',
      isActivated: true,
      currentValues: {
        'pressure': 1.0,
      },
      setValues: {
        'pressure': 1.0,
      }, description: 'Controls the pressure in the reaction chamber',
    );
    _components['Vacuum Pump'] = SystemComponent(
      name: 'Vacuum Pump',
      isActivated: true,
      currentValues: {
        'flow_rate': 0.0,
        'power': 50.0,
      },
      setValues: {
        'flow_rate': 0.0,
        'power': 50.0,
      }, description: 'Pumps out gas from the reaction chamber',
    );
    _components['Precursor Heater 1'] = SystemComponent(
      name: 'Precursor Heater 1',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
      },
      setValues: {
        'temperature': 150.0,
      }, description: 'Heats precursor gas before entering the chamber',
    );
    _components['Precursor Heater 2'] = SystemComponent(
      name: 'Precursor Heater 2',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
      },
      setValues: {
        'temperature': 150.0,
      }, description: 'Heats precursor gas before entering the chamber',
    );
    _components['Frontline Heater'] = SystemComponent(
      name: 'Frontline Heater',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
      },
      setValues: {
        'temperature': 150.0,
      }, description: 'Heats the front of the chamber',
    );
    _components['Backline Heater'] = SystemComponent(
      name: 'Backline Heater',
      isActivated: true,
      currentValues: {
        'temperature': 150.0,
      },
      setValues: {
        'temperature': 150.0,
      }, description: 'Heats the back of the chamber',
    );
  }

  // Load system log from repository
  Future<void> _loadSystemLog() async {
    String? userId = _authService.currentUser?.uid;
    if (userId != null) {
      _systemLog.addAll(await _systemStateRepository.getSystemLog(userId));
    }
  }

  // Update component state with new values
  void updateComponentState(String componentName, Map<String, double> newState) {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      print("Updating component state: $componentName, New state: $newState");

      if (_components.containsKey(componentName)) {
        var component = _components[componentName]!;

        // Update the current values
        component.currentValues.addAll(newState);

        // For each updated parameter, add the new value to its history
        newState.forEach((parameter, value) {
          if (!component.parameterHistory.containsKey(parameter)) {
            component.parameterHistory[parameter] = [];
          }

          // Add the new data point to the history
          component.parameterHistory[parameter]!.add(
            DataPoint(
              timestamp: DateTime.now(),
              value: value,
            ),
          );

          // Keep the history limited to the last 100 entries
          if (component.parameterHistory[parameter]!.length > 1000) {
            component.parameterHistory[parameter]!.removeAt(0);
          }

          print("Added data point to $componentName for $parameter: $value");
        });

        // Save the updated state to the repository
        _systemStateRepository.saveComponentState(userId, component);

        // Add a log entry
        addLogEntry(
            'Updated $componentName: $newState', ComponentStatus.normal);

        // Notify listeners to update the UI
        notifyListeners();
      }
    }
  }

  // Activate a component
  void activateComponent(String componentName) {
    String? userId = _authService.currentUser?.uid;
    if (userId == null) return;

    if (_components.containsKey(componentName)) {
      _components[componentName]!.isActivated = true;
      _systemStateRepository.saveComponent(userId, _components[componentName]!);
      addLogEntry('Activated $componentName', ComponentStatus.normal);
      notifyListeners();
    }
  }

  // Deactivate a component
  void deactivateComponent(String componentName) {
    if (_components.containsKey(componentName)) {
      _components[componentName]!.isActivated = false;
      addLogEntry('Deactivated $componentName', ComponentStatus.normal);
      notifyListeners();
    }
  }

  // Set a component's set value
  void setComponentSetValue(String componentName, String parameterName, double value) {
    String? userId = _authService.currentUserId;
    if (userId != null) {
      if (_components.containsKey(componentName)) {
        _components[componentName]!.setValues[parameterName] = value;
        _systemStateRepository.saveComponent(userId, _components[componentName]!);
        addLogEntry('Set $parameterName of $componentName to $value', ComponentStatus.normal);
        notifyListeners();
      }
    }
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
    _systemStateRepository.addLogEntry(userId, logEntry);
    notifyListeners();
  }


  // Retrieve a component by name
  SystemComponent? getComponentByName(String componentName) {
    return _components[componentName];
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
  Future<void> _fetchComponentHistory(String componentName) async {
    String? userId = _authService.currentUser?.uid;
    if (userId == null) return;

    final now = DateTime.now();
    final start = now.subtract(Duration(hours: 24));

    try {
      List<Map<String, dynamic>> historyData = await _systemStateRepository.getComponentHistory(
        userId,
        componentName,
        start,
        now,
      );


      final component = _components[componentName];
      if (component != null) {
        // Parse historical data and populate the parameterHistory
        for (var data in historyData) {
          final timestamp = (data['timestamp'] as Timestamp).toDate();
          final currentValues = Map<String, double>.from(data['currentValues']);

          currentValues.forEach((parameter, value) {
            if (!component.parameterHistory.containsKey(parameter)) {
              component.parameterHistory[parameter] = [];
            }
            // Add historical data point
            component.parameterHistory[parameter]!.add(DataPoint(
              timestamp: timestamp,
              value: value,
            ));
          });
        }
      }
    } catch (e) {
      print("Error fetching component history for $componentName: $e");
    }
  }

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

  void _startContinuousStateLogging() {
    _stateUpdateTimer = Timer.periodic(Duration(seconds: 5), (_) {
      _saveCurrentState();
    });
  }

  void _stopContinuousStateLogging() {
    _stateUpdateTimer?.cancel();
    _stateUpdateTimer = null;
  }

  void _saveCurrentState() {
    String? userId = _authService.currentUser?.uid;
    if (userId == null) return;

    for (var component in _components.values) {
      _systemStateRepository.saveComponentState(userId, component);
    }
    _systemStateRepository.saveSystemState(userId, {
      'isRunning': _isSystemRunning,
      'activeRecipeId': _activeRecipe?.id,
      'currentRecipeStepIndex': _currentRecipeStepIndex,
    });
  }


  void logParameterValue(String componentName, String parameter, double value) {
    _systemStateRepository.saveComponentState(
      _authService.currentUserId!,
      SystemComponent(
        name: componentName,
        isActivated: true,
        currentValues: {parameter: value},
        setValues: {parameter: value},
        description: '',
      ),
    );
  }

  void runDiagnostic(String componentName) {
    final component = _components[componentName];
    if (component != null) {
      addLogEntry(
          'Running diagnostic for ${component.name}', ComponentStatus.normal);
      Future.delayed(const Duration(seconds: 2), () {
        addLogEntry(
            '${component.name} diagnostic completed: All systems nominal',
            ComponentStatus.normal);
        notifyListeners();
      });
    }
  }

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

  bool isSystemReadyForRecipe() {
    return _components.values.every((component) =>
    component.isActivated ||
        component.name.toLowerCase().contains('valve'));
  }

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

  void emergencyStop() {
    stopSystem();
    for (var component in _components.values) {
      component.isActivated = false;
      _systemStateRepository.saveComponentState(
          _authService.currentUser!.uid, component);
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

  bool isReactorPressureNormal() {
    final pressure =
        _components['Reaction Chamber']?.currentValues['pressure'] ?? 0.0;
    return pressure >= 0.9 && pressure <= 1.1;
  }

  bool isReactorTemperatureNormal() {
    final temperature =
        _components['Reaction Chamber']?.currentValues['temperature'] ?? 0.0;
    return temperature >= 145 && temperature <= 155;
  }

  bool isPrecursorTemperatureNormal(String precursor) {
    final component = _components[precursor];
    if (component != null) {
      final temperature = component.currentValues['temperature'] ?? 0.0;
      return temperature >= 28 && temperature <= 32;
    }
    return false;
  }

  void incrementRecipeStepIndex() {
    if (_activeRecipe != null &&
        _currentRecipeStepIndex < _activeRecipe!.steps.length - 1) {
      _currentRecipeStepIndex++;
      notifyListeners();
    }
  }

  void completeRecipe() {
    addLogEntry(
        'Recipe completed: ${_activeRecipe?.name}', ComponentStatus.normal);
    _activeRecipe = null;
    _currentRecipeStepIndex = 0;
    _isSystemRunning = false;
    _simulationService.stopSimulation();
    notifyListeners();
  }

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


  List<Recipe> getAllRecipes() {
    return _recipeProvider.recipes;
  }

  void refreshRecipes() {
    _recipeProvider.loadRecipes();
    notifyListeners();
  }


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

  void _deactivateAllValves() {
    _deactivateComponent('Valve 1');
    _deactivateComponent('Valve 2');
  }

  void _deactivateComponent(String componentName) {
    if (_components.containsKey(componentName)) {
      _components[componentName]!.isActivated = false;
      addLogEntry('$componentName deactivated', ComponentStatus.normal);
      notifyListeners();
    }
  }

  void _activateComponent(String componentName) {
    if (_components.containsKey(componentName)) {
      _components[componentName]!.isActivated = true;
      addLogEntry('$componentName activated', ComponentStatus.normal);
      notifyListeners();
    }
  }


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

  Future<void> _executeValveStep(RecipeStep step) async {
    ValveType valveType = step.parameters['valveType'] as ValveType;
    int duration = step.parameters['duration'] as int;
    String valveName = valveType == ValveType.valveA ? 'Valve 1' : 'Valve 2';

    updateComponentState(valveName, {'status': 1.0});
    addLogEntry(
        '$valveName opened for $duration seconds', ComponentStatus.normal);

    await Future.delayed(Duration(seconds: duration));

    updateComponentState(valveName, {'status': 0.0});
    addLogEntry(
        '$valveName closed after $duration seconds', ComponentStatus.normal);
  }

  Future<void> _executePurgeStep(RecipeStep step) async {
    int duration = step.parameters['duration'] as int;

    updateComponentState('Valve 1', {'status': 0.0});
    updateComponentState('Valve 2', {'status': 0.0});
    updateComponentState(
        'MFC', {'flow_rate': 100.0}); // Assume max flow rate for purge
    addLogEntry('Purge started for $duration seconds', ComponentStatus.normal);

    await Future.delayed(Duration(seconds: duration));

    updateComponentState('MFC', {'flow_rate': 0.0});
    addLogEntry(
        'Purge completed after $duration seconds', ComponentStatus.normal);
  }

  Future<void> _executeLoopStep(RecipeStep step, double? parentTemperature,
      double? parentPressure) async {
    int iterations = step.parameters['iterations'] as int;
    double? loopTemperature = step.parameters['temperature'] as double?;
    double? loopPressure = step.parameters['pressure'] as double?;

    double effectiveTemperature = loopTemperature ??
        parentTemperature ??
        _components['Reaction Chamber']!.currentValues['temperature']!;
    double effectivePressure = loopPressure ??
        parentPressure ??
        _components['Reaction Chamber']!.currentValues['pressure']!;

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


  Future<void> _executeSetParameterStep(RecipeStep step) async {
    String componentName = step.parameters['component'] as String;
    String parameterName = step.parameters['parameter'] as String;
    double value = step.parameters['value'] as double;

    if (_components.containsKey(componentName)) {
      setComponentSetValue(componentName, parameterName, value);
      addLogEntry('Set $parameterName of $componentName to $value',
          ComponentStatus.normal);
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      addAlarm('Unknown component: $componentName', AlarmSeverity.warning);
    }
  }

  Future<void> _setReactionChamberParameters(
      double temperature, double pressure) async {
    _components['Reaction Chamber']!.setValues['temperature'] = temperature;
    _components['Reaction Chamber']!.setValues['pressure'] = pressure;
    addLogEntry(
        'Setting chamber temperature to $temperature°C and pressure to $pressure atm',
        ComponentStatus.normal);

    await Future.delayed(const Duration(seconds: 5));

    _components['Reaction Chamber']!.currentValues['temperature'] = temperature;
    _components['Reaction Chamber']!.currentValues['pressure'] = pressure;
    addLogEntry('Chamber reached target temperature and pressure',
        ComponentStatus.normal);
  }

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

  void acknowledgeAlarm(String alarmId) async {
    await _alarmProvider.acknowledgeAlarm(alarmId);

    // Log the alarm acknowledgement
    addLogEntry('Alarm acknowledged: $alarmId', ComponentStatus.normal);

    notifyListeners();
  }

  void clearAlarm(String alarmId) async {
    await _alarmProvider.clearAlarm(alarmId);

    // Log the alarm clearance
    addLogEntry('Alarm cleared: $alarmId', ComponentStatus.normal);

    notifyListeners();
  }

// You might also want to add this method to clear all acknowledged alarms
  void clearAllAcknowledgedAlarms() async {
    await _alarmProvider.clearAllAcknowledgedAlarms();

    // Log the action
    addLogEntry('All acknowledged alarms cleared', ComponentStatus.normal);

    notifyListeners();
  }

  @override
  void dispose() {
    _stopContinuousStateLogging();
    _simulationService.stopSimulation();
    super.dispose();
  }
}
