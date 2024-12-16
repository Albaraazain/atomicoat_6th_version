// lib/features/auth/presentation/screens/admin/user_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user_management_bloc.dart';
import '../../widgets/user_list_item.dart';
import '../../../../../core/enums/user_role.dart';

@RoutePage()
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserManagementBloc>().add(
                const UserManagementEvent.refreshRequested(),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<UserManagementBloc, UserManagementState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const Center(child: CircularProgressIndicator()),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            loaded: (state) => _buildUserList(context, state.users),
            failure: (state) => Center(
              child: Text('Error: ${state.failure}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserList(BuildContext context, List<User> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return UserListItem(
          user: user,
          onRoleChanged: (newRole) {
            context.read<UserManagementBloc>().add(
              UserManagementEvent.roleChanged(
                userId: user.id,
                newRole: newRole,
              ),
            );
          },
          onStatusChanged: (newStatus) {
            context.read<UserManagementBloc>().add(
              UserManagementEvent.statusChanged(
                userId: user.id,
                newStatus: newStatus,
              ),
            );
          },
          onDelete: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete User'),
                content: Text('Are you sure you want to delete ${user.name}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<UserManagementBloc>().add(
                        UserManagementEvent.userDeleted(userId: user.id),
                      );
                    },
                    child: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
