// In data_point.dart

class DataPoint {
  final DateTime timestamp;
  final double value;

  DataPoint({required this.timestamp, required this.value});

  DataPoint.reducedPrecision({required this.timestamp, required double value})
      : this.value = double.parse(value.toStringAsFixed(2));

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      value: json['value'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'value': value,
    };
  }

  @override
  String toString() {
    return 'DataPoint(timestamp: $timestamp, value: ${value.toStringAsFixed(2)})';
  }
}

/*

class DataPoint {
    /// Timestamp of the data point
    final DateTime timestamp;
    /// Measured value
    final double value;

    /// Constructor for creating a new data point
    DataPoint({
        required this.timestamp,
        required this.value
    });

    /// Creates a data point with reduced precision for storage efficiency
    DataPoint.reducedPrecision({
        required this.timestamp,
        required double value
    });
}

 */