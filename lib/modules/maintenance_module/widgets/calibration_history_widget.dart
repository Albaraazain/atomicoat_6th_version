import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/calibration/bloc/calibration_bloc.dart';
import '../../../blocs/calibration/bloc/calibration_event.dart';
import '../../../blocs/calibration/bloc/calibration_state.dart';
import '../models/calibration_record.dart';
import 'package:intl/intl.dart';

class CalibrationHistoryWidget extends StatelessWidget {
  final String? componentId;
  final Function(String) getComponentName;

  // Keep existing parameters and add new ones
  const CalibrationHistoryWidget({
    Key? key,
    this.componentId,
    required this.getComponentName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalibrationBloc, CalibrationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(child: Text('Error: ${state.error}'));
        }

        List<CalibrationRecord> records = componentId != null
            ? state.calibrationRecords.where((record) => record.componentId == componentId).toList()
            : state.calibrationRecords;

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
                      onPressed: () {
                        BlocProvider.of<CalibrationBloc>(context)
                            .add(DeleteCalibrationRecord(record.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calibration record deleted')),
                        );
                      },
                      child: Text('Delete'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<CalibrationBloc>(context)
                            .add(UpdateCalibrationRecord(record));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calibration record updated')),
                        );
                      },
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