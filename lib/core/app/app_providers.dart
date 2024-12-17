import 'package:experiment_planner/features/alarms/bloc/alarm_bloc.dart';
import 'package:experiment_planner/features/alarms/repository/alarm_repository.dart';
import 'package:experiment_planner/features/auth/bloc/auth_bloc.dart';
import 'package:experiment_planner/features/auth/repository/auth_repository.dart';
import 'package:experiment_planner/features/components/bloc/component_bloc.dart';
import 'package:experiment_planner/features/components/bloc/component_list_bloc.dart';
import 'package:experiment_planner/features/components/repository/global_component_repository.dart';
import 'package:experiment_planner/features/components/repository/user_component_state_repository.dart';
import 'package:experiment_planner/features/log/bloc/system_log_bloc.dart';
import 'package:experiment_planner/features/log/repositories/system_log_entry_repository.dart';
import 'package:experiment_planner/features/monitoring/bloc/parameter_monitoring_bloc.dart';
import 'package:experiment_planner/features/recipes/bloc/recipe_bloc.dart';
import 'package:experiment_planner/features/recipes/repository/recipe_repository.dart';
import 'package:experiment_planner/features/safety/bloc/safety_bloc.dart';
import 'package:experiment_planner/features/safety/repository/safety_repository.dart';
import 'package:experiment_planner/features/simulation/bloc/simulation_bloc.dart';
import 'package:experiment_planner/features/system/bloc/system_state_bloc.dart';
import 'package:experiment_planner/features/system/repositories/global_system_state_repository.dart';
import 'package:experiment_planner/features/system/repositories/user_system_state_repository.dart';
import 'package:experiment_planner/shared/services/navigation_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../features/safety/services/monitoring_service.dart';



class AppProviders {
  static List<BlocProvider> createBlocProviders() {
    // Initialize repositories
    final authRepository = AuthRepository();
    final alarmRepository = AlarmRepository();
    final userComponentRepository = UserComponentStateRepository();
    final globalComponentRepository = GlobalComponentRepository();
    final logRepository = SystemLogEntryRepository();
    final recipeRepository = RecipeRepository();
    final safetyRepository = SafetyRepository();
    final globalSystemStateRepository = GlobalSystemStateRepository();
    final userSystemStateRepository = UserSystemStateRepository();

    // Initialize core blocs
    final authBloc = AuthBloc(authRepository: authRepository);
    final alarmBloc = AlarmBloc(alarmRepository, authBloc);

    // Initialize system state bloc with dependencies
    final systemStateBloc = SystemStateBloc(
      userRepository: userSystemStateRepository,
      globalRepository: globalSystemStateRepository,
      authBloc: authBloc,
    );

    // Initialize component blocs with dependencies
    final componentListBloc = ComponentListBloc(globalComponentRepository);

    // Initialize safety bloc
    final safetyBloc = SafetyBloc(
      repository: safetyRepository,
      alarmBloc: alarmBloc,
      authBloc: authBloc,
      monitoringService: MonitoringService(),
    );

    return [
      // Core blocs
      BlocProvider<AuthBloc>(create: (context) => authBloc),
      BlocProvider<AlarmBloc>(create: (context) => alarmBloc),
      BlocProvider<SystemStateBloc>(create: (context) => systemStateBloc),

      // Component blocs
      BlocProvider<ComponentListBloc>(create: (context) => componentListBloc),
      BlocProvider<ComponentBloc>(
        create: (context) => ComponentBloc(
          userComponentRepository,
          userId: authBloc.state.user?.id ?? '',
        ),
      ),

      // Safety and monitoring blocs
      BlocProvider<SafetyBloc>(
        create: (context) => SafetyBloc(
          repository: safetyRepository,
          alarmBloc: context.read<AlarmBloc>(),
          authBloc: context.read<AuthBloc>(),
          monitoringService: context.read<MonitoringService>(),
        ),
      ),
      BlocProvider<ParameterMonitoringBloc>(
        create: (context) => ParameterMonitoringBloc(
          safetyBloc: safetyBloc,
          userRepository: userComponentRepository,
          userId: authBloc.state.user?.id ?? '',
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
          repository: logRepository,
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
      Provider<MonitoringService>(
        create: (_) => MonitoringService(),
      ),
    ];
  }

  static List<RepositoryProvider> createRepositoryProviders() {
    return [
      RepositoryProvider<AuthRepository>(
        create: (context) => AuthRepository(),
      ),
      RepositoryProvider<AlarmRepository>(
        create: (context) => AlarmRepository(),
      ),
      RepositoryProvider<UserComponentStateRepository>(
        create: (context) => UserComponentStateRepository(),
      ),
      RepositoryProvider<GlobalComponentRepository>(
        create: (context) => GlobalComponentRepository(),
      ),
      RepositoryProvider<SystemLogEntryRepository>(
        create: (context) => SystemLogEntryRepository(),
      ),
      RepositoryProvider<RecipeRepository>(
        create: (context) => RecipeRepository(),
      ),
      RepositoryProvider<SafetyRepository>(
        create: (context) => SafetyRepository(),
      ),
      RepositoryProvider<GlobalSystemStateRepository>(
        create: (context) => GlobalSystemStateRepository(),
      ),
      RepositoryProvider<UserSystemStateRepository>(
        create: (context) => UserSystemStateRepository(),
      ),
    ];
  }
}