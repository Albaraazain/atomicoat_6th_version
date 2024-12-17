import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:experiment_planner/core/utils/bloc_utils.dart';
import 'package:experiment_planner/features/components/bloc/component_state.dart';
import '../repositories/user_system_state_repository.dart';
import '../repositories/global_system_state_repository.dart';
import '../models/system_state_data.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import 'system_state_event.dart';
import 'system_state_state.dart';
import '../models/system_component_state.dart';
import '../../components/models/system_component.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SystemStateBloc extends Bloc<SystemStateEvent, SystemStateState> {
  final UserSystemStateRepository _userRepository;
  final GlobalSystemStateRepository _globalRepository;
  final AuthBloc _authBloc;
  StreamSubscription? _stateSubscription;
  String? _currentUserId;

  SystemStateBloc({
    required UserSystemStateRepository userRepository,
    required GlobalSystemStateRepository globalRepository,
    required AuthBloc authBloc,
  }) : _userRepository = userRepository,
      _globalRepository = globalRepository,
      _authBloc = authBloc,
      super(SystemStateState()) {
    on<InitializeSystem>(_onInitializeSystem);
    on<StartSystem>(_onStartSystem);
    on<StopSystem>(_onStopSystem);
    on<EmergencyStop>(_onEmergencyStop);
    on<CheckSystemReadiness>(_onCheckSystemReadiness);
    on<SaveSystemState>(_onSaveSystemState);
    on<ValidateSystemState>(_onValidateSystemState);
    on<UpdateSystemParameters>(_onUpdateSystemParameters);

    // Listen to auth state changes
    _authBloc.stream.listen((authState) {
      if (authState.status == AuthStatus.authenticated) {
        _currentUserId = authState.user?.id;
      } else {
        _currentUserId = null;
      }
    });
  }

  Future<void> _onInitializeSystem(
    InitializeSystem event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: SystemOperationalStatus.initializing,
        isLoading: true,
      ));

      if (_currentUserId == null) {
        throw Exception('No authenticated user');
      }

      // Load components
      final components = await _userRepository.getAllComponents(userId: _currentUserId!);

      // Perform initial readiness check
      final readinessResult = await _performSystemCheck();

      // Load global state
      final globalState = await _globalRepository.getLatestState();

      // Setup global state subscription
      await _stateSubscription?.cancel();
      _stateSubscription = _globalRepository.watchSystemState().listen(
        (systemState) {
          if (systemState != null) {
            add(SaveSystemState(systemState.data));
            // Trigger readiness check on state updates
            add(CheckSystemReadiness());
          }
        },
        onError: (error) {
          add(SaveSystemState({'error': error.toString()}));
        },
      );

      emit(state.copyWith(
        status: readinessResult.isReady ?
          SystemOperationalStatus.ready :
          SystemOperationalStatus.initializing,
        components: components,
        currentSystemState: globalState?.data ?? {},
        lastStateUpdate: globalState?.timestamp,
        isLoading: false,
        systemIssues: readinessResult.issues,
        isReadinessCheckPassed: readinessResult.isReady,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: SystemOperationalStatus.error,
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onStartSystem(
    StartSystem event,
    Emitter<SystemStateState> emit,
  ) async {
    if (!state.canStart) {
      emit(state.copyWith(
        error: 'System cannot be started in current state',
      ));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true));

      await _globalRepository.saveSystemState({
        'status': 'running',
        'isSystemRunning': true,
        'timestamp': DateTime.now().toIso8601String(),
      });

      emit(state.copyWith(
        status: SystemOperationalStatus.running,
        isSystemRunning: true,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onStopSystem(
    StopSystem event,
    Emitter<SystemStateState> emit,
  ) async {
    if (!state.canStop) {
      emit(state.copyWith(
        error: 'System is not running',
      ));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true));

      await _globalRepository.saveSystemState({
        'status': 'ready',
        'isSystemRunning': false,
        'timestamp': DateTime.now().toIso8601String(),
      });

      emit(state.copyWith(
        status: SystemOperationalStatus.ready,
        isSystemRunning: false,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onEmergencyStop(
    EmergencyStop event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      await _globalRepository.saveSystemState({
        ...state.currentSystemState,
        'isRunning': false,
        'emergencyStoppedAt': DateTime.now().toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      emit(state.copyWith(
        status: SystemOperationalStatus.emergencyStopped,
        isSystemRunning: false,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onCheckSystemReadiness(
    CheckSystemReadiness event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Implement system readiness checks here
      final issues = _checkSystemIssues();

      emit(state.copyWith(
        systemIssues: issues,
        isReadinessCheckPassed: issues.isEmpty,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onSaveSystemState(
    SaveSystemState event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final stateData = {
        ...event.state,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Save to both repositories
      await _globalRepository.saveSystemState(stateData);
      if (_currentUserId != null) {
        await _userRepository.saveSystemState(
          SystemStateData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            data: stateData,
            timestamp: DateTime.now(),
          ),
          userId: _currentUserId!,
        );
      }

      emit(state.copyWith(
        currentSystemState: event.state,
        lastStateUpdate: DateTime.now(),
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onValidateSystemState(
    ValidateSystemState event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      // Implement state validation logic here
      final issues = _validateCurrentState();

      emit(state.copyWith(
        systemIssues: issues,
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  Future<void> _onUpdateSystemParameters(
    UpdateSystemParameters event,
    Emitter<SystemStateState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final updatedState = Map<String, dynamic>.from(state.currentSystemState);
      event.updates.forEach((component, values) {
        if (updatedState.containsKey('components')) {
          final components = updatedState['components'] as Map<String, dynamic>;
          if (components.containsKey(component)) {
            final componentData = components[component] as Map<String, dynamic>;
            componentData['currentValues'] = values;
          }
        }
      });

      await _globalRepository.saveSystemState(updatedState);

      emit(state.copyWith(
        currentSystemState: updatedState,
        lastStateUpdate: DateTime.now(),
        isLoading: false,
      ));
    } catch (error) {
      emit(state.copyWith(
        error: BlocUtils.handleError(error),
        isLoading: false,
      ));
    }
  }

  List<String> _checkSystemIssues() {
    final issues = <String>[];

    final components = state.currentSystemState['components'] as Map<String, dynamic>?;

    if (components == null || components.isEmpty) {
      issues.add('No components found in system');
      return issues;
    }

    components.forEach((componentName, componentData) {
      final data = componentData as Map<String, dynamic>;
      final isActivated = data['isActivated'] as bool? ?? false;
      final currentValues = data['currentValues'] as Map<String, dynamic>?;
      final setValues = data['setValues'] as Map<String, dynamic>?;

      if (!isActivated) {
        issues.add('$componentName is not activated');
      }

      if (currentValues != null && setValues != null) {
        currentValues.forEach((parameter, value) {
          final setValue = setValues[parameter];
          if (setValue != null && (value as num).abs() - (setValue as num).abs() > 0.1) {
            issues.add('$componentName: $parameter mismatch (current: $value, set: $setValue)');
          }
        });
      }
    });

    return issues;
  }

  List<String> _validateCurrentState() {
    final issues = <String>[];

    if (!state.isSystemRunning && state.status == SystemOperationalStatus.running) {
      issues.add('System status inconsistency detected');
    }

    final components = state.currentSystemState['components'] as Map<String, dynamic>?;
    if (components != null) {
      components.forEach((componentName, componentData) {
        final data = componentData as Map<String, dynamic>;
        final currentValues = data['currentValues'] as Map<String, dynamic>?;
        final minValues = data['minValues'] as Map<String, dynamic>?;
        final maxValues = data['maxValues'] as Map<String, dynamic>?;

        if (currentValues != null && minValues != null && maxValues != null) {
          currentValues.forEach((parameter, value) {
            final min = minValues[parameter] as num?;
            final max = maxValues[parameter] as num?;
            final current = value as num;

            if (min != null && current < min) {
              issues.add('$componentName: $parameter below minimum ($current < $min)');
            }
            if (max != null && current > max) {
              issues.add('$componentName: $parameter above maximum ($current > $max)');
            }
          });
        }
      });
    }

    return issues;
  }

  Future<ReadinessCheckResult> _performSystemCheck() async {
    final issues = <String>[];
    bool isReady = true;

    try {
      // 1. Check Component Initialization
      final componentResults = await Future.wait(
        state.components.map((component) => _checkComponentReadiness(component))
      );

      for (var result in componentResults) {
        issues.addAll(result.issues);
        if (!result.isReady) isReady = false;
      }

      // 2. Check System Parameters
      final parameterCheck = _validateSystemParameters();
      if (!parameterCheck.isValid) {
        issues.addAll(parameterCheck.issues);
        isReady = false;
      }

      // 3. Check Safety Systems
      final safetyCheck = await _checkSafetySystems();
      if (!safetyCheck.isValid) {
        issues.addAll(safetyCheck.issues);
        isReady = false;
      }

      // 4. Check Network Connectivity
      if (!await _checkNetworkConnectivity()) {
        issues.add('Network connectivity issues detected');
        isReady = false;
      }

      // Save readiness state
      await _userRepository.saveSystemState(
        SystemStateData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          data: {
            ...state.currentSystemState,
            'isReady': isReady,
            'readinessChecks': issues,
          },
          timestamp: DateTime.now(),
          isInitialized: true,
          isReady: isReady,
          readinessChecks: issues,
        ),
        userId: _currentUserId!,
      );

      return ReadinessCheckResult(
        isReady: isReady,
        issues: issues,
      );
    } catch (e) {
      issues.add('Error during system check: ${e.toString()}');
      return ReadinessCheckResult(
        isReady: false,
        issues: issues,
      );
    }
  }

  Future<ComponentCheckResult> _checkComponentReadiness(SystemComponent component) async {
    final issues = <String>[];

    if (!component.state.isInitialized) {
      issues.add('${component.name} not initialized');
    }

    if (!component.state.isConnected) {
      issues.add('${component.name} not connected');
    }

    if (component.state.hasError) {
      issues.add('${component.name} error: ${component.state.errorMessage}');
    }

    // Check component-specific parameters
    final parameterCheck = _validateComponentParameters(component);
    issues.addAll(parameterCheck.issues);

    return ComponentCheckResult(
      isReady: issues.isEmpty,
      issues: issues,
    );
  }

  ParameterValidationResult _validateSystemParameters() {
    final issues = <String>[];

    final params = state.currentSystemState;
    if (!params.containsKey('components')) {
      return ParameterValidationResult(isValid: false, issues: ['System parameters not initialized']);
    }

    try {
      final components = params['components'] as Map<String, dynamic>;

      // Check essential parameters with specific ranges
      _validateParameterRange(
        components,
        'Reaction Chamber',
        'temperature',
        15.0,
        1000.0,
        issues,
      );

      _validateParameterRange(
        components,
        'Pressure Control System',
        'pressure',
        0.1,
        10.0,
        issues,
      );

      return ParameterValidationResult(
        isValid: issues.isEmpty,
        issues: issues,
      );
    } catch (e) {
      return ParameterValidationResult(
        isValid: false,
        issues: ['Parameter validation error: ${e.toString()}'],
      );
    }
  }

  void _validateParameterRange(
    Map<String, dynamic> components,
    String componentName,
    String parameterName,
    double min,
    double max,
    List<String> issues,
  ) {
    final component = components[componentName] as Map<String, dynamic>?;
    if (component == null) {
      issues.add('$componentName not found');
      return;
    }

    final values = component['currentValues'] as Map<String, dynamic>?;
    if (values == null) {
      issues.add('$componentName values not initialized');
      return;
    }

    final value = values[parameterName] as double?;
    if (value == null) {
      issues.add('$componentName $parameterName not initialized');
      return;
    }

    if (value < min || value > max) {
      issues.add('$componentName $parameterName out of range ($min-$max): $value');
    }
  }

  Future<SafetyCheckResult> _checkSafetySystems() async {
    final issues = <String>[];

    // Check emergency stop system
    if (!_isEmergencyStopSystemOperational()) {
      issues.add('Emergency stop system not operational');
    }

    // Check safety interlocks
    if (!_areSafetyInterlocksEngaged()) {
      issues.add('Safety interlocks not properly engaged');
    }

    // Check alarm system
    if (!_isAlarmSystemOperational()) {
      issues.add('Alarm system not operational');
    }

    return SafetyCheckResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }

  Future<bool> _checkNetworkConnectivity() async {
    final connectivity = await Connectivity().checkConnectivity();
    return connectivity != ConnectivityResult.none;
  }

  ParameterValidationResult _validateComponentParameters(SystemComponent component) {
    final issues = <String>[];

    // Validate component-specific parameters
    for (var param in component.parameters.entries) {
      final value = param.value;
      final name = param.key;

      if (value == null) {
        issues.add('${component.name}: $name not initialized');
        continue;
      }

      // Add your component-specific validation logic here
      if (!_isParameterInValidRange(name, value)) {
        issues.add('${component.name}: $name out of valid range');
      }
    }

    return ParameterValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }

  bool _isParameterInValidRange(String paramName, dynamic value) {
    // Define parameter-specific validation ranges
    final ranges = {
      'temperature': {'min': 15.0, 'max': 1000.0},
      'pressure': {'min': 0.1, 'max': 10.0},
      // Add other parameters as needed
    };

    if (!ranges.containsKey(paramName)) return true;

    final range = ranges[paramName]!;
    if (value is! num) return false;

    return value >= range['min']! && value <= range['max']!;
  }

  bool _isEmergencyStopSystemOperational() {
    // Implement emergency stop system check
    final emergencySystem = state.currentSystemState['emergencySystem'];
    if (emergencySystem == null) return false;

    return emergencySystem['isOperational'] == true &&
           emergencySystem['lastTestPassed'] == true;
  }

  bool _areSafetyInterlocksEngaged() {
    // Implement safety interlocks check
    final safetySystem = state.currentSystemState['safetySystem'];
    if (safetySystem == null) return false;

    final interlocks = safetySystem['interlocks'] as Map<String, dynamic>?;
    return interlocks?.values.every((status) => status == true) ?? false;
  }

  bool _isAlarmSystemOperational() {
    // Implement alarm system check
    final alarmSystem = state.currentSystemState['alarmSystem'];
    if (alarmSystem == null) return false;

    return alarmSystem['isOperational'] == true &&
           alarmSystem['lastTestPassed'] == true;
  }

  @override
  Future<void> close() {
    _stateSubscription?.cancel();
    return super.close();
  }
}

class ReadinessCheckResult {
  final bool isReady;
  final List<String> issues;

  ReadinessCheckResult({
    required this.isReady,
    required this.issues,
  });
}

class ComponentCheckResult {
  final bool isReady;
  final List<String> issues;

  ComponentCheckResult({
    required this.isReady,
    required this.issues,
  });
}

class ParameterValidationResult {
  final bool isValid;
  final List<String> issues;

  ParameterValidationResult({
    required this.isValid,
    required this.issues,
  });
}

class SafetyCheckResult {
  final bool isValid;
  final List<String> issues;

  SafetyCheckResult({
    required this.isValid,
    required this.issues,
  });
}