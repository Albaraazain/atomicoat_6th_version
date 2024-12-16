// lib/core/errors/auth_error.dart
sealed class AuthFailure {
  const AuthFailure();
}

class InvalidCredentials extends AuthFailure {}
class ServerError extends AuthFailure {}
class NetworkError extends AuthFailure {}