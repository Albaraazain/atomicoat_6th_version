// lib/features/auth/data/repositories/user_request_repository.dart
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/i_user_request_repository.dart';
import '../../domain/entities/user_request.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/enums/user_request_status.dart';
import '../datasources/user_request_remote_data_source.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

@LazySingleton(as: IUserRequestRepository)
class UserRequestRepository implements IUserRequestRepository {
  final IUserRequestRemoteDataSource _remoteDataSource;
  final InternetConnectionChecker _connectionChecker;

  UserRequestRepository(this._remoteDataSource, this._connectionChecker);

  @override
  Future<Either<Failure, Unit>> create(UserRequest request) async {
    try {
      if (!await _connectionChecker.hasConnection) {
        return left(const Failure.networkError());
      }

      await _remoteDataSource.create(request);
      return right(unit);
    } catch (e) {
      return left(Failure.serverError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateStatus(
    String userId,
    UserRequestStatus status,
  ) async {
    try {
      if (!await _connectionChecker.hasConnection) {
        return left(const Failure.networkError());
      }

      await _remoteDataSource.updateStatus(userId, status);
      return right(unit);
    } catch (e) {
      return left(Failure.serverError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserRequest>>> getPendingRequests() async {
    try {
      if (!await _connectionChecker.hasConnection) {
        return left(const Failure.networkError());
      }

      final requests = await _remoteDataSource.getPendingRequests();
      return right(requests.map((model) => model.toDomain()).toList());
    } catch (e) {
      return left(Failure.serverError(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingRequestCount() async {
    try {
      if (!await _connectionChecker.hasConnection) {
        return left(const Failure.networkError());
      }

      final count = await _remoteDataSource.getPendingRequestCount();
      return right(count);
    } catch (e) {
      return left(Failure.serverError(e.toString()));
    }
  }
}
