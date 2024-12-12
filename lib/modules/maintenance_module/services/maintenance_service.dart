// lib/services/maintenance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maintenance_procedure.dart';
import '../models/maintenance_task.dart';

class MaintenanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _tasksCollection => _firestore.collection('maintenance_tasks');
  CollectionReference get _proceduresCollection => _firestore.collection('maintenance_procedures');

  // Maintenance Procedures
  Future<List<MaintenanceProcedure>> loadMaintenanceProcedures() async {
    QuerySnapshot snapshot = await _proceduresCollection.get();
    return snapshot.docs.map((doc) => MaintenanceProcedure.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<MaintenanceProcedure?> getMaintenanceProcedure(String componentId, String procedureType) async {
    QuerySnapshot snapshot = await _proceduresCollection
        .where('componentId', isEqualTo: componentId)
        .where('procedureType', isEqualTo: procedureType)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return MaintenanceProcedure.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> saveMaintenanceProcedure(MaintenanceProcedure procedure) async {
    String id = procedure.componentId + '_' + procedure.procedureType;
    await _proceduresCollection.doc(id).set(procedure.toJson());
  }

  // Maintenance Tasks
  Future<List<MaintenanceTask>> loadTasks() async {
    QuerySnapshot snapshot = await _tasksCollection.get();
    return snapshot.docs.map((doc) => MaintenanceTask.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> saveTask(MaintenanceTask task) async {
    await _tasksCollection.doc(task.id).set(task.toJson());
  }

  Future<void> updateTask(MaintenanceTask task) async {
    await _tasksCollection.doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String id) async {
    await _tasksCollection.doc(id).delete();
  }


  // Helper method to convert Firestore Timestamp to DateTime
  DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    }
    return null;
  }
}