

import 'package:rxdart/rxdart.dart';
import '../exceptions/bloc_exception.dart';

/// Utility functions for blocs
class BlocUtils {
  /// Debounce stream events
  static Stream<T> debounce<T>(Stream<T> stream, Duration duration) {
    return stream.debounceTime(duration);
  }

  /// Throttle stream events
  static Stream<T> throttle<T>(Stream<T> stream, Duration duration) {
    return stream.throttleTime(duration);
  }

  /// Handle common error cases
  static String handleError(dynamic error) {
    if (error is BlocException) {
      return error.message;
    }
    if (error is StateError) {
      return 'Invalid operation: ${error.message}';
    }
    return 'An unexpected error occurred: $error';
  }

  /// Validate required fields
  static void validateRequired(Map<String, dynamic> data, List<String> fields) {
    for (final field in fields) {
      if (!data.containsKey(field) || data[field] == null) {
        throw BlocException('Required field missing: $field');
      }
    }
  }
}