// lib/features/auth/domain/repositories/i_user_request_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/user_request.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/enums/user_request_status.dart';

abstract class IUserRequestRepository {
  Future<Either<Failure, Unit>> create(UserRequest request);
  Future<Either<Failure, Unit>> updateStatus(String userId, UserRequestStatus status);
  Future<Either<Failure, List<UserRequest>>> getPendingRequests();
  Future<Either<Failure, int>> getPendingRequestCount();
}
