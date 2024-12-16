
import 'package:equatable/equatable.dart';
import '../models/safety_error.dart';
import '../../../shared/base/base_bloc_event.dart';

sealed class SafetyEvent extends BaseBlocEvent {
  SafetyEvent() : super();
}

class SafetyMonitoringStarted extends SafetyEvent {}

class SafetyMonitoringPaused extends SafetyEvent {}

class SafetyErrorDetected extends SafetyEvent {
  final SafetyError error;
  SafetyErrorDetected(this.error);
}

class SafetyErrorCleared extends SafetyEvent {
  final String errorId;
  SafetyErrorCleared(this.errorId);
}

class SafetyThresholdAdjusted extends SafetyEvent {
  final String componentId;
  final String parameterName;
  final double minThreshold;
  final double maxThreshold;

  SafetyThresholdAdjusted({
    required this.componentId,
    required this.parameterName,
    required this.minThreshold,
    required this.maxThreshold,
  });
}