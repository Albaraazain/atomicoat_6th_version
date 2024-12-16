// lib/features/auth/presentation/bloc/pending_requests_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/i_user_request_repository.dart';
import '../../domain/entities/user_request.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/enums/user_request_status.dart';

part 'pending_requests_event.dart';
part 'pending_requests_state.dart';
part 'pending_requests_bloc.freezed.dart';

@injectable
class PendingRequestsBloc extends Bloc<PendingRequestsEvent, PendingRequestsState> {
  final IUserRequestRepository _repository;

  PendingRequestsBloc(this._repository)
      : super(const PendingRequestsState.initial()) {
    on<PendingRequestsEvent>((event, emit) async {
      await event.map(
        loaded: (_) => _handleLoaded(emit),
        approved: (e) => _handleApproved(e, emit),
        denied: (e) => _handleDenied(e, emit),
        refreshRequested: (_) => _handleLoaded(emit),
      );
    });
  }

  Future<void> _handleLoaded(Emitter<PendingRequestsState> emit) async {
    emit(const PendingRequestsState.loading());

    final result = await _repository.getPendingRequests();

    emit(result.fold(
      (failure) => PendingRequestsState.failure(failure),
      (requests) => PendingRequestsState.loaded(requests),
    ));
  }

  Future<void> _handleApproved(
    RequestApproved event,
    Emitter<PendingRequestsState> emit,
  ) async {
    emit(const PendingRequestsState.loading());

    final result = await _repository.updateStatus(
      event.userId,
      UserRequestStatus.approved,
    );

    result.fold(
      (failure) => emit(PendingRequestsState.failure(failure)),
      (_) => add(const PendingRequestsEvent.refreshRequested()),
    );
  }

  Future<void> _handleDenied(
    RequestDenied event,
    Emitter<PendingRequestsState> emit,
  ) async {
    emit(const PendingRequestsState.loading());

    final result = await _repository.updateStatus(
      event.userId,
      UserRequestStatus.denied,
    );

    result.fold(
      (failure) => emit(PendingRequestsState.failure(failure)),
      (_) => add(const PendingRequestsEvent.refreshRequested()),
    );
  }
}

