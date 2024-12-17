// lib/features/auth/models/user.dart
import '../../../core/enums/user_role.dart';

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String status;
  final String machineSerial;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.machineSerial,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role.toJson(),
    'status': status,
    'machineSerial': machineSerial,
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    name: json['name'] ?? '',
    role: _parseUserRole(json['role']),
    status: json['status'] ?? '',
    machineSerial: json['machineSerial'] ?? '',
  );

  static UserRole _parseUserRole(dynamic roleString) {
    if (roleString == null) return UserRole.user;
    try {
      return UserRole.values.firstWhere(
        (role) => role.toString().split('.').last == roleString,
        orElse: () => UserRole.user,
      );
    } catch (e) {
      print('Error parsing UserRole: $e');
      return UserRole.user;
    }
  }
}
