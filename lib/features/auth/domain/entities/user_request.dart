// lib/features/auth/domain/entities/user_request.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/user_request_status.dart';

part 'user_request.freezed.dart';

@freezed
class UserRequest with _$UserRequest {
  const factory UserRequest({
    required String id,
    required String userId,
    required String email,
    required String name,
    required String machineSerial,
    required UserRequestStatus status,
    required DateTime? createdAt,
    required DateTime? updatedAt,
  }) = _UserRequest;
}
