// lib/core/errors/exceptions.dart
class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);
}

class NetworkException implements Exception {}

class CacheException implements Exception {}

