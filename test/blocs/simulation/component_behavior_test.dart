// test/blocs/simulation/component_behavior_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/blocs/simulation/models/component_simulation_behavior.dart';

void main() {
  group('ReactorChamberBehavior', () {
    late ReactorChamberBehavior behavior;

    setUp(() {
      behavior = ReactorChamberBehavior();
    });

    test('generates valid temperature and pressure values', () {
      final currentValues = {'temperature': 150.0, 'pressure': 1.0};
      final newValues = behavior.generateValues(currentValues);

      expect(newValues.keys, containsAll(['temperature', 'pressure']));
      expect(newValues['temperature']!, inInclusiveRange(145.0, 155.0));
      expect(newValues['pressure']!, inInclusiveRange(0.9, 1.1));
    });

    test('validates values within acceptable ranges', () {
      expect(behavior.validateValues({
        'temperature': 150.0,
        'pressure': 1.0,
      }), isTrue);

      expect(behavior.validateValues({
        'temperature': 350.0,  // Too high
        'pressure': 1.0,
      }), isFalse);

      expect(behavior.validateValues({
        'temperature': 150.0,
        'pressure': 15.0,  // Too high
      }), isFalse);
    });
  });

  group('MFCBehavior', () {
    late MFCBehavior behavior;

    setUp(() {
      behavior = MFCBehavior();
    });

    test('generates valid flow rate values', () {
      final currentValues = {
        'flow_rate': 50.0,
        'pressure': 1.0,
        'setpoint': 50.0,
      };
      final newValues = behavior.generateValues(currentValues);

      expect(newValues.keys, containsAll(['flow_rate', 'pressure']));
      expect(newValues['flow_rate']!, inInclusiveRange(45.0, 55.0));
      expect(newValues['pressure']!, inInclusiveRange(0.95, 1.05));
    });

    test('moves flow rate towards setpoint', () {
      final currentValues = {
        'flow_rate': 40.0,
        'pressure': 1.0,
        'setpoint': 50.0,
      };
      final newValues = behavior.generateValues(currentValues);

      expect(newValues['flow_rate']!, greaterThan(40.0));
    });
  });

  group('ValveBehavior', () {
    late ValveBehavior behavior;

    setUp(() {
      behavior = ValveBehavior();
    });

    test('maintains binary valve state', () {
      expect(
        behavior.generateValues({'status': 0.0})['status'],
        equals(0.0),
      );
      expect(
        behavior.generateValues({'status': 1.0})['status'],
        equals(1.0),
      );
    });

    test('validates only binary values', () {
      expect(behavior.validateValues({'status': 0.0}), isTrue);
      expect(behavior.validateValues({'status': 1.0}), isTrue);
      expect(behavior.validateValues({'status': 0.5}), isFalse);
    });
  });
}