// lib/features/auth/domain/usecases/sign_up.dart
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../repositories/i_auth_repository.dart';
import '../entities/user.dart';
import '../../../../core/errors/failures.dart';
import '../value_objects/email.dart';
import '../value_objects/password.dart';

@injectable
class SignUp {
  final IAuthRepository repository;

  SignUp(this.repository);

  Future<Either<Failure, User>> call(SignUpParams params) async {
    final emailAddress = EmailAddress(params.email);
    final password = Password(params.password);

    if (!emailAddress.isValid()) {
      return left(const Failure.invalidInput('Invalid email format'));
    }

    if (!password.isValid()) {
      return left(const Failure.invalidInput('Invalid password'));
    }

    if (params.name.isEmpty) {
      return left(const Failure.invalidInput('Name cannot be empty'));
    }

    if (params.machineSerial.isEmpty) {
      return left(const Failure.invalidInput('Machine serial cannot be empty'));
    }

    return await repository.signUpWithEmailAndPassword(
      email: emailAddress,
      password: password,
      name: params.name,
      machineSerial: params.machineSerial,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String name;
  final String machineSerial;

  SignUpParams({
    required this.email,
    required this.password,
    required this.name,
    required this.machineSerial,
  });
}
