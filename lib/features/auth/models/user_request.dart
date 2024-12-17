// lib/features/auth/models/user_request.dart
import '../../../core/enums/user_request_status.dart';

class UserRequest {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String machineSerial;
  final UserRequestStatus status; // Changed from String to UserRequestStatus
  final DateTime createdAt;

  UserRequest({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.machineSerial,
    this.status = UserRequestStatus.pending, // Added default value
    required this.createdAt,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      machineSerial: json['machineSerial'] as String,
      status: _parseStatus(json['status']), // Added status parsing
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'machineSerial': machineSerial,
      'status': status.toString().split('.').last, // Proper enum serialization
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper method to parse status from string or enum
  static UserRequestStatus _parseStatus(dynamic status) {
    if (status is UserRequestStatus) return status;
    if (status is String) {
      return UserRequestStatus.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == status.toLowerCase(),
        orElse: () => UserRequestStatus.pending,
      );
    }
    return UserRequestStatus.pending;
  }
}
