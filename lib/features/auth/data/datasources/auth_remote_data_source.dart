// lib/features/auth/data/datasources/auth_remote_data_source.dart
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/firebase_constants.dart';

abstract class IAuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String machineSerial,
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> watchUser(String userId);
}

@LazySingleton(as: IAuthRemoteDataSource)
class FirebaseAuthDataSource implements IAuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource(this._firebaseAuth, this._firestore);

  @override
  Future<UserModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const ServerException('User not found');
      }

      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw const ServerException('User data not found');
      }

      return UserModel.fromFirestore(
        userDoc.data()!,
        userDoc.id,
      );
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String machineSerial,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const ServerException('Failed to create user');
      }

      final userData = {
        'email': email,
        'name': name,
        'role': 'user',
        'status': 'pending',
        'machineSerial': machineSerial,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .set(userData);

      return UserModel.fromFirestore(
        userData,
        userCredential.user!.uid,
      );
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) return null;

      final userDoc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromFirestore(
        userDoc.data()!,
        userDoc.id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<UserModel?> watchUser(String userId) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}

