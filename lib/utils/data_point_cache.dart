/*
// lib/utils/data_point_cache.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modules/system_operation_also_main_module/models/data_point.dart';

class DataPointCache {
  final int maxSize;
  final Map<String, Map<String, List<DataPoint>>> _cache = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _updateTimer;

  DataPointCache({this.maxSize = 1000}) {
    _updateTimer = Timer.periodic(Duration(minutes: 5), (_) => _updateFirestore());
  }

  void addDataPoint(String componentId, String parameter, DataPoint dataPoint) {
    if (!_cache.containsKey(componentId)) {
      _cache[componentId] = {};
    }
    if (!_cache[componentId]!.containsKey(parameter)) {
      _cache[componentId]![parameter] = [];
    }

    // Use reduced precision when adding to cache
    DataPoint reducedDataPoint = DataPoint.reducedPrecision(
        timestamp: dataPoint.timestamp,
        value: dataPoint.value
    );

    _cache[componentId]![parameter]!.add(reducedDataPoint);

    if (_cache[componentId]![parameter]!.length > maxSize) {
      _cache[componentId]![parameter]!.removeAt(0);
    }
  }

  List<DataPoint> getDataPoints(String componentId, String parameter) {
    return _cache[componentId]?[parameter] ?? [];
  }

  void clear() {
    _cache.clear();
  }

  Future<void> _updateFirestore() async {
    try {
      WriteBatch batch = _firestore.batch();
      int operationCount = 0;

      for (var componentId in _cache.keys) {
        for (var parameter in _cache[componentId]!.keys) {
          List<DataPoint> dataPoints = _cache[componentId]![parameter]!;
          if (dataPoints.isEmpty) continue;

          DocumentReference docRef = _firestore
              .collection('components')
              .doc(componentId)
              .collection('parameters')
              .doc(parameter);

          DataPoint latestDataPoint = dataPoints.last;
          batch.set(docRef, latestDataPoint.toJson(), SetOptions(merge: true));

          operationCount++;

          if (operationCount >= 500) {
            await batch.commit();
            batch = _firestore.batch();
            operationCount = 0;
          }
        }
      }

      if (operationCount > 0) {
        await batch.commit();
      }

      print('Firestore update completed successfully');
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }

  void dispose() {
    _updateTimer?.cancel();
  }
}*/
