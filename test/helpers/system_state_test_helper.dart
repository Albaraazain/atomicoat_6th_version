// test/helpers/system_state_test_helper.dart


import 'package:experiment_planner/blocs/system_state/models/system_state_data.dart';

class SystemStateTestHelper {
  static SystemStateData createTestState({
    String id = 'test-id',
    Map<String, dynamic>? data,
    DateTime? timestamp,
  }) {
    return SystemStateData(
      id: id,
      data: data ?? {
        'components': {
          'component1': {
            'isActivated': true,
            'currentValues': {'temperature': 25.0},
            'setValues': {'temperature': 25.0},
            'minValues': {'temperature': 20.0},
            'maxValues': {'temperature': 30.0},
          },
          'component2': {
            'isActivated': true,
            'currentValues': {'pressure': 1.0},
            'setValues': {'pressure': 1.0},
            'minValues': {'pressure': 0.5},
            'maxValues': {'pressure': 1.5},
          },
        },
        'isRunning': false,
        'lastUpdate': DateTime.now().toIso8601String(),
      },
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> createComponentData({
    bool isActivated = true,
    Map<String, double> currentValues = const {'value': 0.0},
    Map<String, double> setValues = const {'value': 0.0},
    Map<String, double> minValues = const {'value': -10.0},
    Map<String, double> maxValues = const {'value': 10.0},
  }) {
    return {
      'isActivated': isActivated,
      'currentValues': currentValues,
      'setValues': setValues,
      'minValues': minValues,
      'maxValues': maxValues,
    };
  }

  static List<String> validateTestState(Map<String, dynamic> state) {
    final issues = <String>[];
    final components = state['components'] as Map<String, dynamic>?;

    if (components == null) {
      issues.add('No components found');
      return issues;
    }

    components.forEach((name, data) {
      final component = data as Map<String, dynamic>;
      if (!component['isActivated']) {
        issues.add('$name is not activated');
      }
    });

    return issues;
  }
}