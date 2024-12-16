// lib/features/auth/domain/entities/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/user_role.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required String status,
    required String machineSerial,
    required DateTime? createdAt,
    required DateTime? updatedAt,
  }) = _User;
}
