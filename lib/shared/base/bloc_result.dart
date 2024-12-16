// lib/blocs/base/bloc_result.dart

/// Represents the result of a bloc operation
class BlocResult<T> {
  final bool success;
  final T? data;
  final String? error;

  const BlocResult.success([this.data])
      : success = true,
        error = null;

  const BlocResult.failure(this.error)
      : success = false,
        data = null;

  bool get isSuccess => success;
  bool get isFailure => !success;
}