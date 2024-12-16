
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/models/data_point.dart';
import '../../../base/base_repository.dart';

class ParameterMonitoringRepository extends BlocRepository<Map<String, dynamic>> {
  static const int MAX_HISTORY_POINTS = 1000;

  ParameterMonitoringRepository({String? userId}) : super(
    collectionName: 'parameter_monitoring',
    userId: userId,
  );

  @override
  Map<String, dynamic> fromJson(Map<String, dynamic> json) => json;

  @override
  Map<String, dynamic> toJson(Map<String, dynamic> data) => data;

  Future<void> saveParameterValue(
    String componentId,
    String parameterName,
    DataPoint dataPoint,
  ) async {
    final docRef = userCollection
        .doc(componentId)
        .collection('parameters')
        .doc(parameterName)
        .collection('history')
        .doc(dataPoint.timestamp.millisecondsSinceEpoch.toString());

    await docRef.set(dataPoint.toJson());

    // Cleanup old data points
    final oldData = await userCollection
        .doc(componentId)
        .collection('parameters')
        .doc(parameterName)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(MAX_HISTORY_POINTS + 1)
        .get();

    if (oldData.docs.length > MAX_HISTORY_POINTS) {
      final batch = FirebaseFirestore.instance.batch();
      oldData.docs
          .sublist(MAX_HISTORY_POINTS)
          .forEach((doc) => batch.delete(doc.reference));
      await batch.commit();
    }
  }

  Stream<List<DataPoint>> watchParameterHistory(
    String componentId,
    String parameterName,
    Duration duration,
  ) {
    final cutoff = DateTime.now().subtract(duration);

    return userCollection
        .doc(componentId)
        .collection('parameters')
        .doc(parameterName)
        .collection('history')
        .where('timestamp', isGreaterThan: cutoff.millisecondsSinceEpoch)
        .orderBy('timestamp', descending: true)
        .limit(MAX_HISTORY_POINTS)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DataPoint.fromJson(doc.data()))
            .toList());
  }

  Future<void> saveThresholds(
    String componentId,
    String parameterName,
    double minValue,
    double maxValue,
  ) async {
    await save('thresholds/$componentId/$parameterName', {
      'min': minValue,
      'max': maxValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, Map<String, double>>> getThresholds(String componentId) async {
    final doc = await get('thresholds/$componentId');
    if (doc == null) return {};

    final thresholds = <String, Map<String, double>>{};
    doc.forEach((parameter, value) {
      if (value is Map) {
        thresholds[parameter] = {
          'min': (value['min'] as num).toDouble(),
          'max': (value['max'] as num).toDouble(),
        };
      }
    });
    return thresholds;
  }
}