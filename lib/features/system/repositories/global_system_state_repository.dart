// lib/features/system/repositories/global_system_state_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/system_state_data.dart';

class GlobalSystemStateRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'system_states';

  GlobalSystemStateRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get stateCollection => _firestore.collection(_collection);

  Future<void> saveSystemState(Map<String, dynamic> stateData) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    await stateCollection.doc(id).set({
      ...stateData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<SystemStateData?> getLatestState() async {
    final snapshot = await stateCollection
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    return SystemStateData(
      id: doc.id,
      data: doc.data() as Map<String, dynamic>,
      timestamp: ((doc.data() as Map<String, dynamic>)['timestamp'] as Timestamp).toDate(),
    );
  }

  Stream<SystemStateData?> watchSystemState() {
    return stateCollection
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return SystemStateData(
        id: doc.id,
        data: doc.data() as Map<String, dynamic>,
        timestamp: ((doc.data() as Map<String, dynamic>)['timestamp'] as Timestamp).toDate(),
      );
    });
  }
}