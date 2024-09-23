import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../repositories/user_request_repository.dart';
import '../repositories/user_repository.dart';
import '../enums/user_role.dart';
import '../services/auth_service.dart';

// Import all the necessary screens

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final UserRequestRepository _userRequestRepository = UserRequestRepository();
  final UserRepository _userRepository = UserRepository();
  late AuthService _authService;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
            onPressed: () async {
              await authProvider.signOut();
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
  }


  Widget _buildPendingRequestsTab() {
    return FutureBuilder<List<UserRequest>>(
      future: _userRequestRepository.getPendingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No pending requests'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final request = snapshot.data![index];
              return ListTile(
                title: Text(request.name),
                subtitle: Text(request.email),
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
        }
      },
    );
  }


  Widget _buildContent() {
    return DefaultTabController(
      length: 2,
      child: Material( // Add this Material widget
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(icon: Icon(Icons.pending), text: 'Pending Requests'),
                Tab(icon: Icon(Icons.people), text: 'Manage Users'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPendingRequestsTab(),
                  _buildManageUsersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildManageUsersTab() {
    return FutureBuilder<List<User>>(
      future: _userRepository.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No users found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return FutureBuilder<UserRole?>(
                future: _authService.getUserRole(user.id),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text(user.name), subtitle: Text('Loading...'));
                  }
                  final userRole = roleSnapshot.data ?? UserRole.user;
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<UserRole>(
                          value: userRole,
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
      },
    );
  }


  void _approveUser(UserRequest request) async {
    await _userRequestRepository.updateUserRequestStatus(request.userId, UserRequestStatus.approved);
    await _authService.updateUserStatus(request.userId, 'active');
    setState(() {});
  }

  void _denyUser(UserRequest request) async {
    await _userRequestRepository.updateUserRequestStatus(request.userId, UserRequestStatus.denied);
    await _authService.updateUserStatus(request.userId, 'denied');
    setState(() {});
  }

  void _updateUserRole(String userId, UserRole newRole) async {
    await _authService.updateUserRole(userId, newRole);
    setState(() {});
  }

  void _deactivateUser(String userId) async {
    await _authService.updateUserStatus(userId, 'inactive');
    setState(() {});
  }


  void _activateUser(String userId) async {
    await _authService.updateUserStatus(userId, 'active');
    setState(() {});
  }
}