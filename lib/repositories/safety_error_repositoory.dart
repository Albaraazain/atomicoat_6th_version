// lib/repositories/safety_error_repository.dart

import '../modules/system_operation_also_main_module/models/safety_error.dart';
import 'base_repository.dart';

class SafetyErrorRepository extends BaseRepository<SafetyError> {
  SafetyErrorRepository() : super('safety_errors', 'safety_errors');

  @override
  SafetyError fromJson(Map<String, dynamic> json) => SafetyError.fromJson(json);
}