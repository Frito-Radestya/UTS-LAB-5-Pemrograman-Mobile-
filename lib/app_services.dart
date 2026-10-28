import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kage/data/local/local_box.dart';
import 'package:kage/data/quiz_bank.dart';
import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/data/repositories/progress_repository.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';

class AppServices {
  AppServices({
    AuthRepository? authRepository,
    HistoryRepository? historyRepository,
    QuizRepository? quizRepository,
    ProgressRepository? progressRepository,
  }) {
    this.authRepository = authRepository ?? InMemoryAuthRepository();
    this.historyRepository = historyRepository ?? InMemoryHistoryRepository();
    this.quizRepository = quizRepository ?? LocalQuizRepository.empty();
    this.progressRepository =
        progressRepository ?? InMemoryProgressRepository();

    auth = AuthController(repository: this.authRepository);
    quiz = QuizController(
      questions: this.quizRepository,
      progress: this.progressRepository,
    );
    routerListenable = Listenable.merge([auth, quiz]);
  }

  static Future<AppServices> create() async {
    final preferences = await SharedPreferences.getInstance();
    final box = await openKageBox();
    final bank = await loadQuizBank();
    return AppServices(
      authRepository: LocalAuthRepository(preferences),
      historyRepository: LocalHistoryRepository(box),
      progressRepository: LocalProgressRepository(box),
      quizRepository: LocalQuizRepository(bank),
    );
  }

  late final AuthController auth;
  late final QuizController quiz;
  late final AuthRepository authRepository;
  late final HistoryRepository historyRepository;
  late final QuizRepository quizRepository;
  late final ProgressRepository progressRepository;
  late final Listenable routerListenable;

  void dispose() {
    quiz.dispose();
    auth.dispose();
  }
}
