// lib/features/auth/presentation/widgets/user_list_item.dart
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../../../core/enums/user_role.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final Function(UserRole) onRoleChanged;
  final Function(String) onStatusChanged;
  final VoidCallback onDelete;

  const UserListItem({
    super.key,
    required this.user,
    required this.onRoleChanged,
    required this.onStatusChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<UserRole>(
                    value: user.role,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) onRoleChanged(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: user.status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['pending', 'approved', 'blocked'].map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: onStatusChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Machine Serial: ${user.machineSerial}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
