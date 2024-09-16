// lib/repositories/system_component_repository.dart

import '../modules/system_operation_also_main_module/models/system_component.dart';
import 'base_repository.dart';

class SystemComponentRepository extends BaseRepository<SystemComponent> {
  SystemComponentRepository() : super('system_components', 'system_components');

  @override
  SystemComponent fromJson(Map<String, dynamic> json) => SystemComponent.fromJson(json);
}