// lib/features/auth/repository/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/core/enums/user_request_status.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../core/enums/user_role.dart';
import '../models/user.dart';
import '../models/user_request.dart';

// Custom exceptions
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException({required this.code, required this.message});

  @override
  String toString() => message;
}

class UserDataException implements Exception {
  final String code;
  final String message;

  UserDataException({required this.code, required this.message});

  @override
  String toString() => message;
}

class AccessDeniedException implements Exception {
  final String code;
  final String message;
  final String status;

  AccessDeniedException({
    required this.code,
    required this.message,
    required this.status
  });

  @override
  String toString() => message;
}

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

    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;
    return User.fromJson(data);
  }

  Future<User> signIn({required String email, required String password}) async {
    try {
      print("AUTH_REPO: Starting sign in for email: $email");

      // First try Firebase authentication
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).catchError((error) {
        if (error is firebase_auth.FirebaseAuthException) {
          throw AuthException(
            code: error.code,
            message: _getAuthErrorMessage(error.code),
          );
        }
        throw AuthException(
          code: 'unknown_auth_error',
          message: error.toString(),
        );
      });

      if (credential.user == null) {
        throw AuthException(
          code: 'no_user',
          message: 'No user returned after authentication',
        );
      }

      // Then try to get user data
      try {
        final doc = await _firestore.collection('users').doc(credential.user!.uid).get();

        if (!doc.exists) {
          throw UserDataException(
            code: 'user_doc_not_found',
            message: 'User document not found in Firestore',
          );
        }

        final data = doc.data()!;
        data['id'] = doc.id;

        // Validate required fields
        _validateUserData(data);

        final user = User.fromJson(data);

        // Check user status
        if (user.status != 'active' && user.role != UserRole.admin) {
          throw AccessDeniedException(
            code: 'inactive_user',
            message: 'Your account is not active',
            status: user.status,
          );
        }

        return user;
      } catch (e) {
        // If user data retrieval fails, sign out the user
        await _auth.signOut();
        rethrow;
      }
    } catch (e) {
      print("AUTH_REPO: Error during sign in: $e");
      rethrow;
    }
  }

  void _validateUserData(Map<String, dynamic> data) {
    final requiredFields = ['email', 'role', 'status'];
    final missingFields = requiredFields.where((field) =>
      data[field] == null || data[field].toString().isEmpty
    ).toList();

    if (missingFields.isNotEmpty) {
      throw UserDataException(
        code: 'invalid_user_data',
        message: 'Missing required fields: ${missingFields.join(", ")}',
      );
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Authentication error occurred.';
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
        'role': UserRole.user.toString().split('.').last,
        'status': 'pending',
        'machineSerial': machineSerial,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create user request with explicit pending status
      await _firestore
          .collection('user_requests')
          .doc(credential.user!.uid)
          .set({
        'userId': credential.user!.uid,
        'email': email,
        'name': name,
        'machineSerial': machineSerial,
        'status': UserRequestStatus.pending
            .toString()
            .split('.')
            .last, // Explicit status
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<List<UserRequest>> getPendingRequests() async {
    try {
      final snapshot = await _firestore
          .collection('user_requests')
          .where('status',
              isEqualTo: UserRequestStatus.pending.toString().split('.').last)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserRequest.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch pending requests: ${e.toString()}');
    }
  }

  Future<void> approveUserRequest(String requestId) async {
    try {
      await _firestore.collection('user_requests').doc(requestId).update({
        'status': UserRequestStatus.approved.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also update the user's status
      final request =
          await _firestore.collection('user_requests').doc(requestId).get();
      final userId = request.data()?['userId'] as String?;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'status': 'active',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to approve user request: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return User.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<void> denyUserRequest(String requestId) async {
    try {
      await _firestore.collection('user_requests').doc(requestId).update({
        'status': UserRequestStatus.denied.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Also update the user's status
      final request =
          await _firestore.collection('user_requests').doc(requestId).get();
      final userId = request.data()?['userId'] as String?;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'status': 'denied',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to deny user request: ${e.toString()}');
    }
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user role: ${e.toString()}');
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user status: ${e.toString()}');
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
