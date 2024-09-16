import 'package:flutter/foundation.dart';
import '../models/system_component.dart';
import '../models/recipe.dart';
import '../models/alarm.dart';
import '../models/system_log_entry.dart';
import '../models/safety_error.dart';
import '../services/ald_system_simulation_service.dart';
import '../providers/recipe_provider.dart';
import 'alarm_provider.dart';

class SystemStateProvider with ChangeNotifier {
  final Map<String, SystemComponent> _components = {};
  Recipe? _activeRecipe;
  int _currentRecipeStepIndex = 0;
  Recipe? _selectedRecipe;
  bool _isSystemRunning = false;
  final List<SystemLogEntry> _systemLog = [];
  final List<Alarm> _activeAlarms = [];
  late AldSystemSimulationService _simulationService;
  final RecipeProvider _recipeProvider;


  final AlarmProvider _alarmProvider;

  SystemStateProvider(this._recipeProvider, this._alarmProvider) {
    _initializeComponents();
    _simulationService = AldSystemSimulationService(systemStateProvider: this);
  }


  Recipe? get activeRecipe => _activeRecipe;
  int get currentRecipeStepIndex => _currentRecipeStepIndex;
  Map<String, SystemComponent> get components => _components;
  Recipe? get selectedRecipe => _selectedRecipe;
  bool get isSystemRunning => _isSystemRunning;
  List<SystemLogEntry> get systemLog => _systemLog;
  List<Alarm> get activeAlarms => _activeAlarms;



  void _initializeComponents() {
    final componentsList = [
      SystemComponent(
        name: 'Nitrogen Generator',
        description: 'Provides inert gas for purging and as a carrier gas',
        currentValues: {'flow_rate': 0.0, 'purity': 99.9},
        setValues: {'flow_rate': 0.0},
      ),
      SystemComponent(
        name: 'MFC',
        description: 'Mass Flow Controller for precise gas flow regulation',
        currentValues: {'flow_rate': 0.0, 'pressure': 1.0, 'percent_correction': 0.0},
        setValues: {'flow_rate': 0.0},
      ),
      SystemComponent(
        name: 'Backline Heater',
        description: 'Heats precursor delivery lines to prevent condensation',
        currentValues: {'temperature': 25.0},
        setValues: {'temperature': 25.0},
      ),
      SystemComponent(
        name: 'Frontline Heater',
        description: 'Heats gas lines near the reaction chamber',
        currentValues: {'temperature': 25.0},
        setValues: {'temperature': 25.0},
      ),
      SystemComponent(
        name: 'Precursor Heater 1',
        description: 'Heats precursor container to maintain vapor pressure',
        currentValues: {'temperature': 25.0, 'fill_level': 100.0},
        setValues: {'temperature': 25.0},
      ),
      SystemComponent(
        name: 'Precursor Heater 2',
        description: 'Heats precursor container to maintain vapor pressure',
        currentValues: {'temperature': 25.0, 'fill_level': 100.0},
        setValues: {'temperature': 25.0},
      ),
      SystemComponent(
        name: 'Reaction Chamber',
        description: 'Where the ALD reactions occur on the substrate',
        currentValues: {'temperature': 25.0, 'pressure': 1.0},
        setValues: {'temperature': 25.0, 'pressure': 1.0},
      ),
      SystemComponent(
        name: 'Valve 1',
        description: 'Controls the flow of precursor 1 and purge gas',
        currentValues: {'status': 0.0},
        setValues: {'status': 0.0},
      ),
      SystemComponent(
        name: 'Valve 2',
        description: 'Controls the flow of precursor 2 and purge gas',
        currentValues: {'status': 0.0},
        setValues: {'status': 0.0},
      ),
      SystemComponent(
        name: 'Pressure Control System',
        description: 'Maintains optimal pressure in the reaction chamber',
        currentValues: {'pressure': 1.0},
        setValues: {'pressure': 1.0},
      ),
      SystemComponent(
        name: 'Vacuum Pump',
        description: 'Evacuates the chamber between precursor pulses',
        currentValues: {'power': 100.0},
        setValues: {'power': 100.0},
      ),
    ];

    for (var component in componentsList) {
      _components[component.name] = component;
    }
  }

  void startSystem() {
    if (!_isSystemRunning && isSystemReadyForRecipe()) {
      _isSystemRunning = true;
      _simulationService.startSimulation();
      addLogEntry('System started', ComponentStatus.normal);
      notifyListeners();
    } else {
      addAlarm('System not ready to start', AlarmSeverity.warning);
    }
  }

  void stopSystem() {
    _isSystemRunning = false;
    _activeRecipe = null;
    _currentRecipeStepIndex = 0;
    _simulationService.stopSimulation();
    _deactivateAllValves();
    addLogEntry('System stopped', ComponentStatus.normal);
    notifyListeners();
  }

  bool isSystemReadyForRecipe() {
    return _components.values.every((component) =>
    component.isActivated || component.name.toLowerCase().contains('valve'));
  }

  void _deactivateAllValves() {
    _deactivateComponent('Valve 1');
    _deactivateComponent('Valve 2');
  }

  Future<void> executeRecipe(Recipe recipe) async {
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
      _alarmProvider.addAlarm('System not ready for recipe execution', AlarmSeverity.warning);
    }
  }

  Future<void> _executeSteps(List<RecipeStep> steps, {double? inheritedTemperature, double? inheritedPressure}) async {
    for (var step in steps) {
      if (!_isSystemRunning) break;
      await _executeStep(step, inheritedTemperature: inheritedTemperature, inheritedPressure: inheritedPressure);
      incrementRecipeStepIndex();
    }
  }

  Future<void> _executeStep(RecipeStep step, {double? inheritedTemperature, double? inheritedPressure}) async {
    addLogEntry('Executing step: ${_getStepDescription(step)}', ComponentStatus.normal);

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
    addLogEntry('$valveName opened for $duration seconds', ComponentStatus.normal);

    await Future.delayed(Duration(seconds: duration));

    updateComponentState(valveName, {'status': 0.0});
    addLogEntry('$valveName closed after $duration seconds', ComponentStatus.normal);
  }

  Future<void> _executePurgeStep(RecipeStep step) async {
    int duration = step.parameters['duration'] as int;

    updateComponentState('Valve 1', {'status': 0.0});
    updateComponentState('Valve 2', {'status': 0.0});
    updateComponentState('MFC', {'flow_rate': 100.0}); // Assume max flow rate for purge
    addLogEntry('Purge started for $duration seconds', ComponentStatus.normal);

    await Future.delayed(Duration(seconds: duration));

    updateComponentState('MFC', {'flow_rate': 0.0});
    addLogEntry('Purge completed after $duration seconds', ComponentStatus.normal);
  }


  Future<void> _executeLoopStep(RecipeStep step, double? parentTemperature, double? parentPressure) async {
    int iterations = step.parameters['iterations'] as int;
    double? loopTemperature = step.parameters['temperature'] as double?;
    double? loopPressure = step.parameters['pressure'] as double?;

    double effectiveTemperature = loopTemperature ?? parentTemperature ?? _components['Reaction Chamber']!.currentValues['temperature']!;
    double effectivePressure = loopPressure ?? parentPressure ?? _components['Reaction Chamber']!.currentValues['pressure']!;

    for (int i = 0; i < iterations; i++) {
      if (!_isSystemRunning) break;
      addLogEntry('Starting loop iteration ${i + 1} of $iterations', ComponentStatus.normal);

      await _setReactionChamberParameters(effectiveTemperature, effectivePressure);

      await _executeSteps(step.subSteps ?? [],
          inheritedTemperature: effectiveTemperature,
          inheritedPressure: effectivePressure
      );
    }
  }

  Future<void> _executeSetParameterStep(RecipeStep step) async {
    String componentName = step.parameters['component'] as String;
    String parameterName = step.parameters['parameter'] as String;
    double value = step.parameters['value'] as double;

    if (_components.containsKey(componentName)) {
      setComponentSetValue(componentName, parameterName, value);
      addLogEntry('Set $parameterName of $componentName to $value', ComponentStatus.normal);
      // Simulate a brief delay for parameter change
      await Future.delayed(Duration(milliseconds: 500));
    } else {
      addAlarm('Unknown component: $componentName', AlarmSeverity.warning);
    }
  }

  Future<void> _setReactionChamberParameters(double temperature, double pressure) async {
    _components['Reaction Chamber']!.setValues['temperature'] = temperature;
    _components['Reaction Chamber']!.setValues['pressure'] = pressure;
    addLogEntry('Setting chamber temperature to $temperature°C and pressure to $pressure atm', ComponentStatus.normal);

    await Future.delayed(Duration(seconds: 5));

    _components['Reaction Chamber']!.currentValues['temperature'] = temperature;
    _components['Reaction Chamber']!.currentValues['pressure'] = pressure;
    addLogEntry('Chamber reached target temperature and pressure', ComponentStatus.normal);
  }

  void updateComponentState(String componentName, Map<String, double> newState) {
    if (_components.containsKey(componentName)) {
      _components[componentName]!.currentValues.addAll(newState);
      notifyListeners();
    }
  }

  void addLogEntry(String message, ComponentStatus severity) {
    _systemLog.add(SystemLogEntry(
      timestamp: DateTime.now(),
      message: message,
      severity: severity,
    ));
    notifyListeners();
  }

  void addAlarm(String message, AlarmSeverity severity) {
    _activeAlarms.add(Alarm(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void acknowledgeAlarm(String alarmId) {
    final alarmIndex = _activeAlarms.indexWhere((alarm) => alarm.id == alarmId);
    if (alarmIndex != -1) {
      _activeAlarms[alarmIndex].acknowledged = true;
      notifyListeners();
    }
  }

  void clearAlarm(String alarmId) {
    _activeAlarms.removeWhere((alarm) => alarm.id == alarmId && alarm.acknowledged);
    notifyListeners();
  }

  void selectRecipe(String id) {
    _selectedRecipe = _recipeProvider.getRecipeById(id);
    if (_selectedRecipe != null) {
      addLogEntry('Recipe selected: ${_selectedRecipe!.name}', ComponentStatus.normal);
    } else {
      addAlarm('Failed to select recipe: Recipe not found', AlarmSeverity.warning);
    }
    notifyListeners();
  }

  void emergencyStop() {
    stopSystem();
    for (var component in _components.values) {
      component.isActivated = false;
    }
    addAlarm('Emergency stop activated', AlarmSeverity.critical);
    addLogEntry('Emergency stop activated', ComponentStatus.error);
    notifyListeners();
  }

  bool isReactorPressureNormal() {
    final pressure = _components['Reaction Chamber']?.currentValues['pressure'] ?? 0.0;
    return pressure >= 0.9 && pressure <= 1.1;
  }

  bool isReactorTemperatureNormal() {
    final temperature = _components['Reaction Chamber']?.currentValues['temperature'] ?? 0.0;
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
    if (_activeRecipe != null && _currentRecipeStepIndex < _activeRecipe!.steps.length - 1) {
      _currentRecipeStepIndex++;
      notifyListeners();
    }
  }

  void completeRecipe() {
    addLogEntry('Recipe completed: ${_activeRecipe?.name}', ComponentStatus.normal);
    _activeRecipe = null;
    _currentRecipeStepIndex = 0;
    _isSystemRunning = false;
    _simulationService.stopSimulation();
    notifyListeners();
  }

  void triggerSafetyAlert(SafetyError error) {
    addAlarm(error.description, _mapSeverityToAlarmSeverity(error.severity));
    addLogEntry('Safety Alert: ${error.description}', _mapSeverityToComponentStatus(error.severity));
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

  SystemComponent? getComponentByName(String name) {
    return _components[name];
  }

  void handleRecipeStep(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        _handleValveStep(step);
        break;
      case StepType.purge:
        _handlePurgeStep(step);
        break;
      case StepType.loop:
        _handleLoopStep(step);
        break;
      case StepType.setParameter:
        _executeSetParameterStep(step);
        break;
    }
  }

  void _handleValveStep(RecipeStep step) {
    ValveType valveType = step.parameters['valveType'] as ValveType;
    int duration = step.parameters['duration'] as int;
    String valveName = valveType == ValveType.valveA ? 'Valve 1' : 'Valve 2';

    updateComponentState(valveName, {'status': 1.0});
    addLogEntry('$valveName opened for $duration seconds', ComponentStatus.normal);

    Future.delayed(Duration(seconds: duration), () {
      updateComponentState(valveName, {'status': 0.0});
      addLogEntry('$valveName closed after $duration seconds', ComponentStatus.normal);
      incrementRecipeStepIndex();
    });
  }

  void _handlePurgeStep(RecipeStep step) {
    int duration = step.parameters['duration'] as int;

    updateComponentState('Valve 1', {'status': 0.0});
    updateComponentState('Valve 2', {'status': 0.0});
    addLogEntry('Purge started for $duration seconds', ComponentStatus.normal);

    Future.delayed(Duration(seconds: duration), () {
      addLogEntry('Purge completed after $duration seconds', ComponentStatus.normal);
      incrementRecipeStepIndex();
    });
  }

  void activateComponent(String name) {
    final component = _components[name];
    if (component != null) {
      component.isActivated = true;
      notifyListeners();
    }
  }

  void _deactivateComponent(String name) {
    if (_components.containsKey(name)) {
      _components[name]!.isActivated = false;
      addLogEntry('$name deactivated', ComponentStatus.normal);
      notifyListeners();
    }
  }

  void deactivateComponent(String name) {
    _deactivateComponent(name);
  }

  void setComponentSetValue(String componentName, String parameter, double value) {
    final component = _components[componentName];
    if (component != null) {
      component.setValues[parameter] = value;
      notifyListeners();
    }
  }

  void runDiagnostic(String componentName) {
    final component = _components[componentName];
    if (component != null) {
      addLogEntry('Running diagnostic for ${component.name}', ComponentStatus.normal);
      Future.delayed(Duration(seconds: 2), () {
        addLogEntry('${component.name} diagnostic completed: All systems nominal', ComponentStatus.normal);
        notifyListeners();
      });
    }
  }

  void _handleLoopStep(RecipeStep step) {
    int iterations = step.parameters['iterations'] as int;
    List<RecipeStep> subSteps = step.subSteps ?? [];

    void executeSubSteps(int currentIteration) {
      if (currentIteration >= iterations) {
        incrementRecipeStepIndex();
        return;
      }

      addLogEntry('Starting loop iteration ${currentIteration + 1} of $iterations', ComponentStatus.normal);

      for (var subStep in subSteps) {
        handleRecipeStep(subStep);
      }

      Future.delayed(Duration(seconds: 1), () {
        executeSubSteps(currentIteration + 1);
      });
    }

    executeSubSteps(0);
  }

  // Helper method to get all recipes (useful for UI that needs to display all recipes)
  List<Recipe> getAllRecipes() {
    return _recipeProvider.recipes;
  }

  // Method to refresh recipes from the RecipeProvider
  void refreshRecipes() {
    _recipeProvider.loadRecipes();
    notifyListeners();
  }
}