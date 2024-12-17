import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/enums/user_role.dart';

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String status;
  final DateTime createdAt;  // Changed type to DateTime

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name ?? '',  // Provide default for optional field
        'role': role.toString().split('.').last,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),  // Convert to Timestamp
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String? ?? '',  // Handle potentially missing name
        role: UserRole.values.firstWhere(
          (e) => e.toString() == 'UserRole.${json['role']}',
          orElse: () => UserRole.user,
        ),
        status: json['status'] as String,
        createdAt: (json['createdAt'] as Timestamp).toDate(),  // Convert from Timestamp
      );

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role, status: $status)';
  }
}