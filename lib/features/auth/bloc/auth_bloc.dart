// lib/features/auth/bloc/auth_bloc.dart
import 'package:experiment_planner/features/auth/bloc/auth_event.dart';
import 'package:experiment_planner/features/auth/bloc/auth_state.dart';
import 'package:experiment_planner/features/auth/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState.initial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
        name: event.name,
        machineSerial: event.machineSerial,
      );

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Registration successful. Please wait for admin approval.',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.signOut();
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
