// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../enums/user_role.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserRole? _userRole;

  User? get user => _user;
  String? get userId => _user?.uid;
  UserRole? get userRole => _userRole;
  bool get isAuthenticated => _user != null;

  // current user id getter


  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = _authService.currentUser;
    await _updateUserRole();
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      _updateUserRole();
      notifyListeners();
    });
  }

  Future<void> _updateUserRole() async {
    if (_user != null) {
      _userRole = await _authService.getUserRole(_user!.uid);
      notifyListeners();
    } else {
      _userRole = null;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      User? user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      return user != null;
    } catch (e) {
      print('Error in signUp: $e');
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      User? user = await _authService.signIn(email: email, password: password);
      return user != null;
    } catch (e) {
      print('Error in signIn: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userRole = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _user = _authService.currentUser;
    await _updateUserRole();
    notifyListeners();
  }
}