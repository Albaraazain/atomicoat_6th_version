// lib/widgets/role_based_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../enums/user_role.dart';
import '../utils/permission_helper.dart';

class RoleBasedWidget extends StatelessWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleBasedWidget({
    Key? key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (PermissionHelper.hasPermission(authProvider.userRole, allowedRoles)) {
          return child;
        } else {
          return fallback ?? SizedBox.shrink();
        }
      },
    );
  }
}