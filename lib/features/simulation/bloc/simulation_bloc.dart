
import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:experiment_planner/features/alarms/bloc/alarm_bloc.dart';
import 'package:experiment_planner/features/alarms/bloc/alarm_event.dart';
import 'package:experiment_planner/features/components/bloc/component_bloc.dart';
import 'package:experiment_planner/features/components/bloc/component_event.dart';
import 'package:experiment_planner/features/components/models/system_component.dart';
import 'package:experiment_planner/features/alarms/models/alarm.dart';
import 'package:experiment_planner/features/safety/bloc/safety_bloc.dart';
import 'package:experiment_planner/features/safety/bloc/safety_event.dart';
import 'package:experiment_planner/features/safety/models/safety_error.dart';
import 'package:experiment_planner/core/utils/bloc_utils.dart';
import 'package:experiment_planner/features/simulation/bloc/simulation_event.dart';
import 'package:experiment_planner/features/simulation/bloc/simulation_state.dart';
import 'package:experiment_planner/features/simulation/models/component_simulation_behavior.dart';
class SimulationBloc extends Bloc<SimulationEvent, SimulationState> {
  final ComponentBloc _componentBloc;
  final AlarmBloc _alarmBloc;
  final SafetyBloc _safetyBloc;
  final Random _random; // Make Random injectable
  Timer? _simulationTimer;

  static const int SIMULATION_INTERVAL_MS = 500;

  SimulationBloc({
    required ComponentBloc componentBloc,
    required AlarmBloc alarmBloc,
    required SafetyBloc safetyBloc,
    Random? random, // Add optional random parameter
  })  : _componentBloc = componentBloc,
        _alarmBloc = alarmBloc,
        _safetyBloc = safetyBloc,
        _random = random ?? Random(), // Use provided random or create new one
        super(SimulationState.initial()) {
    on<StartSimulation>(_onStartSimulation);
    on<StopSimulation>(_onStopSimulation);
    on<SimulationTick>(_onSimulationTick);
    on<UpdateComponentValues>(_onUpdateComponentValues);
    on<CheckSafetyConditions>(_onCheckSafetyConditions);
    on<GenerateRandomError>(_onGenerateRandomError);
  }

  Future<void> _onStartSimulation(
    StartSimulation event,
    Emitter<SimulationState> emit,
  ) async {
    if (state.status == SimulationStatus.running) return;

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(
      const Duration(milliseconds: SIMULATION_INTERVAL_MS),
      (_) => add(SimulationTick()),
    );

    final newState = state.copyWith(
      status: SimulationStatus.running,
      tickCount: 0,
      lastComponentUpdates: {},
    );
    emit(newState);

    _alarmBloc.add(AddAlarm(
      message: 'Simulation started',
      severity: AlarmSeverity.info,
    ));
  }

  Future<void> _onStopSimulation(
    StopSimulation event,
    Emitter<SimulationState> emit,
  ) async {
    _simulationTimer?.cancel();
    _simulationTimer = null;

    // Important: emit state before adding alarm
    emit(state.copyWith(
      status: SimulationStatus.idle,
      lastUpdated: DateTime.now(),
    ));

    _alarmBloc.add(AddAlarm(
      message: 'Simulation stopped',
      severity: AlarmSeverity.info,
    ));
  }

  Future<void> _onGenerateRandomError(
    GenerateRandomError event,
    Emitter<SimulationState> emit,
  ) async {
    final isComponentError = _random.nextBool();

    // Always emit a state to acknowledge the event
    emit(state.copyWith(
      lastUpdated: DateTime.now(),
    ));

    if (isComponentError) {
      final componentName = _getRandomComponent();
      _componentBloc.add(ComponentErrorAdded(
        componentName,
        'Simulated malfunction detected',
      ));

      final component = SystemComponent(
        name: componentName,
        description: '',
        currentValues: {},
        setValues: {},
      );
      component.status = ComponentStatus.error;

      _componentBloc.add(ComponentStatusUpdated(
        componentName,
        component.status,
      ));
    } else {
      _safetyBloc.add(SafetyErrorDetected(
        SafetyError(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: 'Simulated safety error detected',
          severity: _random.nextBool()
              ? SafetyErrorSeverity.warning
              : SafetyErrorSeverity.critical,
        ),
      ));
    }
  }

  Future<void> _onSimulationTick(
    SimulationTick event,
    Emitter<SimulationState> emit,
  ) async {
    if (state.status != SimulationStatus.running) return;

    try {
      // Update component values
      final updates = _generateComponentUpdates();
      if (updates.isNotEmpty) {
        add(UpdateComponentValues(updates));
      }

      // Check safety conditions
      add(CheckSafetyConditions());

      // Occasionally generate random errors
      if (_random.nextDouble() < 0.05) {
        // 5% chance per tick
        add(GenerateRandomError());
      }

      emit(state.copyWith(
        tickCount: state.tickCount + 1,
        lastUpdated: event.timestamp,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: SimulationStatus.error,
        error: BlocUtils.handleError(error),
      ));
    }
  }

  Future<void> _onUpdateComponentValues(
    UpdateComponentValues event,
    Emitter<SimulationState> emit,
  ) async {
    try {
      // Update primary components
      for (var entry in event.updates.entries) {
        _componentBloc.add(ComponentValueUpdated(
          entry.key,
          entry.value,
        ));
      }

      // Handle dependencies
      final dependencyUpdates = _processDependencies(event.updates);
      if (dependencyUpdates.isNotEmpty) {
        for (var entry in dependencyUpdates.entries) {
          _componentBloc.add(ComponentValueUpdated(
            entry.key,
            entry.value,
          ));
        }
      }

      emit(state.copyWith(
        lastComponentUpdates: {
          ...state.lastComponentUpdates,
          for (var component in event.updates.keys) component: DateTime.now(),
        },
      ));
    } catch (error) {
      emit(state.copyWith(error: BlocUtils.handleError(error)));
    }
  }

  Future<void> _onCheckSafetyConditions(
    CheckSafetyConditions event,
    Emitter<SimulationState> emit,
  ) async {
    // Check chamber conditions
    _checkReactionChamber();

    // Check other critical components
    _checkCriticalComponents();
  }

  Map<String, Map<String, double>> _generateComponentUpdates() {
    final updates = <String, Map<String, double>>{};

    for (var entry in state.componentBehaviors.entries) {
      final componentName = entry.key;
      final behavior = entry.value;

      // Get current values from component
      final component = _getComponentState(componentName);
      if (component != null && component.isActivated) {
        final newValues = behavior.generateValues(component.currentValues);

        // Only include if values changed and are valid
        if (_hasValuesChanged(component.currentValues, newValues) &&
            behavior.validateValues(newValues)) {
          updates[componentName] = newValues;
        }
      }
    }

    return updates;
  }

  SystemComponent? _getComponentState(String componentName) {
    try {
      _componentBloc.add(ComponentInitialized(componentName));
      return _componentBloc.state.component;
    } catch (e) {
      return null;
    }
  }

  bool _hasValuesChanged(
    Map<String, double> current,
    Map<String, double> newValues,
  ) {
    return newValues.entries.any((entry) {
      final currentValue = current[entry.key];
      return currentValue == null ||
          (currentValue - entry.value).abs() > 0.0001;
    });
  }

  Map<String, Map<String, double>> _processDependencies(
    Map<String, Map<String, double>> updates,
  ) {
    final dependencyUpdates = <String, Map<String, double>>{};

    for (var entry in updates.entries) {
      final dependencies = state.dependencies[entry.key] ?? [];

      for (var dependentName in dependencies) {
        final behavior = state.componentBehaviors[dependentName];
        if (behavior != null) {
          final currentValues =
              _getComponentState(dependentName)?.currentValues ?? {};
          final newValues = behavior.generateValues(currentValues);

          // Apply dependency factors
          if (entry.key == 'MFC' &&
              dependentName == 'Nitrogen Generator' &&
              entry.value.containsKey('flow_rate')) {
            newValues['flow_rate'] = entry.value['flow_rate']! * 0.8;
          }

          if (behavior.validateValues(newValues)) {
            dependencyUpdates[dependentName] = newValues;
          }
        }
      }
    }

    return dependencyUpdates;
  }

  void _checkReactionChamber() {
    final behavior =
        state.componentBehaviors['Reaction Chamber'] as ReactorChamberBehavior?;
    if (behavior == null) return;

    final chamber = _getComponentState('Reaction Chamber');
    if (chamber != null) {
      final values = chamber.currentValues;
      if (!behavior.validateValues(values)) {
        _safetyBloc.add(SafetyErrorDetected(
          SafetyError(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            description: 'Reaction chamber parameters out of safe range',
            severity: SafetyErrorSeverity.critical,
          ),
        ));
      }
    }
  }

  void _checkCriticalComponents() {
    for (var entry in state.componentBehaviors.entries) {
      if (_isCriticalComponent(entry.key)) {
        final component = _getComponentState(entry.key);
        if (component != null) {
          if (!entry.value.validateValues(component.currentValues)) {
            _safetyBloc.add(SafetyErrorDetected(
              SafetyError(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                description: '${entry.key} parameters out of safe range',
                severity: SafetyErrorSeverity.warning,
              ),
            ));
          }
        }
      }
    }
  }

  bool _isCriticalComponent(String componentName) {
    return [
      'MFC',
      'Pressure Control System',
      'Vacuum Pump',
    ].contains(componentName);
  }

  double _generateNewValue(
      String parameter, double setpoint, double fluctuation) {
    double delta = (_random.nextDouble() * fluctuation * 2) - fluctuation;
    return setpoint + delta;
  }

  double _adjustDependentValue(
    double baseValue,
    double factor,
    double fluctuation,
  ) {
    return baseValue * factor +
        _random.nextDouble() * fluctuation * 2 -
        fluctuation;
  }

  String _getRandomComponent() {
    const components = [
      'Reaction Chamber',
      'MFC',
      'Vacuum Pump',
      'Pressure Control System',
    ];
    return components[_random.nextInt(components.length)];
  }

  @override
  Future<void> close() {
    _simulationTimer?.cancel();
    return super.close();
  }
}
