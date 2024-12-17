// lib/core/app/app_providers.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Bloc imports
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/alarms/bloc/alarm_bloc.dart';
import '../../features/components/bloc/component_bloc.dart';
import '../../features/components/bloc/component_list_bloc.dart';
import '../../features/monitoring/bloc/parameter_monitoring_bloc.dart';
import '../../features/recipes/bloc/recipe_bloc.dart';
import '../../features/safety/bloc/safety_bloc.dart';
import '../../features/simulation/bloc/simulation_bloc.dart';
import '../../features/system/bloc/system_state_bloc.dart';
import '../../features/log/bloc/system_log_bloc.dart';

// Repository imports
import '../../features/auth/repository/auth_repository.dart';
import '../../features/alarms/repository/alarm_repository.dart';
import '../../features/components/repository/component_repository.dart';
import '../../features/recipes/repository/recipe_repository.dart';
import '../../features/safety/repository/safety_repository.dart';
import '../../features/system/repositories/system_state_repository.dart';
import '../../features/log/repositories/system_log_entry_repository.dart';

// Service imports
import '../../shared/services/navigation_service.dart';

class AppProviders {
  static List<BlocProvider> createBlocProviders() {
    // Initialize repositories
    final authRepository = AuthRepository();
    final systemStateRepository = SystemStateRepository();
    final recipeRepository = RecipeRepository();
    final componentRepository = ComponentRepository();
    final alarmRepository = AlarmRepository();
    final safetyRepository = SafetyRepository();
    final systemLogRepository = SystemLogEntryRepository();

    // Initialize core blocs
    final authBloc = AuthBloc(authRepository: authRepository);
    final alarmBloc = AlarmBloc(alarmRepository);
    final systemStateBloc = SystemStateBloc(systemStateRepository);
    final componentListBloc = ComponentListBloc(componentRepository);

    // Initialize safety bloc with dependencies
    final safetyBloc = SafetyBloc(
      repository: safetyRepository,
      alarmBloc: alarmBloc,
      authBloc: authBloc,
    );

    return [
      // Core blocs
      BlocProvider<AuthBloc>.value(value: authBloc),
      BlocProvider<AlarmBloc>.value(value: alarmBloc),
      BlocProvider<SystemStateBloc>.value(value: systemStateBloc),

      // Component blocs
      BlocProvider<ComponentBloc>(
        create: (context) => ComponentBloc(componentRepository),
      ),
      BlocProvider<ComponentListBloc>.value(value: componentListBloc),

      // Safety and monitoring blocs
      BlocProvider<SafetyBloc>.value(value: safetyBloc),
      BlocProvider<ParameterMonitoringBloc>(
        create: (context) => ParameterMonitoringBloc(
          safetyBloc: safetyBloc,
        ),
      ),

      // Recipe and simulation blocs
      BlocProvider<RecipeBloc>(
        create: (context) => RecipeBloc(
          repository: recipeRepository,
          systemStateBloc: systemStateBloc,
          alarmBloc: alarmBloc,
          authBloc: authBloc,
        ),
      ),
      BlocProvider<SimulationBloc>(
        create: (context) => SimulationBloc(
          componentBloc: context.read<ComponentBloc>(),
          alarmBloc: alarmBloc,
          safetyBloc: safetyBloc,
        ),
      ),

      // System log bloc
      BlocProvider<SystemLogBloc>(
        create: (context) => SystemLogBloc(
          repository: systemLogRepository,
          authBloc: authBloc,
        ),
      ),
    ];
  }

  static List<SingleChildWidget> createServiceProviders({
    required NavigationService navigationService,
  }) {
    return [
      Provider<NavigationService>.value(value: navigationService),
    ];
  }
}