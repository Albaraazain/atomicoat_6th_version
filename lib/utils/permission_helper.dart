// lib/utils/permission_helper.dart

import '../enums/user_role.dart';

class PermissionHelper {
  static bool hasPermission(UserRole? userRole, List<UserRole> requiredRoles) {
    if (userRole == null) return false;
    if (userRole == UserRole.admin) return true; // Admin has access to everything
    return requiredRoles.contains(userRole);
  }

  static bool canAccessMaintenanceModule(UserRole? userRole) {
    return hasPermission(userRole, [UserRole.engineer, UserRole.admin]);
  }

  static bool canAccessRecipeManagement(UserRole? userRole) {
    return hasPermission(userRole, [UserRole.engineer, UserRole.admin]);
  }

  static bool canModifySystemSettings(UserRole? userRole) {
    return hasPermission(userRole, [UserRole.admin]);
  }

  static bool canViewReports(UserRole? userRole) {
    return hasPermission(userRole, [UserRole.engineer, UserRole.admin]);
  }

// Add more specific permission checks as needed
}