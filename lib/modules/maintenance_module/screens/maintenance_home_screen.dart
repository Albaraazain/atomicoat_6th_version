// lib/screens/maintenance_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maintenance_task.dart';
import '../providers/maintenance_provider.dart';
import '../providers/calibration_provider.dart';
import '../widgets/system_overview_widget.dart';
import '../widgets/maintenance_schedule_widget.dart';
import '../widgets/calibration_summary_widget.dart';
import '../widgets/error_dialog.dart';
import '../models/component.dart';
import '../models/calibration_record.dart';
import './add_task_screen.dart';
import './add_calibration_screen.dart';

class MaintenanceHomeScreen extends StatefulWidget {
  @override
  _MaintenanceHomeScreenState createState() => _MaintenanceHomeScreenState();
}

class _MaintenanceHomeScreenState extends State<MaintenanceHomeScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _fetchData();
      _isInit = false;
    }
  }

  Future<void> _fetchData() async {
    try {
      await Provider.of<MaintenanceProvider>(context, listen: false).fetchComponents();
      await Provider.of<MaintenanceProvider>(context, listen: false).fetchTasks();
      await Provider.of<CalibrationProvider>(context, listen: false).fetchCalibrationRecords();
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => ErrorDialog(
          message: 'An error occurred while fetching data. Please try again.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('ALD Maintenance & Calibration'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Consumer2<MaintenanceProvider, CalibrationProvider>(
        builder: (ctx, maintenanceProvider, calibrationProvider, child) {
          if (maintenanceProvider.isLoading || calibrationProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (maintenanceProvider.error != null || calibrationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('An error occurred. Please try again.'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      maintenanceProvider.clearError();
                      calibrationProvider.clearError();
                      _fetchData();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SystemOverviewWidget(
                      components: maintenanceProvider.components,
                      onComponentTap: (component) => _showComponentDetails(context, component),
                    ),
                    SizedBox(height: 24),
                    MaintenanceScheduleWidget(
                      tasks: maintenanceProvider.tasks,
                      onTaskTap: (task) => _showTaskDetails(context, task),
                    ),
                    SizedBox(height: 24),
                    CalibrationSummaryWidget(
                      components: maintenanceProvider.components,
                      calibrationRecords: calibrationProvider.calibrationRecords,
                      getLatestCalibrationForComponent: (id) => calibrationProvider.getLatestCalibrationForComponent(id),
                      isCalibrationDue: (id, duration) => calibrationProvider.isCalibrationDue(id, duration),
                      showCalibrationDetailsDialog: (context, component, calibration) {
                        _showCalibrationDetails(context, component, calibration);
                      },
                      showCalibrationHistoryDialog: (context) {
                        _showCalibrationHistory(context, calibrationProvider.calibrationRecords);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptionDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add new task or calibration',
      ),
    );
  }

  void _showComponentDetails(BuildContext context, Component component) {
    // TODO: Navigate to a detailed component screen
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(component.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${component.type}'),
            Text('Status: ${component.status}'),
            Text('Last Maintenance: ${component.lastMaintenanceDate.toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(BuildContext context, MaintenanceTask task) {
    // TODO: Navigate to a detailed task screen
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Task Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${task.description}'),
            Text('Due Date: ${task.dueDate.toString()}'),
            Text('Status: ${task.isCompleted ? "Completed" : "Pending"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCalibrationDetails(BuildContext context, Component component, CalibrationRecord? calibration) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Calibration Details for ${component.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (calibration != null) ...[
              Text('Last Calibration: ${calibration.calibrationDate.toString()}'),
              Text('Performed By: ${calibration.performedBy}'),
              Text('Notes: ${calibration.notes}'),
            ] else
              Text('No calibration records found for this component.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCalibrationHistory(BuildContext context, List<CalibrationRecord> records) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Calibration History'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text('${record.componentId} - ${record.calibrationDate.toString()}'),
                subtitle: Text('Performed By: ${record.performedBy}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddOptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Maintenance Task'),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddTaskScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.build),
              title: Text('Calibration Record'),
              onTap: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddCalibrationScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}