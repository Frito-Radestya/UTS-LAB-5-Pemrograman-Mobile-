import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kage/data/local/local_box.dart';
import 'package:kage/data/quiz_bank.dart';
import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/data/repositories/progress_repository.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/data/repositories/settings_repository.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/settings/reminder_service.dart';
import 'package:kage/features/settings/settings_controller.dart';

/// Titik komposisi seluruh state aplikasi.
///
/// Controller tetap terpisah dan hanya dihubungkan di sini, sehingga tidak ada
/// satu kelas besar yang mengetahui autentikasi, kuis, riwayat, dan pengaturan
/// sekaligus.
class AppServices {
  AppServices({
    AuthRepository? authRepository,
    HistoryRepository? historyRepository,
    QuizRepository? quizRepository,
    ProgressRepository? progressRepository,
    SettingsRepository? settingsRepository,
    ReminderService? reminderService,
  }) {
    this.reminderService = reminderService ?? NoopReminderService();
    this.authRepository = authRepository ?? InMemoryAuthRepository();
    this.historyRepository = historyRepository ?? InMemoryHistoryRepository();
    this.quizRepository = quizRepository ?? LocalQuizRepository.empty();
    this.progressRepository =
        progressRepository ?? InMemoryProgressRepository();
    this.settingsRepository =
        settingsRepository ?? InMemorySettingsRepository();
    auth = AuthController(repository: this.authRepository);
    settings = SettingsController(
      repository: this.settingsRepository,
      reminder: reminderService,
    );
    history = HistoryController(repository: this.historyRepository);
    progress = ProgressController(repository: this.progressRepository);
    quiz = QuizController(
      onCompleted: _recordQuizResult,
      questions: this.quizRepository,
      progress: this.progressRepository,
    );
    routerListenable = Listenable.merge([auth, quiz]);
  }

  /// Menyusun layanan dengan penyimpanan lokal permanen.
  ///
  /// `shared_preferences` menyimpan sesi login dan pengaturan, sedangkan Hive
  /// menyimpan riwayat kuis, XP, dan kuis yang sedang berjalan. Bank soal dibaca
  /// dari `assets/data/*.json`. Semuanya dimuat sebelum `runApp` sehingga
  /// halaman langsung menampilkan kondisi terakhir.
  static Future<AppServices> create() async {
    final preferences = await SharedPreferences.getInstance();
    final box = await openKageBox();
    final bank = await loadQuizBank();
    return AppServices(
      authRepository: LocalAuthRepository(preferences),
      settingsRepository: LocalSettingsRepository(preferences),
      reminderService: LocalReminderService(),
      historyRepository: LocalHistoryRepository(box),
      progressRepository: LocalProgressRepository(box),
      quizRepository: LocalQuizRepository(bank),
    );
  }

  late final AuthController auth;
  late final SettingsController settings;
  late final HistoryController history;
  late final ProgressController progress;
  late final QuizController quiz;
  late final AuthRepository authRepository;
  late final HistoryRepository historyRepository;
  late final QuizRepository quizRepository;
  late final ProgressRepository progressRepository;
  late final SettingsRepository settingsRepository;
  late final ReminderService reminderService;

  /// Perubahan yang memengaruhi keputusan redirect router.
  late final Listenable routerListenable;

  void _recordQuizResult(QuizResult result) {
    history.addResult(result);
    progress.addXp((result.score * result.difficulty.xpMultiplier).round());
  }

  void dispose() {
    quiz.dispose();
    progress.dispose();
    history.dispose();
    settings.dispose();
    auth.dispose();
  }
}
