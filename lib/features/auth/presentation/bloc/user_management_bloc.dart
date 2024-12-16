// lib/features/auth/presentation/bloc/user_management_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/enums/user_role.dart';

part 'user_management_event.dart';
part 'user_management_state.dart';
part 'user_management_bloc.freezed.dart';

@injectable
class UserManagementBloc extends Bloc<UserManagementEvent, UserManagementState> {
  final IAuthRepository _authRepository;

  UserManagementBloc(this._authRepository)
      : super(const UserManagementState.initial()) {
    on<UserManagementEvent>((event, emit) async {
      await event.map(
        loaded: (_) => _handleLoaded(emit),
        roleChanged: (e) => _handleRoleChanged(e, emit),
                statusChanged: (e) => _handleStatusChanged(e, emit),
        userDeleted: (e) => _handleUserDeleted(e, emit),
        refreshRequested: (_) => _handleLoaded(emit),
      );
    });
  }

  Future<void> _handleLoaded(Emitter<UserManagementState> emit) async {
    emit(const UserManagementState.loading());

    final result = await _authRepository.getAllUsers();

    emit(result.fold(
      (failure) => UserManagementState.failure(failure),
      (users) => UserManagementState.loaded(users),
    ));
  }

  Future<void> _handleRoleChanged(
    RoleChanged event,
    Emitter<UserManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserManagementLoaded) return;

    emit(UserManagementState.loading());

    final result = await _authRepository.updateUserRole(
      event.userId,
      event.newRole,
    );

    result.fold(
      (failure) => emit(UserManagementState.failure(failure)),
      (_) => add(const UserManagementEvent.refreshRequested()),
    );
  }

  Future<void> _handleStatusChanged(
    StatusChanged event,
    Emitter<UserManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserManagementLoaded) return;

    emit(UserManagementState.loading());

    final result = await _authRepository.updateUserStatus(
      event.userId,
      event.newStatus,
    );

    result.fold(
      (failure) => emit(UserManagementState.failure(failure)),
      (_) => add(const UserManagementEvent.refreshRequested()),
    );
  }

  Future<void> _handleUserDeleted(
    UserDeleted event,
    Emitter<UserManagementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserManagementLoaded) return;

    emit(UserManagementState.loading());

    final result = await _authRepository.deleteUser(event.userId);

    result.fold(
      (failure) => emit(UserManagementState.failure(failure)),
      (_) => add(const UserManagementEvent.refreshRequested()),
    );
  }
}


