// lib/modules/maintenance_module/screens/component_detail_screen.dart

import 'package:experiment_planner/modules/maintenance_module/screens/calibration_screen.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/system_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/component/bloc/component_bloc.dart';
import '../../../blocs/calibration/bloc/calibration_bloc.dart';
import '../../../blocs/component/bloc/component_event.dart';
import '../../../blocs/component/bloc/component_state.dart';
import '../../../blocs/calibration/bloc/calibration_event.dart';
import '../../../blocs/calibration/bloc/calibration_state.dart';
import '../models/calibration_record.dart';
import '../widgets/maintenance_task_list.dart';
import '../widgets/calibration_history_widget.dart';
import '../widgets/component_status_update_dialog.dart';
import 'maintenance_procedures_list_screen.dart';
import 'package:intl/intl.dart';

class ComponentDetailScreen extends StatefulWidget {
  final String componentName;

  const ComponentDetailScreen({
    Key? key,
    required this.componentName,
  }) : super(key: key);

  @override
  State<ComponentDetailScreen> createState() => _ComponentDetailScreenState();
}

class _ComponentDetailScreenState extends State<ComponentDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize both blocs
    context.read<ComponentBloc>().add(ComponentInitialized(widget.componentName));
    context.read<CalibrationBloc>().add(LoadCalibrationRecords());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ComponentBloc, ComponentState>(
          listener: (context, state) {
            if (state.error != null) {
              _showErrorSnackBar(context, state.error!);
            }
          },
        ),
        BlocListener<CalibrationBloc, CalibrationState>(
          listener: (context, state) {
            if (state.error != null) {
              _showErrorSnackBar(context, state.error!);
            }
          },
        ),
      ],
      child: BlocBuilder<ComponentBloc, ComponentState>(
        builder: (context, componentState) {
          if (componentState.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final component = componentState.component;
          if (component == null) {
            return const Scaffold(
              body: Center(child: Text('Component not found')),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(component.name),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showStatusUpdateDialog(context, component),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<ComponentBloc>()
                    .add(ComponentInitialized(widget.componentName));
                context.read<CalibrationBloc>().add(LoadCalibrationRecords());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildComponentInfo(component),
                      const SizedBox(height: 24),
                      _buildMaintenanceTasks(component),
                      const SizedBox(height: 24),
                      _buildCalibrationHistory(component),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _navigateToMaintenanceProcedures(
                          context,
                          component,
                        ),
                        child: const Text('View Maintenance Procedures'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComponentInfo(SystemComponent component) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Component Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Type: ${component.type}'),
            Text('Status: ${component.status.toString().split('.').last}'),
            Text(
              'Last Maintenance: ${DateFormat('yyyy-MM-dd').format(component.lastMaintenanceDate)}',
            ),
            const SizedBox(height: 16),
            Text(
              'Current Values:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...component.currentValues.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Text(
                  '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceTasks(SystemComponent component) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            MaintenanceTaskList(
              tasks: component.maintenanceTasks ?? [], // Assuming component has maintenanceTasks property
              showComponentName: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationHistory(SystemComponent component) {
    return BlocBuilder<CalibrationBloc, CalibrationState>(
      builder: (context, calibrationState) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Calibration History',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddCalibrationDialog(
                        context,
                        component,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (calibrationState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  CalibrationHistoryWidget(
                    componentId: component.id,
                    getComponentName: (id) => component.name, // Use component name directly or implement proper lookup
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStatusUpdateDialog(
    BuildContext context,
    SystemComponent component,
  ) {
    showDialog(
      context: context,
      builder: (context) => ComponentStatusUpdateDialog(
        component: component,
        onUpdate: (newStatus, notes) {
          context.read<ComponentBloc>().add(
                ComponentStatusUpdated(component.name, newStatus),
              );
        },
      ),
    );
  }

  void _showAddCalibrationDialog(
    BuildContext context,
    SystemComponent component,
  ) {
    showDialog(
      context: context,
      builder: (context) => CalibrationEditDialog(
        calibrationRecord: CalibrationRecord(
          id: '',
          componentId: component.id,
          calibrationDate: DateTime.now(),
          performedBy: '',
          calibrationData: {}, // Initialize with empty map
          notes: '',
        ),
        onSave: (record) {
          context.read<CalibrationBloc>().add(AddCalibrationRecord(record));
        },
      ),
    );
  }

  void _navigateToMaintenanceProcedures(
    BuildContext context,
    SystemComponent component,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MaintenanceProceduresListScreen(
          componentId: component.id,
          componentName: component.name,
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}