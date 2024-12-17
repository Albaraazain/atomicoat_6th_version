// lib/features/auth/bloc/auth_state.dart
import '../models/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registrationSuccess,  // Add this
  error
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState();

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error && errorMessage != null;
  bool get isRegistrationSuccessful => status == AuthStatus.registrationSuccess;  // Add this
}

