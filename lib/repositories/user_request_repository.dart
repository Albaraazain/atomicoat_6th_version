import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/user_role.dart';
import 'base_repository.dart';

enum UserRequestStatus { pending, approved, denied }

class UserRequest {
  final String userId;
  final String email;
  final String name;
  final String machineSerial;
  final UserRequestStatus status;

  UserRequest({
    required this.userId,
    required this.email,
    required this.name,
    required this.machineSerial,
    this.status = UserRequestStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'name': name,
    'machineSerial': machineSerial,
    'status': status.toString(),
  };

  factory UserRequest.fromJson(Map<String, dynamic> json) => UserRequest(
    userId: json['userId'],
    email: json['email'],
    name: json['name'],
    machineSerial: json['machineSerial'],
    status: UserRequestStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
        orElse: () => UserRequestStatus.pending),
  );
}

class UserRequestRepository extends BaseRepository<UserRequest> {
  UserRequestRepository() : super('user_requests');
  // create collection reference
  final CollectionReference _collection = FirebaseFirestore.instance.collection('user_requests');
  // create firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  UserRequest fromJson(Map<String, dynamic> json) => UserRequest.fromJson(json);

  Future<void> createUserRequest(UserRequest request) async {
    await add(request.userId, request);
  }

  Future<void> updateUserRequestStatus(String userId, UserRequestStatus status) async {
    final request = await get(userId);
    if (request != null) {
      final updatedRequest = UserRequest(
        userId: request.userId,
        email: request.email,
        name: request.name,
        machineSerial: request.machineSerial,
        status: status,
      );
      await update(userId, updatedRequest);
    }
  }

  Future<void> approveRequest(String userId, UserRole role) async {
    await _firestore.runTransaction((transaction) async {
      // Update the user request status
      transaction.update(_collection.doc(userId), {'status': UserRequestStatus.approved.toString()});

      // Update the user's role and status in the users collection
      transaction.update(_firestore.collection('users').doc(userId), {
        'role': role.toString().split('.').last,
        'isActive': true,
      });
    });
  }

  Future<void> denyRequest(String userId) async {
    await _collection.doc(userId).update({'status': UserRequestStatus.denied.toString()});
  }

  Future<int> getPendingRequestCount() async {
    QuerySnapshot snapshot = await _collection
        .where('status', isEqualTo: UserRequestStatus.pending.toString())
        .get();
    return snapshot.size;
  }

  Future<List<UserRequest>> getPendingRequests() async {
    final querySnapshot = await getCollection()
        .where('status', isEqualTo: UserRequestStatus.pending.toString())
        .get();
    return querySnapshot.docs
        .map((doc) => UserRequest.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }
}