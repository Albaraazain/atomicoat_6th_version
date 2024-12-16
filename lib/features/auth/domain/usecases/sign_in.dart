// lib/features/auth/domain/usecases/sign_in.dart
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../repositories/i_auth_repository.dart';
import '../entities/user.dart';
import '../../../../core/errors/failures.dart';
import '../value_objects/email.dart';
import '../value_objects/password.dart';

@injectable
class SignIn {
  final IAuthRepository repository;

  SignIn(this.repository);

  Future<Either<Failure, User>> call(SignInParams params) async {
    final emailAddress = EmailAddress(params.email);
    final password = Password(params.password);

    if (!emailAddress.isValid()) {
      return left(const Failure.invalidInput('Invalid email format'));
    }

    if (!password.isValid()) {
      return left(const Failure.invalidInput('Invalid password'));
    }

    return await repository.signInWithEmailAndPassword(emailAddress, password);
  }
}

class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}

