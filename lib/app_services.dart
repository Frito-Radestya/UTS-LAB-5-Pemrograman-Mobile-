import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kage/data/local/local_box.dart';
import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/data/repositories/progress_repository.dart';
import 'package:kage/features/auth/auth_controller.dart';

class AppServices {
  AppServices({
    AuthRepository? authRepository,
    HistoryRepository? historyRepository,
    ProgressRepository? progressRepository,
  }) {
    this.authRepository = authRepository ?? InMemoryAuthRepository();
    this.historyRepository = historyRepository ?? InMemoryHistoryRepository();
    this.progressRepository =
        progressRepository ?? InMemoryProgressRepository();
    auth = AuthController(repository: this.authRepository);
    routerListenable = auth;
  }

  static Future<AppServices> create() async {
    final preferences = await SharedPreferences.getInstance();
    final box = await openKageBox();
    return AppServices(
      authRepository: LocalAuthRepository(preferences),
      historyRepository: LocalHistoryRepository(box),
      progressRepository: LocalProgressRepository(box),
    );
  }

  late final AuthController auth;
  late final AuthRepository authRepository;
  late final HistoryRepository historyRepository;
  late final ProgressRepository progressRepository;
  late final Listenable routerListenable;

  void dispose() {
    auth.dispose();
  }
}
