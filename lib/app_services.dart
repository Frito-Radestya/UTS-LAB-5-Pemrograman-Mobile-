import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kage/data/local/local_box.dart';
import 'package:kage/data/quiz_bank.dart';
import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/data/repositories/progress_repository.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/models/models.dart';

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
    history = HistoryController(repository: this.historyRepository);
    progress = ProgressController(repository: this.progressRepository);
    quiz = QuizController(
      onCompleted: _recordQuizResult,
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
  late final HistoryController history;
  late final ProgressController progress;
  late final QuizController quiz;
  late final AuthRepository authRepository;
  late final HistoryRepository historyRepository;
  late final QuizRepository quizRepository;
  late final ProgressRepository progressRepository;
  late final Listenable routerListenable;

  void _recordQuizResult(QuizResult result) {
    history.addResult(result);
    progress.addXp((result.score * result.difficulty.xpMultiplier).round());
  }

  void dispose() {
    quiz.dispose();
    progress.dispose();
    history.dispose();
    auth.dispose();
  }
}
