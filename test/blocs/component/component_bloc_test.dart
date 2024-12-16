// test/blocs/component/component_bloc_test.dart

import 'package:experiment_planner/blocs/component/bloc/component_bloc.dart';
import 'package:experiment_planner/blocs/component/bloc/component_event.dart';
import 'package:experiment_planner/blocs/component/bloc/component_state.dart';
import 'package:experiment_planner/blocs/component/repository/component_repository.dart';
import 'package:experiment_planner/features/components/models/system_component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

// Create mocks
class MockComponentRepository extends Mock implements ComponentRepository {}

// Create a fake for SystemComponent
class FakeSystemComponent extends Fake implements SystemComponent {
  @override
  String get name => 'Fake Component';

  @override
  Map<String, double> get currentValues => {'test': 0.0};

  @override
  Map<String, double> get setValues => {'test': 0.0};
}

void main() {
  late ComponentBloc componentBloc;
  late MockComponentRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeSystemComponent());
  });

  // Test component data
  final testComponent = SystemComponent(
    name: 'Test Component',
    description: 'Test Description',
    currentValues: {'temperature': 25.0},
    setValues: {'temperature': 25.0},
  );

  setUp(() {
    mockRepository = MockComponentRepository();
    componentBloc = ComponentBloc(mockRepository);
  });

  tearDown(() {
    componentBloc.close();
  });

  group('ComponentBloc', () {
    test('initial state is correct', () {
      expect(componentBloc.state, ComponentState.initial());
    });

    blocTest<ComponentBloc, ComponentState>(
      'emits [loading, loaded] when component is initialized successfully',
      build: () {
        when(() => mockRepository.getComponent(any()))
            .thenAnswer((_) async => testComponent);
        when(() => mockRepository.watchComponent(any()))
            .thenAnswer((_) => Stream.fromIterable([testComponent]));
        return componentBloc;
      },
      act: (bloc) => bloc.add(ComponentInitialized('Test Component')),
      expect: () => [
        ComponentState.loading(),
        ComponentState.loaded(testComponent),
      ],
    );

    blocTest<ComponentBloc, ComponentState>(
      'emits [loading, error] when component initialization fails',
      build: () {
        when(() => mockRepository.getComponent(any()))
            .thenThrow(Exception('Failed to load component'));
        return componentBloc;
      },
      act: (bloc) => bloc.add(ComponentInitialized('Test Component')),
      expect: () => [
        ComponentState.loading(),
        ComponentState.error('Exception: Failed to load component'),
      ],
    );

    blocTest<ComponentBloc, ComponentState>(
      'updates current values correctly',
      build: () {
        when(() => mockRepository.getComponent(any()))
            .thenAnswer((_) async => testComponent);
        when(() => mockRepository.watchComponent(any()))
            .thenAnswer((_) => Stream.value(testComponent));
        when(() => mockRepository.saveComponentState(any()))
            .thenAnswer((_) async {});
        return componentBloc;
      },
      seed: () => ComponentState.loaded(testComponent),
      act: (bloc) => bloc.add(
        ComponentValueUpdated(
          'Test Component',
          {'temperature': 30.0},
        ),
      ),
      verify: (_) {
        verify(() => mockRepository.saveComponentState(any())).called(1);
      },
    );

    blocTest<ComponentBloc, ComponentState>(
      'toggles activation correctly',
      build: () {
        when(() => mockRepository.saveComponentState(any()))
            .thenAnswer((_) async {});
        return componentBloc;
      },
      seed: () => ComponentState.loaded(testComponent),
      act: (bloc) => bloc.add(
        ComponentActivationToggled('Test Component', true),
      ),
      verify: (_) {
        verify(() => mockRepository.saveComponentState(any())).called(1);
      },
    );

    blocTest<ComponentBloc, ComponentState>(
      'adds error message correctly',
      build: () {
        when(() => mockRepository.saveComponentState(any()))
            .thenAnswer((_) async {});
        return componentBloc;
      },
      seed: () => ComponentState.loaded(testComponent),
      act: (bloc) => bloc.add(
        ComponentErrorAdded('Test Component', 'Test Error'),
      ),
      verify: (_) {
        verify(() => mockRepository.saveComponentState(any())).called(1);
      },
    );
  });
}
