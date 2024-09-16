// lib/widgets/maintenance_task_list.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maintenance_task.dart';
import '../providers/maintenance_provider.dart';
import 'package:intl/intl.dart';

class MaintenanceTaskList extends StatelessWidget {
  final List<MaintenanceTask> tasks;
  final bool showComponentName;

  const MaintenanceTaskList({
    Key? key,
    required this.tasks,
    this.showComponentName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(child: Text('No maintenance tasks scheduled.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskItem(context, tasks[index]);
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, MaintenanceTask task) {
    final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
    final DateFormat formatter = DateFormat('MMM dd, yyyy');

    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        maintenanceProvider.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task deleted')),
        );
      },
      child: Card(
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (bool? value) {
              if (value != null) {
                maintenanceProvider.updateTaskCompletion(task.id, value);
              }
            },
          ),
          title: Text(
            task.description,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Due: ${formatter.format(task.dueDate)}'),
              if (showComponentName)
                FutureBuilder<String>(
                  future: maintenanceProvider.getComponentName(task.componentId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading component...');
                    }
                    return Text('Component: ${snapshot.data ?? 'Unknown'}');
                  },
                ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditDialog(context, task),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, MaintenanceTask task) {
    showDialog(
      context: context,
      builder: (ctx) => _TaskEditDialog(task: task),
    );
  }
}

class _TaskEditDialog extends StatefulWidget {
  final MaintenanceTask task;

  const _TaskEditDialog({Key? key, required this.task}) : super(key: key);

  @override
  __TaskEditDialogState createState() => __TaskEditDialogState();
}

class __TaskEditDialogState extends State<_TaskEditDialog> {
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Task Description'),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Due Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}'),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Text('Select Date'),
                ),
              ],
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
            final updatedTask = widget.task.copyWith(
              description: _descriptionController.text,
              dueDate: _selectedDate,
            );
            Provider.of<MaintenanceProvider>(context, listen: false).updateTask(updatedTask);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}