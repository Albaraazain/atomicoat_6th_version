// lib/features/auth/presentation/bloc/user_management_event.dart
part of 'user_management_bloc.dart';

@freezed
class UserManagementEvent with _$UserManagementEvent {
  const factory UserManagementEvent.loaded() = _Loaded;
  const factory UserManagementEvent.roleChanged({
    required String userId,
    required UserRole newRole,
  }) = RoleChanged;
  const factory UserManagementEvent.statusChanged({
    required String userId,
    required String newStatus,
  }) = StatusChanged;
  const factory UserManagementEvent.userDeleted({
    required String userId,
  }) = UserDeleted;
  const factory UserManagementEvent.refreshRequested() = _RefreshRequested;
}

// lib/features/auth/presentation/bloc/user_management_state.dart
part of 'user_management_bloc.dart';

@freezed
class UserManagementState with _$UserManagementState {
  const factory UserManagementState.initial() = Initial;
  const factory UserManagementState.loading() = Loading;
  const factory UserManagementState.loaded(List<User> users) = UserManagementLoaded;
  const factory UserManagementState.failure(Failure failure) = _Failure;
}

