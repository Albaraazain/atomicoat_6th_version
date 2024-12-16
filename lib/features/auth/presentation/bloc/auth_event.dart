// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.signInRequested({
    required String email,
    required String password,
  }) = SignInRequested;

  const factory AuthEvent.signUpRequested({
    required String email,
    required String password,
    required String name,
    required String machineSerial,
  }) = SignUpRequested;

  const factory AuthEvent.signOutRequested() = SignOutRequested;
}

