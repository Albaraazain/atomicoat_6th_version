

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/alarm/bloc/alarm_bloc.dart';
import '../../../blocs/alarm/bloc/alarm_event.dart';
import '../../../blocs/alarm/bloc/alarm_state.dart';
import '../models/alarm.dart';

class AlarmDisplay extends StatefulWidget {
  @override
  State<AlarmDisplay> createState() => _AlarmDisplayState();
}

class _AlarmDisplayState extends State<AlarmDisplay> {
  @override
  void initState() {
    super.initState();
    context.read<AlarmBloc>().add(LoadAlarms());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmBloc, AlarmState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Alarms',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (state.activeAlarms.isNotEmpty)
                    TextButton(
                      onPressed: () => context.read<AlarmBloc>().add(
                            ClearAllAcknowledgedAlarms(),
                          ),
                      child: Text('Acknowledge All'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: state.activeAlarms.isEmpty
                  ? Center(child: Text('No active alarms'))
                  : ListView.builder(
                      itemCount: state.activeAlarms.length,
                      itemBuilder: (context, index) {
                        final alarm = state.activeAlarms[index];
                        return _buildAlarmTile(context, alarm);
                      },
                    ),
            ),
            if (state.error != null)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAlarmTile(BuildContext context, Alarm alarm) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _getAlarmIcon(alarm.severity),
        title: Text(alarm.message),
        subtitle: Text(
          '${alarm.timestamp.toString().split('.')[0]}',
        ),
        trailing: alarm.acknowledged
            ? Icon(Icons.check, color: Colors.green)
            : TextButton(
                child: Text('Acknowledge'),
                onPressed: () {
                  context.read<AlarmBloc>().add(
                        AcknowledgeAlarm(alarm.id),
                      );
                },
              ),
      ),
    );
  }

  Widget _getAlarmIcon(AlarmSeverity severity) {
    switch (severity) {
      case AlarmSeverity.info:
        return Icon(Icons.info, color: Colors.blue);
      case AlarmSeverity.warning:
        return Icon(Icons.warning, color: Colors.orange);
      case AlarmSeverity.critical:
        return Icon(Icons.error, color: Colors.red);
    }
  }
}