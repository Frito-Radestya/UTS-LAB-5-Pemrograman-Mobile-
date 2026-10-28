import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/features/auth/auth_controller.dart';

class AppServices {
  AppServices({
    AuthRepository? authRepository,
  }) {
    this.authRepository = authRepository ?? InMemoryAuthRepository();
    auth = AuthController(repository: this.authRepository);
    routerListenable = auth;
  }

  static Future<AppServices> create() async {
    final preferences = await SharedPreferences.getInstance();
    return AppServices(
      authRepository: LocalAuthRepository(preferences),
    );
  }

  late final AuthController auth;
  late final AuthRepository authRepository;
  late final Listenable routerListenable;

  void dispose() {
    auth.dispose();
  }
}

