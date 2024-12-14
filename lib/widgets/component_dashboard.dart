// lib/widgets/component_dashboard.dart

import 'package:experiment_planner/blocs/component/bloc/component_list_state.dart';
import 'package:experiment_planner/blocs/component/repository/component_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/component/bloc/component_bloc.dart';
import '../blocs/component/bloc/component_list_bloc.dart';
import '../blocs/component/bloc/component_event.dart';
import '../blocs/component/bloc/component_state.dart';
import '../modules/system_operation_also_main_module/models/system_component.dart';

class ComponentDashboard extends StatelessWidget {
  const ComponentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComponentListBloc, ComponentListState>(
      builder: (context, listState) {
        if (listState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (listState.error != null) {
          return Center(child: Text('Error: ${listState.error}'));
        }

        final components = listState.components.values.toList();

        return ListView.builder(
          itemCount: components.length,
          itemBuilder: (context, index) {
            final component = components[index];
            return ComponentCard(component: component);
          },
        );
      },
    );
  }
}

class ComponentCard extends StatelessWidget {
  final SystemComponent component;

  const ComponentCard({
    Key? key,
    required this.component,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComponentBloc(
        context.read<ComponentRepository>(),
      )..add(ComponentInitialized(component.name)),
      child: BlocBuilder<ComponentBloc, ComponentState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Card(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final component = state.component;
          if (component == null) return const SizedBox();

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        component.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Switch(
                        value: component.isActivated,
                        onChanged: (value) {
                          context.read<ComponentBloc>().add(
                            ComponentActivationToggled(
                              component.name,
                              value,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(component.description),
                  const SizedBox(height: 16),
                  ...component.currentValues.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key),
                          Text(
                            entry.value.toStringAsFixed(2),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (component.errorMessages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Errors:',
                      style: TextStyle(color: Colors.red),
                    ),
                    ...component.errorMessages.map(
                      (error) => Text(
                        '• $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}