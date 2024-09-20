import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state_provider.dart';

class VacuumSystemStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStateProvider>(
      builder: (context, systemStateProvider, child) {
        final vacuumStatus = systemStateProvider.vacuumSystemStatus;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vacuum System Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildPumpStatus('Roughing Pump', vacuumStatus['Roughing Pump']!),
                SizedBox(height: 8),
                _buildPumpStatus('Turbo Pump', vacuumStatus['Turbo Pump']!),
                SizedBox(height: 8),
                _buildChamberPressure(vacuumStatus['Chamber']!['pressure']!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPumpStatus(String pumpName, Map<String, double> status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(pumpName, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Speed: ${status['speed']!.toStringAsFixed(1)} rpm'),
            Text('Pressure: ${_formatPressure(status['pressure']!)}'),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: status['speed']! / (pumpName == 'Roughing Pump' ? 100.0 : 1000.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }

  Widget _buildChamberPressure(double pressure) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chamber Pressure', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text(_formatPressure(pressure)),
      ],
    );
  }

  String _formatPressure(double pressure) {
    if (pressure < 1e-9) {
      return '${(pressure * 1e12).toStringAsFixed(2)} pTorr';
    } else if (pressure < 1e-6) {
      return '${(pressure * 1e9).toStringAsFixed(2)} nTorr';
    } else if (pressure < 1e-3) {
      return '${(pressure * 1e6).toStringAsFixed(2)} µTorr';
    } else if (pressure < 1) {
      return '${(pressure * 1e3).toStringAsFixed(2)} mTorr';
    } else {
      return '${pressure.toStringAsFixed(2)} Torr';
    }
  }
}