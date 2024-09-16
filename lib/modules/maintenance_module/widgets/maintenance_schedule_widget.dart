// lib/widgets/maintenance_schedule_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maintenance_task.dart';
import '../providers/maintenance_provider.dart';
import 'package:intl/intl.dart';

class MaintenanceScheduleWidget extends StatelessWidget {
  final List<MaintenanceTask> tasks;

  final dynamic onTaskTap;

  const MaintenanceScheduleWidget({
    Key? key,
    required this.tasks,
    required this.onTaskTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Schedule',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Consumer<MaintenanceProvider>(
              builder: (ctx, maintenanceProvider, child) {
                if (maintenanceProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (maintenanceProvider.tasks.isEmpty) {
                  return Text('No maintenance tasks scheduled.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: maintenanceProvider.tasks.length,
                  itemBuilder: (ctx, index) {
                    return _buildTaskItem(context, maintenanceProvider.tasks[index]);
                  },
                );
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddTaskDialog(context),
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, MaintenanceTask task) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    return ListTile(
      title: Text(task.description),
      subtitle: Text('Due: ${formatter.format(task.dueDate)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: () {
              Provider.of<MaintenanceProvider>(context, listen: false)
                  .updateTaskCompletion(task.id, !task.isCompleted);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              Provider.of<MaintenanceProvider>(context, listen: false)
                  .deleteTask(task.id);
            },
          ),
        ],
      ),
      onTap: () => _showEditTaskDialog(context, task),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _TaskDialog(),
    );
  }

  void _showEditTaskDialog(BuildContext context, MaintenanceTask task) {
    showDialog(
      context: context,
      builder: (ctx) => _TaskDialog(task: task),
    );
  }
}

class _TaskDialog extends StatefulWidget {
  final MaintenanceTask? task;

  _TaskDialog({this.task});

  @override
  __TaskDialogState createState() => __TaskDialogState();
}

class __TaskDialogState extends State<_TaskDialog> {
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _selectedDate = widget.task?.dueDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
    content: Column(
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
            SizedBox(width: 16),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final maintenanceProvider = Provider.of<MaintenanceProvider>(context, listen: false);
            if (widget.task == null) {
              maintenanceProvider.addTask(
                MaintenanceTask(
                  id: DateTime.now().toString(),
                  componentId: 'default_component_id', // Replace with actual component ID
                  description: _descriptionController.text,
                  dueDate: _selectedDate,
                  isCompleted: false,
                ),
              );
            } else {
              maintenanceProvider.updateTask(
                widget.task!.copyWith(
                  description: _descriptionController.text,
                  dueDate: _selectedDate,
                ),
              );
            }
            Navigator.of(context).pop();
          },
          child: Text(widget.task == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}