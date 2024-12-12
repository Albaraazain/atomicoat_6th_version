// lib/widgets/component_status_update_dialog.dart
import 'package:flutter/material.dart';

import '../../system_operation_also_main_module/models/system_component.dart';

class ComponentStatusUpdateDialog extends StatefulWidget {
  final SystemComponent component;
  final Function(ComponentStatus, String) onUpdate;
  
  const ComponentStatusUpdateDialog({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ComponentStatusUpdateDialogState createState() => _ComponentStatusUpdateDialogState();
}

class _ComponentStatusUpdateDialogState extends State<ComponentStatusUpdateDialog> {
  late ComponentStatus _selectedStatus;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.component.status;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update ${widget.component.name} Status'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Status: ${widget.component.status}'),
            SizedBox(height: 16),
            Text('Select New Status:'),
            _buildStatusRadioListTile('Normal', ComponentStatus.normal),
            _buildStatusRadioListTile('Warning', ComponentStatus.warning),
            _buildStatusRadioListTile('Error', ComponentStatus.error),
            SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter any additional notes about this status change',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onUpdate(_selectedStatus, _notesController.text);
            Navigator.of(context).pop();
            _showConfirmationSnackBar(context);
          },
          child: Text('Update'),
        ),
      ],
    );
  }

  Widget _buildStatusRadioListTile(String title, ComponentStatus value) {
    return RadioListTile<ComponentStatus>(
      title: Text(title),
      value: value,
      groupValue: _selectedStatus,
      onChanged: (ComponentStatus? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedStatus = newValue;
          });
        }
      },
    );
  }


  void _showConfirmationSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.component.name} status updated to $_selectedStatus'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}