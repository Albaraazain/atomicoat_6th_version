import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/shared/base/base_repository.dart';
import '../../components/models/data_point.dart';

class ParameterMonitoringRepository extends BaseRepository<Map<String, dynamic>> {
  static const int MAX_HISTORY_POINTS = 1000;
  final FirebaseFirestore _firestore;

  ParameterMonitoringRepository({String? userId}) :
    _firestore = FirebaseFirestore.instance,
    super('parameter_monitoring');

  @override
  Map<String, dynamic> fromJson(Map<String, dynamic> json) => json;

  Future<void> saveParameterValue(
    String componentId,
    String parameterName,
    DataPoint dataPoint,
    {required String userId}
  ) async {
    final docRef = getUserCollection(userId)
        .doc(componentId)
        .collection('parameters')
        .doc(parameterName)
        .collection('history')
        .doc(dataPoint.timestamp.millisecondsSinceEpoch.toString());

    await docRef.set(dataPoint.toJson());

    // Cleanup old data points
    final oldData = await getUserCollection(userId)
        .doc(componentId)
        .collection('parameters')
        .doc(parameterName)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .limit(MAX_HISTORY_POINTS + 1)
        .get();

    if (oldData.docs.length > MAX_HISTORY_POINTS) {
      final batch = _firestore.batch();
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
    {required String userId}
  ) {
    final cutoff = DateTime.now().subtract(duration);

    return getUserCollection(userId)
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
    {required String userId}
  ) async {
    await add(
      'thresholds/$componentId/$parameterName',
      {
        'min': minValue,
        'max': maxValue,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      userId: userId
    );
  }

  Future<Map<String, Map<String, double>>> getThresholds(
    String componentId,
    {required String userId}
  ) async {
    final doc = await get('thresholds/$componentId', userId: userId);
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