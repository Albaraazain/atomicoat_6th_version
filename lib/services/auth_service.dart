// lib/services/auth_service.dart

import 'package:experiment_planner/repositories/machine_serial.dart';
import 'package:experiment_planner/repositories/user_request_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MachineSerialRepository _machineSerialRepository =
      MachineSerialRepository();
  final UserRequestRepository _userRequestRepository = UserRequestRepository();

  // getter for current user status
  Future<String?> getUserStatus(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      String? role = doc.get('role') as String?;
      if (role?.toLowerCase() == 'admin') {
        return 'approved'; // Always treat admin as approved
      }
      return doc.get('status') as String?;
    } catch (e) {
      print('Error getting user status: $e');
      return null;
    }
  }

  // getter for current user
  User? get currentUser => _auth.currentUser;

  // getter for current user id
  String? get currentUserId => _auth.currentUser?.uid;

  // getter for current user status
  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': status,
      });
    } catch (e) {
      print('Error updating user status: $e');
    }
  }

  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': role.toString().split('.').last.toLowerCase(),
      });
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  Future<void> validateUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      if (!doc.exists || data == null || !data.containsKey('status') || !data.containsKey('role')) {
        await _firestore.collection('users').doc(userId).set({
          'status': 'pending',
          'role': 'user',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error validating user data: $e');
    }
  }

  // Sign up with email and password
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String machineSerial
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        UserRequest request = UserRequest(
          userId: user.uid,
          email: email,
          name: name,
          machineSerial: machineSerial,
        );
        await _userRequestRepository.createUserRequest(request);

        // Create user document in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'machineSerial': machineSerial,
          'status': 'pending',
          'role': 'user',  // Set default role to 'user'
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _machineSerialRepository.assignUserToMachine(machineSerial, user.uid);
      }

      return user;
    } catch (e) {
      print('Error during sign up: $e');
      return null;
    }
  }


  // Sign in with email and password
  Future<User?> signIn({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        // Check if the user document exists
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          // If the document doesn't exist, it might be the admin's first login
          // Create the admin document
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email,
            'role': 'admin',
            'status': 'approved',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } catch (e) {
      print('Error during sign in: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  // Get user role
  Future<UserRole?> getUserRole(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      String roleString = doc.get('role') as String? ?? 'user';
      print('User role: $roleString');
      return UserRole.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == roleString.toLowerCase(),
        orElse: () => UserRole.user,
      );
      return UserRole.values.firstWhere(
            (e) => e.toString().split('.').last.toLowerCase() == roleString.toLowerCase(),
        orElse: () => UserRole.user,
      );
    } catch (e) {
      print('Error getting user role: $e');
      return UserRole.user;
    }
  }

  // Stream of auth state changes. This will be used to listen to the authentication state changes. For example, when a user signs in or signs out. This will be used to update the user object in the provider.
  // This will be used in the AuthProvider to listen to the authentication state changes and update the user object in the provider.
  // a stream is a sequence of asynchronous events. It is like a pipe where data flows through. In this case, the stream will emit the user object when the authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
