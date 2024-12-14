// lib/blocs/simulation/bloc/simulation_state.dart

import 'package:experiment_planner/blocs/base/base_bloc_state.dart';
import 'package:experiment_planner/blocs/simulation/models/component_simulation_behavior.dart';
import 'package:experiment_planner/blocs/simulation/models/simulation_config.dart';

enum SimulationStatus { idle, running, paused, error }

class SimulationState extends BaseBlocState {
  final SimulationStatus status;
  final int tickCount;
  final Map<String, DateTime> lastComponentUpdates;
  final Map<String, List<String>> dependencies;

  final Map<String, ComponentBehavior> componentBehaviors;

  SimulationState({
    required super.isLoading,
    super.error,
    super.lastUpdated,
    required this.status,
    required this.tickCount,
    required this.lastComponentUpdates,
    required this.dependencies,
    required this.componentBehaviors, // Add this
  });

  factory SimulationState.initial() {
    return SimulationState(
      isLoading: false,
      status: SimulationStatus.idle,
      tickCount: 0,
      lastComponentUpdates: const {},
      dependencies: const {
        'MFC': ['Nitrogen Generator'],
        'Pressure Control System': ['Reaction Chamber'],
      },
      componentBehaviors: SimulationConfig.componentBehaviors, // Add this
    );
  }

  SimulationState copyWith({
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    SimulationStatus? status,
    int? tickCount,
    Map<String, DateTime>? lastComponentUpdates,
    Map<String, List<String>>? dependencies,
    Map<String, ComponentBehavior>? componentBehaviors,
  }) {
    return SimulationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      tickCount: tickCount ?? this.tickCount,
      lastComponentUpdates: lastComponentUpdates ?? this.lastComponentUpdates,
      dependencies: dependencies ?? this.dependencies,
      componentBehaviors: componentBehaviors ?? this.componentBehaviors,
    );
  }
}
