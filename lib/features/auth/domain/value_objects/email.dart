// lib/features/auth/domain/value_objects/email.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

class EmailAddress {
  final Either<Failure, String> value;

  factory EmailAddress(String input) {
    if (input.isEmpty) {
      return EmailAddress._(
        left(const Failure.invalidInput('Email cannot be empty')),
      );
    }

    const emailRegex = r'^[^@]+@[^@]+\.[^@]+$';
    if (!RegExp(emailRegex).hasMatch(input)) {
      return EmailAddress._(
        left(const Failure.invalidInput('Invalid email format')),
      );
    }

    return EmailAddress._(right(input));
  }

  const EmailAddress._(this.value);

  bool isValid() => value.isRight();
}
