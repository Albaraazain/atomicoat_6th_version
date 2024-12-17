// lib/features/auth/repository/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/core/enums/user_request_status.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/enums/user_role.dart';
import '../models/user.dart';
import '../models/user_request.dart';

class AuthRepository {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return User.fromJson(data);
  }

  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign in failed');
      }

      final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!doc.exists) {
        throw Exception('User data not found');
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      final user = User.fromJson(data);

      // Check if user is approved
      if (user.role != UserRole.admin && user.status != 'active') {
        await signOut();
        throw Exception('Your account is pending approval');
      }

      return user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String machineSerial,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed');
      }

      // Create user document
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'name': name,
        'role': UserRole.user.toJson(),
        'status': 'pending',
        'machineSerial': machineSerial,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create user request
      await _firestore.collection('user_requests').doc(credential.user!.uid).set({
        'userId': credential.user!.uid,
        'email': email,
        'name': name,
        'machineSerial': machineSerial,
        'status': UserRequestStatus.pending.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Exception _handleAuthError(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
          return Exception('Invalid email or password.');
        case 'user-disabled':
          return Exception('This account has been disabled.');
        case 'user-not-found':
          return Exception('No account found with this email.');
        case 'wrong-password':
          return Exception('Incorrect password.');
        case 'email-already-in-use':
          return Exception('An account already exists with this email.');
        case 'operation-not-allowed':
          return Exception('Operation not allowed.');
        case 'weak-password':
          return Exception('Please enter a stronger password.');
        default:
          return Exception(error.message ?? 'Authentication error occurred.');
      }
    }
    return Exception(error.toString());
  }
}