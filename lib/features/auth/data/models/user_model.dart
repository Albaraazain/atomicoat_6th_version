// lib/features/auth/data/models/user_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';
import '../../../../core/enums/user_role.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required String status,
    required String machineSerial,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  factory UserModel.fromFirestore(Map<String, dynamic> json, String id) {
    return UserModel.fromJson({
      ...json,
      'id': id,
      'role': json['role'] ?? 'user',
      'createdAt': json['createdAt']?.toDate().toIso8601String(),
      'updatedAt': json['updatedAt']?.toDate().toIso8601String(),
    });
  }

  const UserModel._();

  User toDomain() => User(
    id: id,
    email: email,
    name: name,
    role: role,
    status: status,
    machineSerial: machineSerial,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
