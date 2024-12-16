// lib/features/auth/presentation/screens/admin/pending_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/pending_requests_bloc.dart';
import '../../widgets/request_list_item.dart';

@RoutePage()
class PendingRequestsScreen extends StatelessWidget {
  const PendingRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PendingRequestsBloc>().add(
                const PendingRequest