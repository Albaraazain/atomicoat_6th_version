
import 'package:experiment_planner/features/log/models/system_log_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/log/bloc/system_log_bloc.dart';
import '../../../blocs/log/bloc/system_log_event.dart';
import '../../../blocs/log/bloc/system_log_state.dart';
import '../../components/models/system_component.dart';

class SystemLogViewer extends StatefulWidget {
  const SystemLogViewer({Key? key}) : super(key: key);

  @override
  State<SystemLogViewer> createState() => _SystemLogViewerState();
}

class _SystemLogViewerState extends State<SystemLogViewer> {
  ComponentStatus? _severityFilter;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<SystemLogBloc>().add(LogEntriesLoaded());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more entries when near bottom
      context.read<SystemLogBloc>().add(LogEntriesLoaded(limit: 50));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: BlocBuilder<SystemLogBloc, SystemLogState>(
            builder: (context, state) {
              if (state.isLoading && state.entries.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.entries.isEmpty) {
                return const Center(child: Text('No log entries found'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<SystemLogBloc>().add(LogEntriesLoaded());
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.entries.length + (state.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.entries.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final entry = state.entries[index];
                    return _LogEntryTile(entry: entry);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<ComponentStatus>(
            value: _severityFilter,
            hint: const Text('Severity'),
            items: ComponentStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _severityFilter = value;
              });
              // Implement filter
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateRangePicker(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (dateRange != null) {
      context.read<SystemLogBloc>().add(LogEntriesFiltered(
        startDate: dateRange.start,
        endDate: dateRange.end,
        severityFilter: _severityFilter,
      ));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _LogEntryTile extends StatelessWidget {
  final SystemLogEntry entry;

  const _LogEntryTile({
    Key? key,
    required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildSeverityIcon(),
      title: Text(entry.message),
      subtitle: Text(
        _formatDateTime(entry.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () {
          // Implement copy functionality
        },
      ),
    );
  }

  Widget _buildSeverityIcon() {
    final color = switch (entry.severity) {
      ComponentStatus.normal => Colors.green,
      ComponentStatus.warning => Colors.orange,
      ComponentStatus.error => Colors.red,
      ComponentStatus.ok => Colors.blue,
    };

    final icon = switch (entry.severity) {
      ComponentStatus.normal => Icons.check_circle,
      ComponentStatus.warning => Icons.warning,
      ComponentStatus.error => Icons.error,
      ComponentStatus.ok => Icons.check_circle_outline,
    };

    return Icon(icon, color: color);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
           '${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
}