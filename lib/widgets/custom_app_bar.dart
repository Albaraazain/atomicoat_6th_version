// lib/widgets/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onDrawerIconPressed;

  CustomAppBar({
    required this.title,
    this.onDrawerIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: onDrawerIconPressed ?? () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notifications not implemented yet')),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            await authProvider.signOut();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}