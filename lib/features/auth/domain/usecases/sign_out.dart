// lib/features/auth/domain/usecases/sign_out.dart
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../repositories/i_auth_repository.dart';
import '../../../../core/errors/failures.dart';

@injectable
class SignOut {
  final IAuthRepository repository;

  SignOut(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.signOut();
  }
}
