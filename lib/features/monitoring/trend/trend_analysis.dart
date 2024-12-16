
import 'dart:math' as math;
import '../../components/models/data_point.dart';

enum TrendType {
  stable,
  increasing,
  decreasing,
  rapidIncrease,
  rapidDecrease,
}

class TrendAnalysis {
  final Duration analysisPeriod;
  final double rapidChangeThreshold; // percent change per minute

  TrendAnalysis({
    this.analysisPeriod = const Duration(minutes: 5),
    this.rapidChangeThreshold = 5.0, // 5% per minute
  });

  TrendResult analyzeTrend(List<DataPoint> dataPoints) {
    if (dataPoints.length < 2) {
      return TrendResult(
        type: TrendType.stable,
        changeRate: 0,
        confidence: 0,
      );
    }

    final recentPoints = _getRecentPoints(dataPoints);
    if (recentPoints.isEmpty) {
      return TrendResult(
        type: TrendType.stable,
        changeRate: 0,
        confidence: 0,
      );
    }

    final changeRate = _calculateChangeRate(recentPoints);
    final confidence = _calculateConfidence(recentPoints);
    final trendType = _determineTrendType(changeRate);

    return TrendResult(
      type: trendType,
      changeRate: changeRate,
      confidence: confidence,
    );
  }

  List<DataPoint> _getRecentPoints(List<DataPoint> dataPoints) {
    final cutoff = DateTime.now().subtract(analysisPeriod);
    return dataPoints.where((dp) => dp.timestamp.isAfter(cutoff)).toList();
  }

  double _calculateChangeRate(List<DataPoint> points) {
    if (points.length < 2) return 0;

    final first = points.first;
    final last = points.last;
    final timeDiff = last.timestamp.difference(first.timestamp).inMinutes;
    if (timeDiff == 0) return 0;

    return ((last.value - first.value) / first.value * 100) / timeDiff;
  }

  double _calculateConfidence(List<DataPoint> points) {
    if (points.length < 3) return 0;

    // Calculate R-squared value for linear regression
    final xValues = points.map((p) => p.timestamp.millisecondsSinceEpoch.toDouble()).toList();
    final yValues = points.map((p) => p.value).toList();

    double xMean = xValues.reduce((a, b) => a + b) / xValues.length;
    double yMean = yValues.reduce((a, b) => a + b) / yValues.length;

    double xxSum = xValues.map((x) => (x - xMean) * (x - xMean)).reduce((a, b) => a + b);
    double yySum = yValues.map((y) => (y - yMean) * (y - yMean)).reduce((a, b) => a + b);
    double xySum = xValues.asMap().entries.map((e) =>
      (e.value - xMean) * (yValues[e.key] - yMean)).reduce((a, b) => a + b);

    double correlation = xySum / (sqrt(xxSum) * sqrt(yySum));
    return correlation * correlation; // R-squared value
  }

  TrendType _determineTrendType(double changeRate) {
    if (changeRate.abs() < 0.5) return TrendType.stable;
    if (changeRate.abs() >= rapidChangeThreshold) {
      return changeRate > 0 ? TrendType.rapidIncrease : TrendType.rapidDecrease;
    }
    return changeRate > 0 ? TrendType.increasing : TrendType.decreasing;
  }
}

class TrendResult {
  final TrendType type;
  final double changeRate;
  final double confidence;

  TrendResult({
    required this.type,
    required this.changeRate,
    required this.confidence,
  });

  bool get isReliable => confidence > 0.7;

  String get description {
    if (!isReliable) return 'Trend uncertain';
    return switch (type) {
      TrendType.stable => 'Parameter is stable',
      TrendType.increasing => 'Gradually increasing',
      TrendType.decreasing => 'Gradually decreasing',
      TrendType.rapidIncrease => 'Rapidly increasing',
      TrendType.rapidDecrease => 'Rapidly decreasing',
    };
  }
}

double sqrt(double x) => x <= 0 ? 0 : math.sqrt(x);