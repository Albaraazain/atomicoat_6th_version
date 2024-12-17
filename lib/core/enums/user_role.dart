// lib/enums/user_role.dart

enum UserRole {
  operator,
  engineer,
  admin,
  user;

  String toJson() => toString().split('.').last;
}
