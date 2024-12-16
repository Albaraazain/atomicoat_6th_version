// lib/core/router/admin_guard.dart
import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../core/enums/user_role.dart';

@injectable
class AdminGuard extends AutoRouteGuard {
  final IAuthRepository _authRepository;

  AdminGuard(this._authRepository);

  @override
  Future<bool> canNavigate(NavigationResolver resolver, StackRouter router) async {
    final userOption = await _authRepository.getSignedInUser();

    if (userOption.isSome()) {
      final user = userOption.getOrElse(() => throw Error());
      if (user.role == UserRole.admin) {
        return true;
      }
    }

    router.push(const LoginRoute());
    return false;
  }
}
