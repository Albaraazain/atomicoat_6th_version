import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_state_provider.dart';

class PrecursorLevelMonitor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SystemStateProvider>(
      builder: (context, systemStateProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precursor Levels',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ...systemStateProvider.precursorLevels.entries.map(
                      (entry) => _buildPrecursorLevelIndicator(entry.key, entry.value),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrecursorLevelIndicator(String precursor, double level) {
    Color indicatorColor = level > 50 ? Colors.green : (level > 20 ? Colors.orange : Colors.red);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(precursor, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: level / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          ),
          SizedBox(height: 4),
          Text('${level.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}