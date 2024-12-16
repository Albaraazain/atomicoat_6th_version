
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/safety_error.dart';
import '../../components/models/system_component.dart';
import '../../../shared/base/base_repository.dart';

class SafetyRepository extends BlocRepository<SafetyError> {
  SafetyRepository({String? userId}) : super(
    collectionName: 'safety_errors',
    userId: userId,
  );

  @override
  SafetyError fromJson(Map<String, dynamic> json) => SafetyError.fromJson(json);

  @override
  Map<String, dynamic> toJson(SafetyError error) => error.toJson();

  Stream<List<SafetyError>> watchActiveErrors() {
    return userCollection
        .where('resolved', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addSafetyError(SafetyError error) async {
    await save(error.id, {
      ...toJson(error),
      'resolved': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> resolveError(String errorId) async {
    await save(errorId, {
      'resolved': true,
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateThresholds(
    String componentId,
    String parameter,
    double minValue,
    double maxValue,
  ) async {
    await save('thresholds', {
      componentId: {
        parameter: {
          'min': minValue,
          'max': maxValue,
          'updatedAt': FieldValue.serverTimestamp(),
        }
      }
    });
  }
}