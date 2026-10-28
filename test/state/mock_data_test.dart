import 'package:flutter_test/flutter_test.dart';
import 'package:kage/data/quiz_data.dart';
import 'package:kage/models/models.dart';
import 'package:kage/app_services.dart';
import 'package:kage/features/auth/auth_controller.dart';

import '../support/quiz_bank.dart';

void main() {
  group('K-07 data akun baru tanpa mock', () {
    test('akun baru dimulai dari keadaan kosong', () {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);

      expect(app.auth.loggedIn, isFalse);
      expect(app.auth.fullName, isEmpty);
      expect(app.auth.email, isEmpty);
      expect(app.progress.xp, 0);
      expect(app.progress.level, 1);
      expect(app.history.streak, 0);
      expect(app.history.history, isEmpty);
      expect(app.quiz.resume, isNull);
      expect(app.history.learningPathDone, 0);
      expect(app.history.bestFor(CategoryId.sains), 0);
      expect(
        app.history.badges.firstWhere((b) => b.id == 'streak').earned,
        isFalse,
      );
    });

    test('nama dan email berasal dari data akun yang masuk', () {
      final auth = AuthController();
      addTearDown(auth.dispose);

      auth.register(
        name: 'Ayu Lestari',
        email: 'ayu@example.com',
        password: 'rahasia123',
      );

      expect(auth.fullName, 'Ayu Lestari');
      expect(auth.email, 'ayu@example.com');
      expect(auth.firstName, 'Ayu');
      expect(auth.initial, 'A');
    });

    test('progres belajar dihitung dari kategori yang diselesaikan', () {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      app.history.addResults([
        QuizResult(
          categoryId: CategoryId.sains,
          score: 80,
          correct: 8,
          total: 10,
          duration: const Duration(minutes: 2),
          playedAt: DateTime(2026, 10, 20),
          difficulty: Difficulty.pemula,
        ),
        QuizResult(
          categoryId: CategoryId.sains,
          score: 90,
          correct: 9,
          total: 10,
          duration: const Duration(minutes: 2),
          playedAt: DateTime(2026, 10, 21),
          difficulty: Difficulty.pemula,
        ),
        QuizResult(
          categoryId: CategoryId.logika,
          score: 100,
          correct: 10,
          total: 10,
          duration: const Duration(minutes: 2),
          playedAt: DateTime(2026, 10, 22),
          difficulty: Difficulty.pemula,
        ),
      ]);

      expect(app.history.completedCategories, 2);
      expect(app.history.learningPathDone, 2);
      expect(app.history.bestFor(CategoryId.sains), 90);
    });

    test('badge Streak 7 mengikuti nilai streak nyata', () {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      final now = DateTime.now();
      QuizResult dayResult(int daysAgo) => QuizResult(
        categoryId: CategoryId.sains,
        score: 100,
        correct: 10,
        total: 10,
        duration: const Duration(minutes: 2),
        playedAt: DateTime(now.year, now.month, now.day - daysAgo, 20),
        difficulty: Difficulty.pemula,
      );

      app.history.addResults([for (var i = 0; i < 6; i++) dayResult(i)]);
      expect(app.history.streak, 6);
      expect(
        app.history.badges.firstWhere((b) => b.id == 'streak').earned,
        isFalse,
      );

      app.history.addResult(dayResult(6));
      expect(app.history.streak, 7);
      expect(
        app.history.badges.firstWhere((b) => b.id == 'streak').earned,
        isTrue,
      );
    });

    test('setiap kategori memiliki soal pemula tanpa skor bawaan', () {
      for (final category in categories) {
        expect(
          testQuizBank().questionsFor(category.id, Difficulty.pemula),
          isNotEmpty,
        );
      }
    });
  });
}
