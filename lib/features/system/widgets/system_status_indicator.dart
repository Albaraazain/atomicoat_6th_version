

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/alarm/bloc/alarm_bloc.dart';
import '../../../blocs/alarm/bloc/alarm_state.dart';
import '../../../blocs/system_state/bloc/system_state_bloc.dart';
import '../../../blocs/system_state/bloc/system_state_state.dart';
import '../../alarms/models/alarm.dart';

class SystemStatusIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemStateBloc, SystemStateState>(
      builder: (context, systemState) {
        return BlocBuilder<AlarmBloc, AlarmState>(
          builder: (context, alarmState) {
            final status = _determineSystemStatus(systemState, alarmState);
            return GestureDetector(
              onTap: () => _showStatusDetails(context, status, systemState, alarmState),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(status),
                    color: _getStatusColor(status),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  SystemStatus _determineSystemStatus(SystemStateState systemState, AlarmState alarmState) {
    if (alarmState.hasCriticalAlarms) {
      return SystemStatus.error;
    } else if (alarmState.hasActiveAlarms) {
      return SystemStatus.warning;
    } else if (systemState.isSystemRunning) {
      return SystemStatus.running;
    } else if (systemState.isReadinessCheckPassed) {
      return SystemStatus.ready;
    } else {
      return SystemStatus.stopped;
    }
  }

  IconData _getStatusIcon(SystemStatus status) {
    switch (status) {
      case SystemStatus.running:
        return Icons.play_circle_outline;
      case SystemStatus.ready:
        return Icons.check_circle_outline;
      case SystemStatus.stopped:
        return Icons.stop_circle_outlined;
      case SystemStatus.warning:
        return Icons.warning_amber_rounded;
      case SystemStatus.error:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor(SystemStatus status) {
    switch (status) {
      case SystemStatus.running:
        return Colors.green;
      case SystemStatus.ready:
        return Colors.blue;
      case SystemStatus.stopped:
        return Colors.grey;
      case SystemStatus.warning:
        return Colors.orange;
      case SystemStatus.error:
        return Colors.red;
    }
  }

  String _getStatusText(SystemStatus status) {
    switch (status) {
      case SystemStatus.running:
        return 'Running';
      case SystemStatus.ready:
        return 'Ready';
      case SystemStatus.stopped:
        return 'Stopped';
      case SystemStatus.warning:
        return 'Warning';
      case SystemStatus.error:
        return 'Error';
    }
  }

  void _showStatusDetails(
    BuildContext context,
    SystemStatus status,
    SystemStateState systemState,
    AlarmState alarmState,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('System Status Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${_getStatusText(status)}'),
              SizedBox(height: 8),
              Text('Is Running: ${systemState.isSystemRunning}'),
              Text('Active Recipe: ${systemState.currentSystemState['activeRecipe']?.name ?? 'None'}'),
              Text('Current Step: ${systemState.currentSystemState['currentStepIndex'] ?? 0}/${systemState.currentSystemState['totalSteps'] ?? 0}'),
              SizedBox(height: 8),
              Text('Active Alarms: ${alarmState.activeAlarms.length}'),
              Text('Critical Alarms: ${alarmState.criticalAlarms.length}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

enum SystemStatus {
  running,
  ready,
  stopped,
  warning,
  error,
}