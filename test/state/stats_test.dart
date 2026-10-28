import 'package:flutter_test/flutter_test.dart';
import 'package:kage/data/quiz_data.dart';
import 'package:kage/models/models.dart';
import 'package:kage/app_services.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';

import '../support/quiz_bank.dart';

QuizResult _result({
  CategoryId categoryId = CategoryId.sains,
  int score = 80,
  int correct = 8,
  int total = 10,
  int day = 20,
}) {
  return QuizResult(
    categoryId: categoryId,
    score: score,
    correct: correct,
    total: total,
    duration: const Duration(minutes: 2),
    playedAt: DateTime(2026, 10, day, 20),
    difficulty: Difficulty.pemula,
  );
}

void main() {
  group('T-01 statistik riwayat', () {
    test('statistik kosong bernilai nol', () {
      final history = HistoryController();
      addTearDown(history.dispose);

      expect(history.totalQuizzes, 0);
      expect(history.bestScore, 0);
      expect(history.averageScore, 0);
      expect(history.accuracyPercent, 0);
      expect(history.completedCategories, 0);
    });

    test('rata-rata, akurasi, skor terbaik, dan kategori dihitung benar', () {
      final history = HistoryController();
      addTearDown(history.dispose);
      history.addResults([
        _result(score: 80, correct: 8, day: 22),
        _result(
          categoryId: CategoryId.logika,
          score: 100,
          correct: 10,
          day: 21,
        ),
        _result(score: 60, correct: 6, day: 20),
      ]);

      expect(history.totalQuizzes, 3);
      expect(history.bestScore, 100);
      expect(history.averageScore, 80);
      expect(history.accuracyPercent, 80);
      expect(history.completedCategories, 2);
      expect(history.bestFor(CategoryId.sains), 80);
      expect(history.bestFor(CategoryId.logika), 100);
      expect(history.bestFor(CategoryId.sejarah), 0);
    });

    test('akurasi memperhitungkan total soal yang berbeda', () {
      final history = HistoryController();
      addTearDown(history.dispose);
      history.addResults([
        _result(correct: 8, total: 10),
        _result(correct: 9, total: 20),
      ]);

      expect(history.accuracyPercent, 57);
    });
  });

  group('T-01 badge', () {
    test('badge pertama dan sempurna mengikuti riwayat', () {
      final history = HistoryController();
      addTearDown(history.dispose);

      expect(history.badges.firstWhere((b) => b.id == 'first').earned, isFalse);
      history.addResult(_result(score: 100, correct: 10));
      expect(history.badges.firstWhere((b) => b.id == 'first').earned, isTrue);
      expect(
        history.badges.firstWhere((b) => b.id == 'perfect').earned,
        isTrue,
      );
    });

    test('explorer dan master membutuhkan semua kategori', () {
      final history = HistoryController();
      addTearDown(history.dispose);
      for (final category in categories) {
        history.addResult(_result(categoryId: category.id, score: 100));
      }

      expect(
        history.badges.firstWhere((b) => b.id == 'explorer').earned,
        isTrue,
      );
      expect(history.badges.firstWhere((b) => b.id == 'master').earned, isTrue);
    });
  });

  group('T-01 perilaku kontroler', () {
    test('login, update profil, dan logout mengubah state auth', () {
      final auth = AuthController();
      addTearDown(auth.dispose);

      auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );
      expect(auth.loggedIn, isTrue);
      expect(auth.fullName, 'Budi');
      expect(auth.email, 'budi@example.com');

      auth.updateProfile(name: 'Budi Santoso');
      expect(auth.fullName, 'Budi Santoso');
      expect(auth.email, 'budi@example.com');

      auth.logout();
      expect(auth.loggedIn, isFalse);
    });

    test('discardProgress menghapus sesi tersimpan', () {
      final quiz = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains);
      addTearDown(quiz.dispose);
      quiz.saveProgress();
      expect(quiz.resume, isNotNull);

      quiz.discardProgress();

      expect(quiz.resume, isNull);
    });

    test(
      'nextQuestion berhenti di soal terakhir dan finish mencatat hasil',
      () {
        final app = AppServices(quizRepository: testQuizBank())
          ..quiz.startQuiz(CategoryId.sains);
        addTearDown(app.dispose);

        while (!app.quiz.isLastQuestion) {
          app.quiz.nextQuestion();
        }

        expect(app.quiz.questionIndex, app.quiz.totalQuestions - 1);
        app.quiz.finishQuiz();
        expect(app.history.totalQuizzes, 1);
        expect(app.history.history.first, app.quiz.lastResult);
      },
    );

    test('hasil kuis terhubung ke riwayat dan XP', () {
      final app = AppServices(quizRepository: testQuizBank())
        ..quiz.startQuiz(CategoryId.sains, difficulty: Difficulty.ahli);
      addTearDown(app.dispose);

      while (!app.quiz.isLastQuestion) {
        app.quiz.selectAnswer(app.quiz.currentQuestion!.correctIndex);
        app.quiz.submitCurrent();
        app.quiz.nextQuestion();
      }
      app.quiz.selectAnswer(app.quiz.currentQuestion!.correctIndex);
      app.quiz.submitCurrent();
      app.quiz.finishQuiz();

      expect(app.history.totalQuizzes, 1);
      expect(app.history.history.first.score, 100);
      expect(app.progress.xp, 200);
      expect(app.progress.level, 2);
    });

    test('pengaturan notifikasi dapat diubah', () {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);

      expect(app.settings.notifications, isTrue);
      app.settings.setNotifications(false);
      expect(app.settings.notifications, isFalse);
    });
  });
}
