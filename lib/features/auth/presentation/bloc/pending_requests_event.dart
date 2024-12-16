// lib/features/auth/presentation/bloc/pending_requests_event.dart
part of 'pending_requests_bloc.dart';

@freezed
class PendingRequestsEvent with _$PendingRequestsEvent {
  const factory PendingRequestsEvent.loaded() = _Loaded;
  const factory PendingRequestsEvent.approved({
    required String userId,
  }) = RequestApproved;
  const factory PendingRequestsEvent.denied({
    required String userId,
  }) = RequestDenied;
  const factory PendingRequestsEvent.refreshRequested() = _RefreshRequested;
}

// lib/features/auth/presentation/bloc/pending_requests_state.dart
part of 'pending_requests_bloc.dart';

@freezed
class PendingRequestsState with _$PendingRequestsState {
  const factory PendingRequestsState.initial() = Initial;
  const factory PendingRequestsState.loading() = Loading;
  const factory PendingRequestsState.loaded(List<UserRequest> requests) = PendingRequestsLoaded;
  const factory PendingRequestsState.failure(Failure failure) = _Failure;
}

