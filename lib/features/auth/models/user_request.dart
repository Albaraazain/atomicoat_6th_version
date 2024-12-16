import 'package:experiment_planner/core/enums/user_request_status.dart';

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
    'status': status.toString(),
  };

  factory UserRequest.fromJson(Map<String, dynamic> json) => UserRequest(
    userId: json['userId'],
    email: json['email'],
    name: json['name'],
    machineSerial: json['machineSerial'],
    status: UserRequestStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
        orElse: () => UserRequestStatus.pending),
  );
}