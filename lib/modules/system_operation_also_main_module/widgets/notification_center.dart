import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state_provider.dart';

class NotificationCenter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final systemStateProvider = Provider.of<SystemStateProvider>(context);

    return AlertDialog(
      title: Text('Notifications'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          itemCount: systemStateProvider.notifications.length,
          itemBuilder: (context, index) {
            final notification = systemStateProvider.notifications[index];
            return ListTile(
              title: Text(notification.message),
              subtitle: Text(notification.timestamp.toString()),
              leading: Icon(_getNotificationIcon(notification.severity)),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => systemStateProvider.dismissNotification(notification.id),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }

  IconData _getNotificationIcon(NotificationSeverity severity) {
    switch (severity) {
      case NotificationSeverity.info:
        return Icons.info;
      case NotificationSeverity.warning:
        return Icons.warning;
      case NotificationSeverity.error:
        return Icons.error;
    }
  }
}