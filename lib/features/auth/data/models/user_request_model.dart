// lib/features/auth/data/models/user_request_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_request.dart';
import '../../../../core/enums/user_request_status.dart';

part 'user_request_model.freezed.dart';
part 'user_request_model.g.dart';

@freezed
class UserRequestModel with _$UserRequestModel {
  const factory UserRequestModel({
    required String id,
    required String userId,
    required String email,
    required String name,
    required String machineSerial,
    required UserRequestStatus status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserRequestModel;

  factory UserRequestModel.fromJson(Map<String, dynamic> json) =>
      _$UserRequestModelFromJson(json);

  factory UserRequestModel.fromFirestore(Map<String, dynamic> json, String id) {
    return UserRequestModel.fromJson({
      ...json,
      'id': id,
      'status': json['status'] ?? 'pending',
      'createdAt': json['createdAt']?.toDate().toIso8601String(),
      'updatedAt': json['updatedAt']?.toDate().toIso8601String(),
    });
  }

  const UserRequestModel._();

  UserRequest toDomain() => UserRequest(
    id: id,
    userId: userId,
    email: email,
    name: name,
    machineSerial: machineSerial,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
