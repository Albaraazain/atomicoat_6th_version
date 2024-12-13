// test/widgets/monitoring/parameter_visualization_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../lib/modules/system_operation_also_main_module/models/data_point.dart';
import '../../../lib/widgets/monitoring/parameter_visualization_widget.dart';

void main() {
  final testDataPoints = [
    DataPoint(timestamp: DateTime.now().subtract(Duration(minutes: 5)), value: 25.0),
    DataPoint(timestamp: DateTime.now().subtract(Duration(minutes: 4)), value: 26.0),
    DataPoint(timestamp: DateTime.now().subtract(Duration(minutes: 3)), value: 24.0),
    DataPoint(timestamp: DateTime.now().subtract(Duration(minutes: 2)), value: 27.0),
    DataPoint(timestamp: DateTime.now().subtract(Duration(minutes: 1)), value: 25.5),
  ];

  final testThresholds = {
    'min': 20.0,
    'max': 30.0,
  };

  testWidgets('renders chart with data points', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParameterVisualizationWidget(
            componentId: 'test-component',
            parameterName: 'temperature',
            dataPoints: testDataPoints,
            thresholds: testThresholds,
          ),
        ),
      ),
    );

    expect(find.byType(LineChart), findsOneWidget);
    expect(find.text('temperature Trend'), findsOneWidget);
  });

  testWidgets('shows no data message when empty', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParameterVisualizationWidget(
            componentId: 'test-component',
            parameterName: 'temperature',
            dataPoints: [],
            thresholds: testThresholds,
          ),
        ),
      ),
    );

    expect(find.text('No data available'), findsOneWidget);
  });

  testWidgets('shows threshold indicators when provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ParameterVisualizationWidget(
            componentId: 'test-component',
            parameterName: 'temperature',
            dataPoints: testDataPoints,
            thresholds: testThresholds,
            showThresholds: true,
          ),
        ),
      ),
    );

    expect(find.text('Max: 30.0'), findsOneWidget);
    expect(find.text('Min: 20.0'), findsOneWidget);
  });
}