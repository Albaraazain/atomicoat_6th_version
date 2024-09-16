// lib/core/services/ald_system_simulation_service.dart

import 'dart:async';
import 'dart:math';
import '../models/system_component.dart';
import '../models/recipe.dart';
import '../models/data_point.dart';
import '../models/safety_error.dart';
import '../providers/system_state_provider.dart';

class AldSystemSimulationService {
  final SystemStateProvider systemStateProvider;
  Timer? _simulationTimer;
  final Random _random = Random();

  final List<SafetyError> _possibleErrors = [
    SafetyError(
      id: 'E1',
      description: 'Reactor Pressure Exceeded Safe Limit',
      severity: SafetyErrorSeverity.critical,
    ),
    SafetyError(
      id: 'E2',
      description: 'Chamber Temperature Dropped Below Minimum',
      severity: SafetyErrorSeverity.warning,
    ),
    SafetyError(
      id: 'E3',
      description: 'Mass Flow Controller Malfunction',
      severity: SafetyErrorSeverity.critical,
    ),
    SafetyError(
      id: 'E4',
      description: 'Precursor Heater 1 Overheating',
      severity: SafetyErrorSeverity.warning,
    ),
    SafetyError(
      id: 'E5',
      description: 'Vacuum Pump Performance Degraded',
      severity: SafetyErrorSeverity.warning,
    ),
  ];

  final Map<String, double> _errorProbabilities = {
    'E1': 0.01,
    'E2': 0.02,
    'E3': 0.005,
    'E4': 0.015,
    'E5': 0.01,
  };

  AldSystemSimulationService({required this.systemStateProvider});

  void _updateComponentStates() {
    for (var component in systemStateProvider.components.values) {
      component.currentValues.forEach((parameter, value) {
        double newValue;
        if (component.isActivated) {
          newValue = _generateNewValue(component.name, parameter, value);
        } else {
          // If component is not activated, simulate a slow drift towards its set value or a default value
          double targetValue = component.setValues[parameter] ?? value;
          newValue = value + (targetValue - value) * 0.01;
        }
        component.currentValues[parameter] = newValue;
        component.parameterHistory[parameter]?.add(
          DataPoint(timestamp: DateTime.now(), value: newValue),
        );

        if (component.parameterHistory[parameter]!.length > 100) {
          component.parameterHistory[parameter]!.removeAt(0);
        }
      });
    }
  }

  double _generateNewValue(String componentName, String parameter, double currentValue) {
    double delta = (_random.nextDouble() - 0.5) * 0.2; // Increased fluctuation

    switch (componentName) {
      case 'Reaction Chamber':
        if (parameter == 'temperature') {
          return _simulateTemperature(currentValue, delta);
        } else if (parameter == 'pressure') {
          return _simulatePressure(currentValue, delta);
        }
        break;
      case 'MFC':
        if (parameter == 'flow_rate') {
          return _simulateFlowRate(currentValue, delta);
        }
        break;
      case 'Nitrogen Generator':
        if (parameter == 'flow_rate') {
          return _simulateFlowRate(currentValue, delta);
        } else if (parameter == 'purity') {
          return _simulatePurity(currentValue, delta);
        }
        break;
      case 'Precursor Heater 1':
      case 'Precursor Heater 2':
        if (parameter == 'temperature') {
          return _simulateTemperature(currentValue, delta);
        } else if (parameter == 'fill_level') {
          return _simulateFillLevel(currentValue, delta);
        }
        break;
      case 'Vacuum Pump':
        if (parameter == 'power') {
          return _simulatePower(currentValue, delta);
        }
        break;
    }

    return (currentValue + delta).clamp(0, 100);
  }


  void startSimulation() {
    _simulationTimer = Timer.periodic(Duration(seconds: 1), (_) => _simulateTick());
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
  }

  void _simulateTick() {
    _updateComponentStates();
    _executeRecipeStep();
    _generateRandomErrors();
    systemStateProvider.notifyListeners();
  }

  double _simulateTemperature(double currentValue, double delta) {
    double setpoint = systemStateProvider.components['Reaction Chamber']!.setValues['temperature'] ?? 150.0;
    return (currentValue + (setpoint - currentValue) * 0.2 + delta).clamp(0, 300);
  }

  double _simulatePressure(double currentValue, double delta) {
    return (currentValue + delta * 0.05).clamp(0.5, 2.0);
  }

  double _simulateFlowRate(double currentValue, double delta) {
    double setpoint = systemStateProvider.components['MFC']!.setValues['flow_rate'] ?? 50.0;
    return (currentValue + (setpoint - currentValue) * 0.3 + delta).clamp(0, 100);
  }

  void _generateRandomErrors() {
    for (var error in _possibleErrors) {
      double probability = _errorProbabilities[error.id] ?? 0.0;
      if (_random.nextDouble() < probability) {
        systemStateProvider.triggerSafetyAlert(error);
      }
    }
  }

  void _executeRecipeStep() {
    if (systemStateProvider.activeRecipe != null && systemStateProvider.isSystemRunning) {
      Recipe activeRecipe = systemStateProvider.activeRecipe!;
      int currentStepIndex = systemStateProvider.currentRecipeStepIndex;

      if (currentStepIndex < activeRecipe.steps.length) {
        RecipeStep currentStep = activeRecipe.steps[currentStepIndex];
        _executeStep(currentStep);

        systemStateProvider.incrementRecipeStepIndex();
      } else {
        systemStateProvider.completeRecipe();
      }
    }
  }

  void _executeStep(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        _simulateValveStep(step);
        break;
      case StepType.purge:
        _simulatePurgeStep(step);
        break;
      case StepType.loop:
        _simulateLoopStep(step);
        break;
    }
  }



  void _simulateValveStep(RecipeStep step) {
    ValveType valveType = step.parameters['valveType'] as ValveType;
    int duration = step.parameters['duration'] as int;
    String valveName = valveType == ValveType.valveA ? 'Valve 1' : 'Valve 2';

    systemStateProvider.updateComponentState(valveName, {'status': 1.0});
    systemStateProvider.addLogEntry('$valveName opened for $duration seconds', ComponentStatus.normal);

    Future.delayed(Duration(seconds: duration), () {
      systemStateProvider.updateComponentState(valveName, {'status': 0.0});
      systemStateProvider.addLogEntry('$valveName closed after $duration seconds', ComponentStatus.normal);
    });
  }

  void _simulatePurgeStep(RecipeStep step) {
    int duration = step.parameters['duration'] as int;

    systemStateProvider.updateComponentState('Valve 1', {'status': 0.0});
    systemStateProvider.updateComponentState('Valve 2', {'status': 0.0});
    systemStateProvider.addLogEntry('Purge started for $duration seconds', ComponentStatus.normal);

    Future.delayed(Duration(seconds: duration), () {
      systemStateProvider.addLogEntry('Purge completed after $duration seconds', ComponentStatus.normal);
    });
  }

  void _simulateLoopStep(RecipeStep step) {
    int iterations = step.parameters['iterations'] as int;
    List<RecipeStep> subSteps = step.subSteps ?? [];

    for (int i = 0; i < iterations; i++) {
      systemStateProvider.addLogEntry('Starting loop iteration ${i + 1} of $iterations', ComponentStatus.normal);
      for (var subStep in subSteps) {
        _executeStep(subStep);
      }
    }

    systemStateProvider.addLogEntry('Loop completed after $iterations iterations', ComponentStatus.normal);
  }


  double _simulatePurity(double currentValue, double delta) {
    return (currentValue + delta * 0.1).clamp(95, 100);
  }

  double _simulateFillLevel(double currentValue, double delta) {
    return (currentValue - _random.nextDouble() * 0.1).clamp(0, 100);
  }

  double _simulatePower(double currentValue, double delta) {
    return (currentValue + delta * 2).clamp(0, 100);
  }

}