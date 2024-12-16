// lib/features/auth/presentation/bloc/admin_dashboard_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/i_user_request_repository.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../../../core/errors/failures.dart';

part 'admin_dashboard_event.dart';
part 'admin_dashboard_state.dart';
part 'admin_dashboard_bloc.freezed.dart';

@injectable
class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final IUserRequestRepository _userRequestRepository;
  final IAuthRepository _authRepository;

  AdminDashboardBloc(
    this._userRequestRepository,
    this._authRepository,
  ) : super(const AdminDashboardState.initial()) {
    on<AdminDashboardEvent>((event, emit) async {
      await event.map(
        loaded: (_) => _handleLoaded(emit),
        refreshRequested: (_) => _handleLoaded(emit),
      );
    });
  }

  Future<void> _handleLoaded(Emitter<AdminDashboardState> emit) async {
    emit(const AdminDashboardState.loading());

    final pendingRequestsCount = await _userRequestRepository.getPendingRequestCount();
    final usersCount = await _authRepository.getUserCount();

    emit(
      pendingRequestsCount.fold(
        (failure) => AdminDashboardState.failure(failure),
        (requestCount) => usersCount.fold(
          (failure) => AdminDashboardState.failure(failure),
          (userCount) => AdminDashboardState.loaded(
            pendingRequestsCount: requestCount,
            totalUsersCount: userCount,
          ),
        ),
      ),
    );
  }
}

