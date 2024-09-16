// lib/widgets/calibration_history_widget.dart
import 'package:flutter/material.dart';
import '../models/calibration_record.dart';
import 'package:intl/intl.dart';

class CalibrationHistoryWidget extends StatelessWidget {
  final List<CalibrationRecord> calibrationRecords;
  final String? componentId;
  final Function(String) getComponentName;
  final Function(BuildContext, CalibrationRecord, Function(CalibrationRecord)) showEditDialog;
  final Function(BuildContext, CalibrationRecord, Function()) showDeleteConfirmationDialog;

  const CalibrationHistoryWidget({
    Key? key,
    required this.calibrationRecords,
    this.componentId,
    required this.getComponentName,
    required this.showEditDialog,
    required this.showDeleteConfirmationDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<CalibrationRecord> records = componentId != null
        ? calibrationRecords.where((record) => record.componentId == componentId).toList()
        : calibrationRecords;

    records.sort((a, b) => b.calibrationDate.compareTo(a.calibrationDate));

    if (records.isEmpty) {
      return Center(child: Text('No calibration records found.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return _buildCalibrationRecordItem(context, records[index]);
      },
    );
  }

  Widget _buildCalibrationRecordItem(BuildContext context, CalibrationRecord record) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      child: ExpansionTile(
        title: Text('Calibration on ${formatter.format(record.calibrationDate)}'),
        subtitle: Text('Component: ${getComponentName(record.componentId)}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performed by: ${record.performedBy}'),
                SizedBox(height: 8),
                Text('Calibration Data:'),
                ...record.calibrationData.entries.map(
                      (entry) => Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text('${entry.key}: ${entry.value}'),
                  ),
                ),
                SizedBox(height: 8),
                Text('Notes: ${record.notes}'),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => showDeleteConfirmationDialog(
                        context,
                        record,
                            () {
                          // Callback to be executed after successful deletion
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calibration record deleted')),
                          );
                        },
                      ),
                      child: Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => showEditDialog(
                        context,
                        record,
                            (updatedRecord) {
                          // Callback to be executed after successful edit
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calibration record updated')),
                          );
                        },
                      ),
                      child: Text('Edit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}