// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/sign_out.dart';
import '../../../../core/errors/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;

  AuthBloc(this._signIn, this._signUp, this._signOut) : super(const AuthState.initial()) {
    on<AuthEvent>((event, emit) async {
      await event.map(
        signInRequested: (e) => _handleSignIn(e, emit),
        signUpRequested: (e) => _handleSignUp(e, emit),
        signOutRequested: (e) => _handleSignOut(e, emit),
      );
    });
  }

  Future<void> _handleSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());

    final result = await _signIn(SignInParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _handleSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());

    final result = await _signUp(SignUpParams(
      email: event.email,
      password: event.password,
      name: event.name,
      machineSerial: event.machineSerial,
    ));

    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (user) => emit(AuthState.authenticated(user)),
    );
  }

  Future<void> _handleSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthState.authenticating());

    final result = await _signOut();

    result.fold(
      (failure) => emit(AuthState.failure(failure)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }
}

