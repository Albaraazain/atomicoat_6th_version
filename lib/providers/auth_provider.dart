// lib/providers/auth_provider.dart

import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../enums/user_role.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  UserRole? _userRole;
  String? _userStatus;
  bool _isLoading = true;

  User? get user => _user;
  String? get userId => _user?.uid;
  UserRole? get userRole => _userRole;
  String? get userStatus => _userStatus;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _userRole == UserRole.admin;
  bool isLoading() => _isLoading;

  bool isApproved() {
    return _userStatus == 'approved' || _userStatus == 'active';
  }

  final AuthService _authService;

  AuthProvider(this._authService) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _user = _authService.currentUser;
    if (_user != null) {
      await validateUserData();
    }
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (_user != null) {
        await validateUserData();
      } else {
        _userRole = null;
        _userStatus = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> validateUserData() async {
    if (_user != null) {
      await _authService.validateUserData(_user!.uid);
      await _updateUserInfo();
    }
  }

  Future<void> _updateUserInfo() async {
    if (_user != null) {
      _userRole = await _authService.getUserRole(_user!.uid);
      _userStatus = await _authService.getUserStatus(_user!.uid);
      print('Updating user info - User role: $_userRole, User status: $_userStatus'); // Debug log
      notifyListeners();
    } else {
      _userRole = null;
      _userStatus = null;
    }
  }


  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String machineSerial,
  }) async {
    try {
      User? user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        machineSerial: machineSerial,
      );
      return user != null;
    } catch (e) {
      print('Error in signUp: $e');
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = await _authService.signIn(email: email, password: password);
      if (user != null) {
        await _updateUserInfo();
        print('After sign in - User role: $_userRole, User status: $_userStatus'); // Debug log
        if (_userRole == UserRole.admin || _userStatus == 'active') {
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          await signOut();
          throw Exception('Your account is pending approval.');
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error in signIn: $e');
      rethrow;
    }
  }


  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userRole = null;
    _userStatus = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _user = _authService.currentUser;
    await _updateUserInfo();
    notifyListeners();
  }
}