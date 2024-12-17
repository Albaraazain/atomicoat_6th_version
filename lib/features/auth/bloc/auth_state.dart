// lib/features/auth/bloc/auth_state.dart
import '../models/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registrationSuccess,
  authError,
  userDataError,
  accessDenied
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final String? errorCode;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.errorCode,
  });

  factory AuthState.initial() => const AuthState();

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    String? errorCode,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.authError ||
                      status == AuthStatus.userDataError ||
                      status == AuthStatus.accessDenied;
  bool get isAuthError => status == AuthStatus.authError;
  bool get isUserDataError => status == AuthStatus.userDataError;
  bool get isAccessDenied => status == AuthStatus.accessDenied;
  bool get isRegistrationSuccessful => status == AuthStatus.registrationSuccess;
}

