import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';
import '../../auth/models/user.dart';
import '../../auth/models/user_request.dart';
import '../../auth/repository/auth_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final AuthRepository _authRepository = AuthRepository();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Admin Dashboard'),
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
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
                onPressed: () {
                  context.read<AuthBloc>().add(SignOutRequested());
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.pending), text: 'Pending Requests'),
                Tab(icon: Icon(Icons.people), text: 'Manage Users'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPendingRequestsTab(),
              _buildManageUsersTab(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPendingRequestsTab() {
    return FutureBuilder<List<UserRequest>>(
      future: _authRepository.getPendingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No pending requests'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final request = snapshot.data![index];
            return ListTile(
              title: Text(request.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.email),
                  Text('Machine Serial: ${request.machineSerial}'),  // Added machine serial display
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _approveUser(request),
                    child: Text('Approve'),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _denyUser(request),
                    child: Text('Deny'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildManageUsersTab() {
    return FutureBuilder<List<User>>(
      future: _authRepository.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final user = snapshot.data![index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<UserRole>(
                    value: user.role,
                    onChanged: (UserRole? newRole) {
                      if (newRole != null) {
                        _updateUserRole(user.id, newRole);
                      }
                    },
                    items: UserRole.values.map((UserRole role) {
                      return DropdownMenuItem<UserRole>(
                        value: role,
                        child: Text(role.toString().split('.').last),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: user.status == 'active'
                        ? () => _deactivateUser(user.id)
                        : () => _activateUser(user.id),
                    child: Text(user.status == 'active' ? 'Deactivate' : 'Activate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.status == 'active' ? Colors.red : Colors.green,
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

  void _approveUser(UserRequest request) async {
    try {
      await _authRepository.approveUserRequest(request.id);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error approving user: $e')),
      );
    }
  }

  void _denyUser(UserRequest request) async {
    try {
      await _authRepository.denyUserRequest(request.id);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error denying user: $e')),
      );
    }
  }

  void _updateUserRole(String userId, UserRole newRole) async {
    try {
      await _authRepository.updateUserRole(userId, newRole);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user role: $e')),
      );
    }
  }

  void _deactivateUser(String userId) async {
    try {
      await _authRepository.updateUserStatus(userId, 'inactive');
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deactivating user: $e')),
      );
    }
  }

  void _activateUser(String userId) async {
    try {
      await _authRepository.updateUserStatus(userId, 'active');
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error activating user: $e')),
      );
    }
  }
}