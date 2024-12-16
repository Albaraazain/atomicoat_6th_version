

/// Custom exception class for bloc-related errors
class BlocException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const BlocException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() => 'BlocException: $message${code != null ? ' ($code)' : ''}';
}