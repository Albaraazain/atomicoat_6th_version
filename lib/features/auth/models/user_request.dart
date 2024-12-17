// lib/features/auth/models/user_request.dart
import '../../../core/enums/user_request_status.dart';

class UserRequest {
  final String userId;
  final String email;
  final String name;
  final String machineSerial;
  final UserRequestStatus status;

  UserRequest({
    required this.userId,
    required this.email,
    required this.name,
    required this.machineSerial,
    this.status = UserRequestStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'name': name,
    'machineSerial': machineSerial,
    'status': status.toJson(),
  };

  factory UserRequest.fromJson(Map<String, dynamic> json) => UserRequest(
    userId: json['userId'] ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    machineSerial: json['machineSerial'] ?? '',
    status: _parseStatus(json['status']),
  );

  static UserRequestStatus _parseStatus(dynamic statusString) {
    if (statusString == null) return UserRequestStatus.pending;
    try {
      return UserRequestStatus.values.firstWhere(
        (status) => status.toString().split('.').last == statusString,
        orElse: () => UserRequestStatus.pending,
      );
    } catch (e) {
      print('Error parsing UserRequestStatus: $e');
      return UserRequestStatus.pending;
    }
  }
}
