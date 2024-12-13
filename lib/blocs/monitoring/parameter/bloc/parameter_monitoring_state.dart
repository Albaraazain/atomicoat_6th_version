// lib/blocs/monitoring/parameter/bloc/parameter_monitoring_state.dart
import '../../../base/base_bloc_state.dart';

class ParameterMonitoringState extends BaseBlocState {
  final Map<String, bool> monitoringStatus;
  final Map<String, Map<String, double>> currentValues;
  final Map<String, Map<String, Map<String, double>>> thresholds;
  final Map<String, Map<String, bool>> violations;

  ParameterMonitoringState({
    required super.isLoading,
    super.error,
    super.lastUpdated,
    required this.monitoringStatus,
    required this.currentValues,
    required this.thresholds,
    required this.violations,
  });

  factory ParameterMonitoringState.initial() {
    return ParameterMonitoringState(
      isLoading: false,
      monitoringStatus: const {},
      currentValues: const {},
      thresholds: const {},
      violations: const {},
    );
  }

  ParameterMonitoringState copyWith({
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    Map<String, bool>? monitoringStatus,
    Map<String, Map<String, double>>? currentValues,
    Map<String, Map<String, Map<String, double>>>? thresholds,
    Map<String, Map<String, bool>>? violations,
  }) {
    return ParameterMonitoringState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      monitoringStatus: monitoringStatus ?? this.monitoringStatus,
      currentValues: currentValues ?? this.currentValues,
      thresholds: thresholds ?? this.thresholds,
      violations: violations ?? this.violations,
    );
  }
}