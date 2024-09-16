import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alarm_provider.dart';

class AlarmIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AlarmProvider>(
      builder: (context, provider, child) {
        if (!provider.hasActiveAlarms) {
          return SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => _showAlarmDetails(context, provider),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: provider.hasCriticalAlarm ? Colors.red : Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  '${provider.activeAlarms.length} Alarm${provider.activeAlarms.length > 1 ? 's' : ''}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showAlarmDetails(BuildContext context, AlarmProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Active Alarms'),
          content: SingleChildScrollView(
            child: ListBody(
              children: provider.activeAlarms.map((alarm) =>
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('${alarm.severity.toString().split('.').last}: ${alarm.message}'),
                  )
              ).toList(),
            ),
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