

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SystemStateData extends Equatable {
  final String id;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const SystemStateData({
    required this.id,
    required this.data,
    required this.timestamp,
  });

  factory SystemStateData.fromJson(Map<String, dynamic> json) {
    return SystemStateData(
      id: json['id'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'data': data,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  SystemStateData copyWith({
    String? id,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  }) {
    return SystemStateData(
      id: id ?? this.id,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [id, data, timestamp];
}