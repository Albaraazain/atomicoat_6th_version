// lib/services/ald_system_simulation_service.dart

import 'dart:async';
import 'dart:math';
import '../providers/system_state_provider.dart';

class AldSystemSimulationService {
  final SystemStateProvider systemStateProvider;
  Timer? _simulationTimer;
  final Random _random = Random();

  // Define dependencies where certain components affect others
  final Map<String, List<String>> _dependencies = {
    'MFC': ['Nitrogen Generator'],
    'Pressure Control System': ['Reaction Chamber'],
    // Additional dependencies can be added here
  };

  AldSystemSimulationService({required this.systemStateProvider});

  /// Starts the simulation by initiating a periodic timer.
  void startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (_) => _simulateTick());
    print("Simulation started.");
  }

  /// Stops the simulation by canceling the periodic timer.
  void stopSimulation() {
    _simulationTimer?.cancel();
    print("Simulation stopped.");
  }

  /// The main simulation tick that updates component states and generates random errors.
  void _simulateTick() {
    _updateComponentStates();
    _generateRandomErrors();
    // No need to call notifyListeners() here since updateComponentState does it internally
  }

  /// Updates the states of all active components based on their set values and random fluctuations.
  void _updateComponentStates() {
    Map<String, Map<String, double>> updates = {};

    for (var component in systemStateProvider.components.values) {
      Map<String, double> componentUpdates = {};

      component.currentValues.forEach((parameter, value) {
        double newValue;
        if (component.isActivated) {
          newValue = _generateNewValue(component.name, parameter, value);
        } else {
          double targetValue = systemStateProvider.components[component.name]!.setValues[parameter] ?? value;
          newValue = _moveTowards(value, targetValue, step: 0.05);
        }

        // Clamp the new value within the defined bounds for the parameter
        newValue = _clampValue(component.name, parameter, newValue);

        componentUpdates[parameter] = newValue;
      });

      if (componentUpdates.isNotEmpty) {
        updates[component.name] = componentUpdates;
      }
    }

    // Apply all calculated updates to the system state provider
    updates.forEach((componentName, newStates) {
      systemStateProvider.updateComponentState(componentName, newStates);
    });

    // Handle any dependencies between components
    _applyDependencies(updates);
  }

  /// Clamps the parameter value within its defined minimum and maximum bounds.
  double _clampValue(String componentName, String parameter, double value) {
    switch (parameter) {
      case 'flow_rate':
        return value.clamp(0.0, 100.0);
      case 'temperature':
        return value.clamp(0.0, 300.0); // Celsius
      case 'pressure':
        return value.clamp(0.0, 2.0); // Atmospheres
      case 'power':
        return value.clamp(0.0, 100.0); // Percentage
      case 'status':
        return value.clamp(0.0, 1.0); // 0: Closed, 1: Open
      default:
        return value;
    }
  }

  /// Applies dependencies where updates in one component affect others.
  void _applyDependencies(Map<String, Map<String, double>> updates) {
    updates.forEach((componentName, newStates) {
      if (_dependencies.containsKey(componentName)) {
        for (var dependentName in _dependencies[componentName]!) {
          var dependentComponent = systemStateProvider.getComponentByName(dependentName);
          if (dependentComponent != null) {
            // Adjust Nitrogen Generator's flow_rate based on MFC's flow_rate
            if (componentName == 'MFC' && newStates.containsKey('flow_rate')) {
              double mfcFlowRate = newStates['flow_rate']!;
              double adjustedFlowRate = mfcFlowRate * 0.8 + _random.nextDouble() * 0.4 - 0.2; // ±0.2 fluctuation
              adjustedFlowRate = _moveTowards(dependentComponent.currentValues['flow_rate']!, adjustedFlowRate, step: 0.05);
              systemStateProvider.updateComponentState(dependentName, {'flow_rate': adjustedFlowRate});
              print("Adjusted $dependentName's flow_rate to $adjustedFlowRate based on $componentName.");
            }

            // Adjust Reaction Chamber's pressure based on Pressure Control System's pressure
            if (componentName == 'Pressure Control System' && newStates.containsKey('pressure')) {
              double pcsPressure = newStates['pressure']!;
              double adjustedPressure = pcsPressure * 0.9 + _random.nextDouble() * 0.2 - 0.1; // ±0.1 fluctuation
              adjustedPressure = _moveTowards(dependentComponent.currentValues['pressure']!, adjustedPressure, step: 0.05);
              systemStateProvider.updateComponentState(dependentName, {'pressure': adjustedPressure});
              print("Adjusted $dependentName's pressure to $adjustedPressure based on $componentName.");
            }

            // Additional dependency logic can be implemented here
          }
        }
      }
    });
  }

  /// Generates random errors based on active alarms affecting system components.
  void _generateRandomErrors() {
    for (var alarm in systemStateProvider.activeAlarms) {
      if (alarm.message.contains('Mass Flow Controller Malfunction')) {
        systemStateProvider.updateComponentState('MFC', {'flow_rate': 0.0});
        print("Error: Mass Flow Controller Malfunction detected. Setting MFC flow_rate to 0.0.");
      }
      // Additional error conditions can be handled here
    }
  }

  /// Generates a new value for a component's parameter with random fluctuations around the set value.
  double _generateNewValue(String componentName, String parameter, double currentValue) {
    double fluctuationRange;

    // Define fluctuation ranges based on the parameter type
    switch (parameter) {
      case 'flow_rate':
        fluctuationRange = 2.0; // ±2 units
        break;
      case 'temperature':
        fluctuationRange = 5.0; // ±5 degrees
        break;
      case 'pressure':
        fluctuationRange = 0.05; // ±0.05 atm
        break;
      case 'power':
        fluctuationRange = 1.0; // ±1%
        break;
      case 'status':
        fluctuationRange = 0.05; // ±0.05 (for binary-like status)
        break;
      default:
        fluctuationRange = 1.0; // Default fluctuation
    }

    // Generate a random fluctuation within the specified range
    double delta = (_random.nextDouble() * fluctuationRange * 2) - fluctuationRange;

    // Retrieve the setpoint for the parameter
    double setpoint = systemStateProvider.components[componentName]!.setValues[parameter] ?? currentValue;

    // Move the current value towards the setpoint with a stabilization step
    double stabilizedValue = _moveTowards(currentValue, setpoint, step: 0.1);

    // Apply random fluctuation
    double newValue = stabilizedValue + delta;

    // Prevent excessive fluctuation by moving the new value towards the setpoint again
    newValue = _moveTowards(newValue, setpoint, step: 0.2);

    // Clamp the final value within defined bounds
    newValue = _clampValue(componentName, parameter, newValue);

    return newValue;
  }

  /// Smoothly moves a value towards a target by a specified step.
  double _moveTowards(double current, double target, {required double step}) {
    if (current < target) {
      return (current + step).clamp(current, target);
    } else if (current > target) {
      return (current - step).clamp(target, current);
    } else {
      return current;
    }
  }
}
