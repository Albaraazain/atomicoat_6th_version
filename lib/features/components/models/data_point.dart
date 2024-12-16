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