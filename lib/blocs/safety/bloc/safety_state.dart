// lib/blocs/safety/bloc/safety_state.dart
import '../../base/base_bloc_state.dart';
import '../../../modules/system_operation_also_main_module/models/safety_error.dart';

class SafetyState extends BaseBlocState {
  final bool isMonitoringActive;
  final List<SafetyError> activeErrors;
  final Map<String, Map<String, SafetyThreshold>> thresholds;

  SafetyState({
    required super.isLoading,
    super.error,
    super.lastUpdated,
    required this.isMonitoringActive,
    required this.activeErrors,
    required this.thresholds,
  });

  factory SafetyState.initial() {
    return SafetyState(
      isLoading: false,
      isMonitoringActive: false,
      activeErrors: const [],
      thresholds: const {},
    );
  }

  SafetyState copyWith({
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    bool? isMonitoringActive,
    List<SafetyError>? activeErrors,
    Map<String, Map<String, SafetyThreshold>>? thresholds,
  }) {
    return SafetyState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isMonitoringActive: isMonitoringActive ?? this.isMonitoringActive,
      activeErrors: activeErrors ?? this.activeErrors,
      thresholds: thresholds ?? this.thresholds,
    );
  }
}

class SafetyThreshold {
  final double min;
  final double max;

  const SafetyThreshold({required this.min, required this.max});
}