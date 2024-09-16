// lib/widgets/component_status_update_dialog.dart
import 'package:flutter/material.dart';
import '../models/component.dart';

class ComponentStatusUpdateDialog extends StatefulWidget {
  final Component component;
  final Function(String, String) onUpdate;

  const ComponentStatusUpdateDialog({
    Key? key,
    required this.component,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _ComponentStatusUpdateDialogState createState() => _ComponentStatusUpdateDialogState();
}

class _ComponentStatusUpdateDialogState extends State<ComponentStatusUpdateDialog> {
  late String _selectedStatus;
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
            _buildStatusRadioListTile('Normal', 'normal'),
            _buildStatusRadioListTile('Warning', 'warning'),
            _buildStatusRadioListTile('Error', 'error'),
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

  Widget _buildStatusRadioListTile(String title, String value) {
    return RadioListTile<String>(
      title: Text(title),
      value: value,
      groupValue: _selectedStatus,
      onChanged: (String? newValue) {
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