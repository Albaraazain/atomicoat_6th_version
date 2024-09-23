// lib/widgets/calibration_summary_widget.dart
import 'package:experiment_planner/modules/system_operation_also_main_module/models/system_component.dart';
import 'package:flutter/material.dart';
import '../models/calibration_record.dart';
import 'package:intl/intl.dart';

class CalibrationSummaryWidget extends StatelessWidget {
  final List<CalibrationRecord> calibrationRecords;
  final Function(String) getLatestCalibrationForComponent;
  final Function(String, Duration) isCalibrationDue;
  final Function(BuildContext, SystemComponent, CalibrationRecord?) showCalibrationDetailsDialog;
  final Function(BuildContext) showCalibrationHistoryDialog;
  // components of type <String, Component> meaning a map with String keys and Component values. a map is a collection of key-value pairs
  final Map<String, SystemComponent> components;

  const CalibrationSummaryWidget({
    Key? key,
    required this.components,
    required this.calibrationRecords,
    required this.getLatestCalibrationForComponent,
    required this.isCalibrationDue,
    required this.showCalibrationDetailsDialog,
    required this.showCalibrationHistoryDialog,
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
              'Calibration Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            if (components.isEmpty)
              Text('No components available for calibration.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: components.length,
                itemBuilder: (ctx, index) {
                  return _buildComponentCalibrationStatus(context, components.values.elementAt(index));
                },
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showCalibrationHistoryDialog(context),
              child: Text('View Full Calibration History'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCalibrationStatus(BuildContext context, SystemComponent component) {
    final latestCalibration = getLatestCalibrationForComponent(component.id);
    final isCalibrationDueForComponent = isCalibrationDue(component.id, Duration(days: 30));

    return ListTile(
      title: Text(component.name),
      subtitle: latestCalibration != null
          ? Text('Last Calibrated: ${_formatDate(latestCalibration.calibrationDate)}')
          : Text('Not yet calibrated'),
      trailing: Icon(
        isCalibrationDueForComponent ? Icons.warning : Icons.check_circle,
        color: isCalibrationDueForComponent ? Colors.orange : Colors.green,
      ),
      onTap: () => showCalibrationDetailsDialog(context, component, latestCalibration),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}