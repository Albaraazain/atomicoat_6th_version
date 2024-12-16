// lib/blocs/simulation/models/component_simulation_behavior.dart
import 'dart:math';

abstract class ComponentBehavior {
  Map<String, double> generateValues(Map<String, double> currentValues);
  bool validateValues(Map<String, double> values);
  Map<String, double> getDefaultValues();
}

class ReactorChamberBehavior implements ComponentBehavior {
  final Random _random = Random();
  static const double TEMPERATURE_FLUCTUATION = 2.0;
  static const double PRESSURE_FLUCTUATION = 0.05;

  @override
  Map<String, double> generateValues(Map<String, double> currentValues) {
    final temperature = currentValues['temperature'] ?? 150.0;
    final pressure = currentValues['pressure'] ?? 1.0;

    return {
      'temperature': _generateTemperature(temperature),
      'pressure': _generatePressure(pressure),
    };
  }

  double _generateTemperature(double current) {
    final delta = (_random.nextDouble() * TEMPERATURE_FLUCTUATION * 2) - TEMPERATURE_FLUCTUATION;
    return current + delta;
  }

  double _generatePressure(double current) {
    final delta = (_random.nextDouble() * PRESSURE_FLUCTUATION * 2) - PRESSURE_FLUCTUATION;
    return (current + delta).clamp(0.0, 10.0);
  }

  @override
  bool validateValues(Map<String, double> values) {
    final temperature = values['temperature'];
    final pressure = values['pressure'];

    if (temperature == null || pressure == null) return false;

    return temperature >= 100.0 &&
           temperature <= 300.0 &&
           pressure >= 0.1 &&
           pressure <= 10.0;
  }

  @override
  Map<String, double> getDefaultValues() => {
    'temperature': 150.0,
    'pressure': 1.0,
  };
}

class MFCBehavior implements ComponentBehavior {
  final Random _random = Random();
  static const double FLOW_FLUCTUATION = 0.5;

  @override
  Map<String, double> generateValues(Map<String, double> currentValues) {
    final flowRate = currentValues['flow_rate'] ?? 0.0;
    final setpoint = currentValues['setpoint'] ?? flowRate;

    return {
      'flow_rate': _generateFlowRate(flowRate, setpoint),
      'pressure': _generatePressure(currentValues['pressure'] ?? 1.0),
    };
  }

  double _generateFlowRate(double current, double setpoint) {
    // Gradually move towards setpoint with noise
    final difference = setpoint - current;
    final step = difference * 0.1; // 10% movement towards setpoint
    final noise = (_random.nextDouble() * FLOW_FLUCTUATION * 2) - FLOW_FLUCTUATION;
    return (current + step + noise).clamp(0.0, 100.0);
  }

  double _generatePressure(double current) {
    const fluctuation = 0.02;
    final delta = (_random.nextDouble() * fluctuation * 2) - fluctuation;
    return (current + delta).clamp(0.5, 2.0);
  }

  @override
  bool validateValues(Map<String, double> values) {
    final flowRate = values['flow_rate'];
    final pressure = values['pressure'];

    if (flowRate == null || pressure == null) return false;

    return flowRate >= 0.0 &&
           flowRate <= 100.0 &&
           pressure >= 0.5 &&
           pressure <= 2.0;
  }

  @override
  Map<String, double> getDefaultValues() => {
    'flow_rate': 0.0,
    'pressure': 1.0,
  };
}

class ValveBehavior implements ComponentBehavior {
  @override
  Map<String, double> generateValues(Map<String, double> currentValues) {
    // Valves are binary - they don't need fluctuation
    return {'status': currentValues['status'] ?? 0.0};
  }

  @override
  bool validateValues(Map<String, double> values) {
    final status = values['status'];
    if (status == null) return false;
    return status == 0.0 || status == 1.0;
  }

  @override
  Map<String, double> getDefaultValues() => {
    'status': 0.0,
  };
}

class HeaterBehavior implements ComponentBehavior {
  final Random _random = Random();
  static const double TEMPERATURE_FLUCTUATION = 1.0;

  @override
  Map<String, double> generateValues(Map<String, double> currentValues) {
    final temperature = currentValues['temperature'] ?? 25.0;
    final setpoint = currentValues['setpoint'] ?? temperature;

    return {
      'temperature': _generateTemperature(temperature, setpoint),
    };
  }

  double _generateTemperature(double current, double setpoint) {
    final difference = setpoint - current;
    final step = difference * 0.05; // 5% movement towards setpoint
    final noise = (_random.nextDouble() * TEMPERATURE_FLUCTUATION * 2) - TEMPERATURE_FLUCTUATION;
    return current + step + noise;
  }

  @override
  bool validateValues(Map<String, double> values) {
    final temperature = values['temperature'];
    if (temperature == null) return false;
    return temperature >= 0.0 && temperature <= 400.0;
  }

  @override
  Map<String, double> getDefaultValues() => {
    'temperature': 25.0,
  };
}