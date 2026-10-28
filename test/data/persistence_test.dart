import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kage/app_services.dart';
import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/data/repositories/progress_repository.dart';
import 'package:kage/data/repositories/settings_repository.dart';
import 'package:kage/models/models.dart';

import '../support/quiz_bank.dart';

Future<SharedPreferences> _preferences() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  return SharedPreferences.getInstance();
}

QuizResult _result({
  CategoryId categoryId = CategoryId.logika,
  int score = 80,
  DateTime? playedAt,
  Difficulty difficulty = Difficulty.menengah,
}) {
  return QuizResult(
    categoryId: categoryId,
    score: score,
    correct: score ~/ 10,
    total: 10,
    duration: const Duration(minutes: 3, seconds: 5),
    playedAt: playedAt ?? DateTime(2026, 10, 25, 20, 15),
    difficulty: difficulty,
  );
}

InProgressQuiz _resume() {
  return const InProgressQuiz(
    categoryId: CategoryId.sains,
    difficulty: Difficulty.ahli,
    index: 2,
    answers: <int?>[1, null, 3, null],
    submitted: <bool>[true, false, true, false],
    questionOrder: <int>[4, 2, 0, 3],
    optionOrders: <List<int>>[
      <int>[2, 0, 1, 3],
      <int>[1, 3, 0, 2],
      <int>[0, 1, 2, 3],
      <int>[3, 2, 1, 0],
    ],
    elapsed: Duration(minutes: 4, seconds: 12),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  var boxCounter = 0;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('kage_persistence_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<Box<dynamic>> openBox() {
    boxCounter += 1;
    return Hive.openBox<dynamic>('kage_test_$boxCounter');
  }

  group('LocalAuthRepository', () {
    test('menyimpan profil dan sesi login', () async {
      final preferences = await _preferences();
      final repository = LocalAuthRepository(preferences);
      expect(repository.loadProfile(), isNull);

      repository.saveProfile(
        const AuthProfile(fullName: 'Budi Santoso', email: 'budi@example.com'),
      );

      final restored = LocalAuthRepository(preferences).loadProfile();
      expect(restored?.fullName, 'Budi Santoso');
      expect(restored?.email, 'budi@example.com');
    });

    test('logout menghapus sesi tersimpan', () async {
      final preferences = await _preferences();
      final repository = LocalAuthRepository(preferences)
        ..saveProfile(
          const AuthProfile(fullName: 'Budi', email: 'budi@example.com'),
        );

      repository.clearProfile();

      expect(LocalAuthRepository(preferences).loadProfile(), isNull);
    });
  });

  group('LocalSettingsRepository', () {
    test('menyimpan preferensi notifikasi', () async {
      final preferences = await _preferences();
      expect(LocalSettingsRepository(preferences).loadNotifications(), isTrue);

      LocalSettingsRepository(preferences).saveNotifications(false);

      expect(LocalSettingsRepository(preferences).loadNotifications(), isFalse);
    });
  });

  group('LocalHistoryRepository', () {
    test('menyimpan dan memulihkan seluruh field hasil kuis', () async {
      final box = await openBox();
      addTearDown(box.close);
      final repository = LocalHistoryRepository(box);
      expect(repository.load(), isEmpty);

      repository.save([
        _result(),
        _result(score: 100, categoryId: CategoryId.sejarah),
      ]);

      final loaded = LocalHistoryRepository(box).load();
      expect(loaded, hasLength(2));
      expect(loaded.first.categoryId, CategoryId.logika);
      expect(loaded.first.score, 80);
      expect(loaded.first.difficulty, Difficulty.menengah);
      expect(loaded.first.duration, const Duration(minutes: 3, seconds: 5));
      expect(loaded.first.playedAt, DateTime(2026, 10, 25, 20, 15));
      expect(loaded.last.categoryId, CategoryId.sejarah);
    });

    test('mengabaikan data rusak tanpa gagal', () async {
      final box = await openBox();
      addTearDown(box.close);
      final repository = LocalHistoryRepository(box);

      await box.put('history', 'bukan json');
      expect(repository.load(), isEmpty);

      await box.put('history', '{"skor": 80}');
      expect(repository.load(), isEmpty);

      await box.put('history', '[{"categoryId":"tidak-ada","score":80}]');
      expect(repository.load(), isEmpty);
    });

    test('clear mengosongkan riwayat tersimpan', () async {
      final box = await openBox();
      addTearDown(box.close);
      final repository = LocalHistoryRepository(box)..save([_result()]);

      repository.clear();

      expect(LocalHistoryRepository(box).load(), isEmpty);
    });
  });

  group('LocalProgressRepository', () {
    test('menyimpan XP dan resume kuis lengkap dengan urutan acak', () async {
      final box = await openBox();
      addTearDown(box.close);
      final repository = LocalProgressRepository(box);
      expect(repository.loadXp(), 0);
      expect(repository.loadResume(), isNull);

      repository.saveXp(420);
      repository.saveResume(_resume());

      final restored = LocalProgressRepository(box);
      expect(restored.loadXp(), 420);

      final resume = restored.loadResume();
      expect(resume, isNotNull);
      expect(resume!.categoryId, CategoryId.sains);
      expect(resume.difficulty, Difficulty.ahli);
      expect(resume.index, 2);
      expect(resume.answers, <int?>[1, null, 3, null]);
      expect(resume.submitted, <bool>[true, false, true, false]);
      expect(resume.questionOrder, <int>[4, 2, 0, 3]);
      expect(resume.optionOrders, <List<int>>[
        <int>[2, 0, 1, 3],
        <int>[1, 3, 0, 2],
        <int>[0, 1, 2, 3],
        <int>[3, 2, 1, 0],
      ]);
      expect(resume.elapsed, const Duration(minutes: 4, seconds: 12));
    });

    test('menghapus resume saat kuis dibuang', () async {
      final box = await openBox();
      addTearDown(box.close);
      LocalProgressRepository(box)
        ..saveResume(_resume())
        ..saveResume(null);

      expect(LocalProgressRepository(box).loadResume(), isNull);
    });

    test('mengabaikan resume rusak', () async {
      final box = await openBox();
      addTearDown(box.close);

      await box.put('progress.resume', '{"categoryId":"sains"}');

      expect(LocalProgressRepository(box).loadResume(), isNull);
    });
  });

  test('riwayat, XP, resume, sesi, dan pengaturan bertahan setelah '
      'aplikasi dibuka ulang', () async {
    final preferences = await _preferences();
    const boxName = 'kage_restart_test';

    final firstBox = await Hive.openBox<dynamic>(boxName);
    final first = AppServices(
      authRepository: LocalAuthRepository(preferences),
      settingsRepository: LocalSettingsRepository(preferences),
      historyRepository: LocalHistoryRepository(firstBox),
      progressRepository: LocalProgressRepository(firstBox),
      quizRepository: testQuizBank(),
    );
    first.auth.register(
      name: 'Budi',
      email: 'budi@example.com',
      password: 'rahasia123',
    );
    first.settings.setNotifications(false);

    // Kuis yang diselesaikan mengisi riwayat dan XP.
    first.quiz.startQuiz(CategoryId.logika);
    while (true) {
      final question = first.quiz.currentQuestion;
      expect(question, isNotNull);
      first.quiz.selectAnswer(question!.correctIndex);
      if (first.quiz.isLastQuestion) break;
      first.quiz.nextQuestion();
    }
    first.quiz.finishQuiz();
    final xpAfterFirstRun = first.progress.xp;
    expect(xpAfterFirstRun, greaterThan(0));
    expect(first.quiz.resume, isNull);

    // Kuis baru disimpan untuk dilanjutkan nanti.
    first.quiz.startQuiz(CategoryId.sains, difficulty: Difficulty.menengah);
    final savedQuestion = first.quiz.currentQuestion!;
    first.quiz.selectAnswer(savedQuestion.correctIndex);
    first.quiz.saveProgress();

    first.dispose();
    await firstBox.close();

    // Membuka ulang aplikasi: repository dan controller dibuat dari nol dengan
    // penyimpanan yang sama.
    final secondBox = await Hive.openBox<dynamic>(boxName);
    final second = AppServices(
      authRepository: LocalAuthRepository(preferences),
      settingsRepository: LocalSettingsRepository(preferences),
      historyRepository: LocalHistoryRepository(secondBox),
      progressRepository: LocalProgressRepository(secondBox),
      quizRepository: testQuizBank(),
    );
    addTearDown(() async {
      second.dispose();
      await secondBox.close();
    });

    expect(second.auth.loggedIn, isTrue);
    expect(second.auth.fullName, 'Budi');
    expect(second.auth.email, 'budi@example.com');
    expect(second.settings.notifications, isFalse);
    expect(second.history.totalQuizzes, 1);
    expect(second.history.history.first.score, 100);
    expect(second.progress.xp, xpAfterFirstRun);

    final resume = second.quiz.resume;
    expect(resume, isNotNull);
    expect(resume!.categoryId, CategoryId.sains);
    expect(resume.difficulty, Difficulty.menengah);
    expect(resume.index, 0);
    expect(resume.answers.first, savedQuestion.correctIndex);
    expect(resume.questionOrder, hasLength(greaterThanOrEqualTo(1)));

    second.quiz.continueAdventure();
    expect(second.quiz.activeCategory, CategoryId.sains);
    expect(second.quiz.selectedDifficulty, Difficulty.menengah);
    expect(second.quiz.currentQuestion?.prompt, savedQuestion.prompt);
    expect(second.quiz.answers.first, savedQuestion.correctIndex);
  });
}
