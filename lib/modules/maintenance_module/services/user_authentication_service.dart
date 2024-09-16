// lib/services/user_authentication_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class UserAuthenticationService {
  static const String _userKey = 'current_user';

  Future<bool> login(String email, String password) async {
    // In a real app, you would validate against a server or secure database
    // This is a simplified example for demonstration purposes
    String hashedPassword = _hashPassword(password);
    if (email == 'admin@example.com' && hashedPassword == _hashPassword('password123')) {
      await _saveUserSession(email);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  Future<void> _saveUserSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, email);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}