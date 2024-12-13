// lib/blocs/component/repository/component_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/modules/system_operation_also_main_module/models/data_point.dart';
import '../../../modules/system_operation_also_main_module/models/system_component.dart';
import '../../../repositories/base_repository.dart';
import '../../../services/auth_service.dart';
import '../../../utils/data_point_cache.dart';

class ComponentRepository extends BaseRepository<SystemComponent> {
  final AuthService _authService;
  final DataPointCache _dataPointCache;

  ComponentRepository(this._authService)
      : _dataPointCache = DataPointCache(),
        super('system_components');

  @override
  SystemComponent fromJson(Map<String, dynamic> json) =>
      SystemComponent.fromJson(json);

  Future<SystemComponent?> getComponent(String componentName) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return await get(componentName, userId: userId);
  }

  Future<List<SystemComponent>> getAllComponents() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return await getAll(userId: userId);
  }

  Future<List<SystemComponent>> getActiveComponents() async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    QuerySnapshot activeComponents = await getUserCollection(userId)
        .where('isActivated', isEqualTo: true)
        .get();

    return activeComponents.docs
        .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateComponentState(
    String componentName,
    Map<String, double> newState,
  ) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    await getUserCollection(userId)
        .doc(componentName)
        .update({'currentValues': newState});
  }

  Stream<SystemComponent?> watchComponent(String componentName) {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    return getUserCollection(userId)
        .doc(componentName)
        .snapshots()
        .map((doc) => doc.exists
            ? fromJson(doc.data() as Map<String, dynamic>)
            : null);
  }

  // DataPoint Cache methods
  void cacheDataPoint(
    String componentName,
    String parameter,
    DataPoint dataPoint, {
    int maxPoints = DataPointCache.DEFAULT_MAX_POINTS,
  }) {
    _dataPointCache.addDataPoint(
      componentName,
      parameter,
      dataPoint,
      maxPoints: maxPoints,
    );
  }

  List<DataPoint> getCachedDataPoints(String componentName, String parameter) {
    return _dataPointCache.getDataPoints(componentName, parameter);
  }

  DataPoint? getLatestDataPoint(String componentName, String parameter) {
    return _dataPointCache.getLatestDataPoint(componentName, parameter);
  }

  void clearCache() {
    _dataPointCache.clearAll();
  }
}