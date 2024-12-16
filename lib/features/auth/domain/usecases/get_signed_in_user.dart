// lib/features/auth/domain/usecases/get_signed_in_user.dart
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../repositories/i_auth_repository.dart';
import '../entities/user.dart';

@injectable
class GetSignedInUser {
  final IAuthRepository repository;

  GetSignedInUser(this.repository);

  Future<Option<User>> call() async {
    return await repository.getSignedInUser();
  }
}
