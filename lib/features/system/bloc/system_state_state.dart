// lib/blocs/system_state/bloc/system_state_state.dart

import '../../../shared/base/base_bloc_state.dart';
import '../../components/models/system_component.dart';

enum SystemOperationalStatus {
  uninitialized,
  initializing,
  ready,
  running,
  stopped,
  error,
  emergencyStopped
}

class SystemStateState extends BaseBlocState {
  final SystemOperationalStatus status;
  final bool isSystemRunning;
  final List<String> systemIssues;
  final Map<String, dynamic> currentSystemState;
  final DateTime? lastStateUpdate;
  final bool isReadinessCheckPassed;
  final List<SystemComponent> components;  // Added components field

  SystemStateState({
    this.status = SystemOperationalStatus.uninitialized,
    this.isSystemRunning = false,
    this.systemIssues = const [],
    this.currentSystemState = const {},
    this.lastStateUpdate,
    this.isReadinessCheckPassed = false,
    bool isLoading = false,
    String? error,
    DateTime? lastUpdated,
    this.components = const [],  // Added components initialization
  }) : super(
          isLoading: isLoading,
          error: error,
          lastUpdated: lastUpdated,
        );

  SystemStateState copyWith({
    SystemOperationalStatus? status,
    bool? isSystemRunning,
    List<String>? systemIssues,
    Map<String, dynamic>? currentSystemState,
    DateTime? lastStateUpdate,
    bool? isReadinessCheckPassed,
    bool? isLoading,
    String? error,
    List<SystemComponent>? components,  // Added components to copyWith
  }) {
    return SystemStateState(
      status: status ?? this.status,
      isSystemRunning: isSystemRunning ?? this.isSystemRunning,
      systemIssues: systemIssues ?? this.systemIssues,
      currentSystemState: currentSystemState ?? this.currentSystemState,
      lastStateUpdate: lastStateUpdate ?? this.lastStateUpdate,
      isReadinessCheckPassed: isReadinessCheckPassed ?? this.isReadinessCheckPassed,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      components: components ?? this.components,  // Added components
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    status,
    isSystemRunning,
    systemIssues,
    currentSystemState,
    lastStateUpdate,
    isReadinessCheckPassed,
    components,  // Added components to props
  ];

  bool get isReady => status == SystemOperationalStatus.ready;
  bool get canStart => isReady && !isSystemRunning && systemIssues.isEmpty;
  bool get canStop => isSystemRunning;
  bool get isError => status == SystemOperationalStatus.error;
  bool get isEmergencyStopped => status == SystemOperationalStatus.emergencyStopped;
}