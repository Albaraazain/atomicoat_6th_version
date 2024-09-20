import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/user_role.dart';
import 'base_repository.dart';

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
    'role': role.toString().split('.').last,
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
    if (roleString == null) return UserRole.user; // Default role
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

class UserRepository extends BaseRepository<User> {
  UserRepository() : super('users');

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  Future<void> updateUserRole(String userId, UserRole role) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'role': role.toString().split('.').last,
    });
  }

  Future<void> updateUserStatus(String userId, String status) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'status': status,
    });
  }

  Future<List<User>> getAllUsers() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure the id is always set
        return User.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}