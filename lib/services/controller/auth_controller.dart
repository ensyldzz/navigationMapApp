import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_app/models/user_model.dart';
import 'package:map_app/services/auth_repository.dart';
import 'package:map_app/helpers/constant/enums.dart';

class AuthController {
  final AuthRepository authRepository;
  AuthController({
    required this.authRepository,
  });

  Future<void> saveUserInfo(UserModel userModel, bool isAdmin) async {
    return await authRepository.saveUserInfo(userModel, isAdmin);
  }

  Future<AuthResultStatus> createAccount(
      String email, String password, String name, String lastName, bool isAdmin) async {
    return await authRepository.createAccount(email, name, lastName, password, isAdmin);
  }

  Future<AuthResultStatus> login(String email, String password, bool isAdmin) async {
    return await authRepository.login(email, password, isAdmin);
  }

  Future<void> logout() async {
    return await authRepository.logout();
  }
}

final authControllerProvider = Provider((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository: authRepository);
});
