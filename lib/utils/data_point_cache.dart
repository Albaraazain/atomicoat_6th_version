// lib/utils/data_point_cache.dart

import '../modules/system_operation_also_main_module/models/data_point.dart';

class DataPointCache {
  final Map<String, Map<String, List<DataPoint>>> _cache = {};
  static const int DEFAULT_MAX_POINTS = 1000;

  void addDataPoint(
    String componentId,
    String parameter,
    DataPoint dataPoint, {
    int maxPoints = DEFAULT_MAX_POINTS,
  }) {
    _cache.putIfAbsent(componentId, () => {});
    _cache[componentId]!.putIfAbsent(parameter, () => []);

    final points = _cache[componentId]![parameter]!;
    points.add(dataPoint);

    if (points.length > maxPoints) {
      points.removeAt(0);
    }
  }

  List<DataPoint> getDataPoints(String componentId, String parameter) {
    return _cache[componentId]?[parameter] ?? [];
  }

  void clearComponentData(String componentId) {
    _cache.remove(componentId);
  }

  void clearParameterData(String componentId, String parameter) {
    _cache[componentId]?.remove(parameter);
  }

  void clearAll() {
    _cache.clear();
  }

  bool hasData(String componentId, String parameter) {
    return _cache[componentId]?[parameter]?.isNotEmpty ?? false;
  }

  DataPoint? getLatestDataPoint(String componentId, String parameter) {
    final points = _cache[componentId]?[parameter];
    return points?.isNotEmpty == true ? points!.last : null;
  }

  List<DataPoint> getDataPointsInRange(
    String componentId,
    String parameter,
    DateTime start,
    DateTime end,
  ) {
    final points = _cache[componentId]?[parameter] ?? [];
    return points.where((point) {
      return point.timestamp.isAfter(start) && point.timestamp.isBefore(end);
    }).toList();
  }
}