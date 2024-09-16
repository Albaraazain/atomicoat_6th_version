import 'system_component.dart';

class SystemLogEntry {
  final DateTime timestamp;
  final String message;
  final ComponentStatus severity;

  SystemLogEntry({
    required this.timestamp,
    required this.message,
    required this.severity,
  });
}
