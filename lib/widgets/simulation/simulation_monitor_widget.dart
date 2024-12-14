// lib/widgets/simulation/simulation_monitor_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/simulation/bloc/simulation_bloc.dart';
import '../../blocs/simulation/bloc/simulation_event.dart';
import '../../blocs/simulation/bloc/simulation_state.dart';

class SimulationMonitorWidget extends StatelessWidget {
  const SimulationMonitorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SimulationBloc, SimulationState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const Divider(),
                _buildStatusInfo(state),
                const SizedBox(height: 16),
                _buildControls(context, state),
                if (state.error != null)
                  _buildErrorMessage(state.error!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SimulationState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Simulation Monitor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildStatusIndicator(state.status),
      ],
    );
  }

  Widget _buildStatusIndicator(SimulationStatus status) {
    final color = switch (status) {
      SimulationStatus.running => Colors.green,
      SimulationStatus.paused => Colors.orange,
      SimulationStatus.error => Colors.red,
      SimulationStatus.idle => Colors.grey,
    };

    final text = switch (status) {
      SimulationStatus.running => 'Running',
      SimulationStatus.paused => 'Paused',
      SimulationStatus.error => 'Error',
      SimulationStatus.idle => 'Idle',
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo(SimulationState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tick Count: ${state.tickCount}'),
        const SizedBox(height: 8),
        Text(
          'Last Update: ${_formatDateTime(state.lastUpdated)}',
        ),
        const SizedBox(height: 8),
        _buildComponentUpdates(state),
      ],
    );
  }

  Widget _buildComponentUpdates(SimulationState state) {
    if (state.lastComponentUpdates.isEmpty) {
      return const Text('No component updates yet');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last Component Updates:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        ...state.lastComponentUpdates.entries.map(
          (entry) => Text(
            '${entry.key}: ${_formatDateTime(entry.value)}',
          ),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, SimulationState state) {
    final isRunning = state.status == SimulationStatus.running;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.read<SimulationBloc>().add(
              isRunning ? StopSimulation() : StartSimulation(),
            );
          },
          icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
          label: Text(isRunning ? 'Stop' : 'Start'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            context.read<SimulationBloc>().add(GenerateRandomError());
          },
          icon: const Icon(Icons.warning),
          label: const Text('Generate Error'),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }
}