import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/safety_error.dart';
import '../../../shared/base/base_repository.dart';

class SafetyRepository extends BaseRepository<SafetyError> {
  final FirebaseFirestore _firestore;

  SafetyRepository({String? userId}) :
    _firestore = FirebaseFirestore.instance,
    super('safety_errors');

  @override
  SafetyError fromJson(Map<String, dynamic> json) => SafetyError.fromJson(json);

  Stream<List<SafetyError>> watchActiveErrors({required String userId}) {
    return getUserCollection(userId)
        .where('resolved', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addSafetyError(SafetyError error, {required String userId}) async {
    await add(
      error.id,
      error,
      userId: userId,
    );

    // Update additional fields
    await getUserCollection(userId).doc(error.id).update({
      'resolved': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveError(String errorId, {required String userId}) async {
    await getUserCollection(userId).doc(errorId).update({
      'resolved': true,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateThresholds(
    String componentId,
    String parameter,
    double minValue,
    double maxValue,
    {required String userId}
  ) async {
    final thresholdsDocRef = getUserCollection(userId).doc('thresholds');

    await _firestore.runTransaction((transaction) async {
      // Get current thresholds
      final doc = await transaction.get(thresholdsDocRef);

      // Update thresholds data
      final Map<String, dynamic> data = doc.exists ? (doc.data() ?? {}) as Map<String, dynamic> : {};
      if (data[componentId] == null) {
        data[componentId] = {};
      }
      data[componentId][parameter] = {
        'min': minValue,
        'max': maxValue,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Set updated data
      transaction.set(thresholdsDocRef, data, SetOptions(merge: true));
    });
  }
}