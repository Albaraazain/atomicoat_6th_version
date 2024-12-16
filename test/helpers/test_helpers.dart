// test/helpers/test_helpers.dart

import 'package:experiment_planner/features/components/models/system_component.dart';
import 'package:experiment_planner/features/system/repositories/system_state_repository.dart';
import 'package:experiment_planner/features/auth/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';
// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockSystemStateRepository extends Mock implements SystemStateRepository {}

// Test data
class TestData {
  static SystemComponent createTestComponent({
    String name = 'Test Component',
    String description = 'Test Description',
    Map<String, double> currentValues = const {'temperature': 25.0},
    Map<String, double> setValues = const {'temperature': 25.0},
  }) {
    return SystemComponent(
      name: name,
      description: description,
      currentValues: currentValues,
      setValues: setValues,
    );
  }

  static List<SystemComponent> createTestComponents() {
    return [
      createTestComponent(name: 'Component 1'),
      createTestComponent(name: 'Component 2'),
      createTestComponent(name: 'Component 3'),
    ];
  }
}

// Helper functions
void registerFallbackValues() {
  // Register any complex types that will be used in verify() calls
  // Example:
  // registerFallbackValue(FakeSystemComponent());
}