// lib/features/auth/domain/value_objects/password.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

class Password {
  final Either<Failure, String> value;

  factory Password(String input) {
    if (input.isEmpty) {
      return Password._(
        left(const Failure.invalidInput('Password cannot be empty')),
      );
    }

    if (input.length < 6) {
      return Password._(
        left(const Failure.invalidInput('Password must be at least 6 characters')),
      );
    }

    return Password._(right(input));
  }

  const Password._(this.value);

  bool isValid() => value.isRight();
}

