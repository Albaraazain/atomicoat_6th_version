// lib/core/router/auth_guard.dart
import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';

@injectable
class AuthGuard extends AutoRouteGuard {
  final IAuthRepository _authRepository;

  AuthGuard(this._authRepository);

  @override
  Future<bool> canNavigate(NavigationResolver resolver, StackRouter router) async {
    final user = await _authRepository.getSignedInUser();

    if (user.isSome()) {
      return true;
    }

    router.push(const LoginRoute());
    return false;
  }
}
