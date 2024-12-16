// lib/features/auth/presentation/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/admin_dashboard_bloc.dart';
import '../../widgets/dashboard_card.dart';

@RoutePage()
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const Center(child: CircularProgressIndicator()),
            loading: (_) => const Center(child: CircularProgressIndicator()),
            loaded: (state) => _buildDashboard(context, state),
            failure: (state) => Center(
              child: Text('Error: ${state.failure}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AdminDashboardLoaded state) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        DashboardCard(
          title: 'Pending Requests',
          value: state.pendingRequestsCount.toString(),
          icon: Icons.pending_actions,
          onTap: () => context.router.push(const PendingRequestsRoute()),
        ),
        DashboardCard(
          title: 'Total Users',
          value: state.totalUsersCount.toString(),
          icon: Icons.people,
          onTap: () => context.router.push(const UserManagementRoute()),
        ),
        // Add more cards as needed
      ],
    );
  }
}

