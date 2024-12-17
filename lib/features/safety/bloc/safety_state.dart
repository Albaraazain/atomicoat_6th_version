import '../../../shared/base/base_bloc_state.dart';
import '../models/safety_error.dart';
import '../services/monitoring_service.dart';

class SafetyState extends BaseBlocState {
  final bool isMonitoringActive;
  final List<SafetyError> activeErrors;
  final Map<String, Map<String, SafetyThreshold>> thresholds;
  final MonitoringStatus? lastStatus;

  SafetyState({
    required super.isLoading,
    super.error,
    super.lastUpdated,
    required this.isMonitoringActive,
    required this.activeErrors,
    required this.thresholds,
    this.lastStatus,
  });

  factory SafetyState.initial() {
    return SafetyState(
      isLoading: false,
      isMonitoringActive: false,
      activeErrors: const [],
      thresholds: const {},
      lastStatus: null,
    );
  }

  SafetyState copyWith({
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    bool? isMonitoringActive,
    List<SafetyError>? activeErrors,
    Map<String, Map<String, SafetyThreshold>>? thresholds,
    MonitoringStatus? lastStatus,
  }) {
    return SafetyState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isMonitoringActive: isMonitoringActive ?? this.isMonitoringActive,
      activeErrors: activeErrors ?? this.activeErrors,
      thresholds: thresholds ?? this.thresholds,
      lastStatus: lastStatus ?? this.lastStatus,
    );
  }
}

class SafetyThreshold {
  final double min;
  final double max;

  const SafetyThreshold({required this.min, required this.max});
}