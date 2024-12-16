

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/alarm/bloc/alarm_bloc.dart';
import '../../../blocs/alarm/bloc/alarm_state.dart';
import '../models/alarm.dart';

class AlarmIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        if (!state.hasActiveAlarms) {
          return SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _showAlarmDetails(context, state),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: state.hasCriticalAlarms ? Colors.red : Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  '${state.activeAlarms.length} Alarm${state.activeAlarms.length > 1 ? 's' : ''}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAlarmDetails(BuildContext context, AlarmState state) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Active Alarms'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                if (state.criticalAlarms.isNotEmpty) ...[
                  _buildAlarmSection('Critical', state.criticalAlarms),
                  Divider(),
                ],
                if (state.warningAlarms.isNotEmpty) ...[
                  _buildAlarmSection('Warning', state.warningAlarms),
                  Divider(),
                ],
                if (state.infoAlarms.isNotEmpty)
                  _buildAlarmSection('Info', state.infoAlarms),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlarmSection(String title, List<Alarm> alarms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ...alarms.map((alarm) => Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(alarm.message),
        )),
      ],
    );
  }
}