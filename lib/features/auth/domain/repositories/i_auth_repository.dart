// lib/features/auth/domain/repositories/i_auth_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../../core/errors/failures.dart';
import '../value_objects/email.dart';
import '../value_objects/password.dart';

abstract class IAuthRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword(
    EmailAddress email,
    Password password,
  );

  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required EmailAddress email,
    required Password password,
    required String name,
    required String machineSerial,
  });

  Future<Either<Failure, Unit>> signOut();
  Future<Option<User>> getSignedInUser();
  Stream<Option<User>> watchSignedInUser();
}

