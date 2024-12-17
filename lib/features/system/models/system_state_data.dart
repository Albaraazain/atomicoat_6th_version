import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SystemStateData extends Equatable {
  final String id;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final bool isInitialized;  // Add this
  final bool isReady;       // Add this
  final List<String> readinessChecks;  // Add this

  const SystemStateData({
    required this.id,
    required this.data,
    required this.timestamp,
    this.isInitialized = false,
    this.isReady = false,
    this.readinessChecks = const [],
  });

  factory SystemStateData.fromJson(Map<String, dynamic> json) {
    return SystemStateData(
      id: json['id'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isInitialized: json['isInitialized'] as bool? ?? false,
      isReady: json['isReady'] as bool? ?? false,
      readinessChecks: List<String>.from(json['readinessChecks'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data,
    'timestamp': Timestamp.fromDate(timestamp),
    'isInitialized': isInitialized,
    'isReady': isReady,
    'readinessChecks': readinessChecks,
  };

  SystemStateData copyWith({
    String? id,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isInitialized,
    bool? isReady,
    List<String>? readinessChecks,
  }) {
    return SystemStateData(
      id: id ?? this.id,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isInitialized: isInitialized ?? this.isInitialized,
      isReady: isReady ?? this.isReady,
      readinessChecks: readinessChecks ?? this.readinessChecks,
    );
  }

  @override
  List<Object?> get props => [id, data, timestamp, isInitialized, isReady, readinessChecks];
}