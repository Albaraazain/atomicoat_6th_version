// lib/features/auth/bloc/auth_event.dart
abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String machineSerial;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.machineSerial,
  });
}

class SignOutRequested extends AuthEvent {}
