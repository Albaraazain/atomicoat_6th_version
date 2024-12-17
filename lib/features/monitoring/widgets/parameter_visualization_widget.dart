
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../components/models/data_point.dart';

class ParameterVisualizationWidget extends StatelessWidget {
  final String componentId;
  final String parameterName;
  final List<DataPoint> dataPoints;
  final Map<String, double>? thresholds;
  final bool showThresholds;
  final Duration timeWindow;

  const ParameterVisualizationWidget({
    Key? key,
    required this.componentId,
    required this.parameterName,
    required this.dataPoints,
    this.thresholds,
    this.showThresholds = true,
    this.timeWindow = const Duration(hours: 1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final now = DateTime.now();
    final startTime = now.subtract(timeWindow);

    final spots = dataPoints
        .where((dp) => dp.timestamp.isAfter(startTime))
        .map((dp) {
          final timeAgo = now.difference(dp.timestamp).inSeconds;
          return FlSpot(timeAgo.toDouble(), dp.value);
        })
        .toList();

    if (spots.isEmpty) {
      return const Center(child: Text('No recent data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            '$parameterName Trend',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toStringAsFixed(1));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final minutes = (value / 60).round();
                        return Text('${-minutes}m');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                  if (showThresholds && thresholds != null) ...[
                    _buildThresholdLine(spots, thresholds!['max'] ?? double.infinity, Colors.red),
                    _buildThresholdLine(spots, thresholds!['min'] ?? double.negativeInfinity, Colors.orange),
                  ],
                ],
                minX: spots.first.x,
                maxX: spots.last.x,
                minY: _calculateMinY(),
                maxY: _calculateMaxY(),
              ),
            ),
          ),
          if (showThresholds && thresholds != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildThresholdIndicator('Max', Colors.red, thresholds!['max']),
                  const SizedBox(width: 16),
                  _buildThresholdIndicator('Min', Colors.orange, thresholds!['min']),
                ],
              ),
            ),
        ],
      ),
    );
  }

  LineChartBarData _buildThresholdLine(List<FlSpot> spots, double value, Color color) {
    return LineChartBarData(
      spots: [
        FlSpot(spots.first.x, value),
        FlSpot(spots.last.x, value),
      ],
      isCurved: false,
      color: color,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      dashArray: [5, 5],
    );
  }

  Widget _buildThresholdIndicator(String label, Color color, double? value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text('$label: ${value?.toStringAsFixed(1) ?? 'N/A'}'),
      ],
    );
  }

  double _calculateMinY() {
    final values = dataPoints.map((dp) => dp.value);
    final min = values.reduce((a, b) => a < b ? a : b);
    final threshold = thresholds?['min'];
    if (threshold != null && threshold < min) {
      return threshold - (min * 0.1);
    }
    return min - (min * 0.1);
  }

  double _calculateMaxY() {
    final values = dataPoints.map((dp) => dp.value);
    final max = values.reduce((a, b) => a > b ? a : b);
    final threshold = thresholds?['max'];
    if (threshold != null && threshold > max) {
      return threshold + (max * 0.1);
    }
    return max + (max * 0.1);
  }
}