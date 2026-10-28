import 'package:flutter_test/flutter_test.dart';
import 'package:kage/app_services.dart';
import 'package:kage/data/quiz_data.dart' as bank;
import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/models/models.dart';

import '../support/quiz_bank.dart';

QuizResult _result({
  CategoryId categoryId = CategoryId.sains,
  int score = 80,
  DateTime? playedAt,
}) {
  return QuizResult(
    categoryId: categoryId,
    score: score,
    correct: score ~/ 10,
    total: 10,
    duration: const Duration(minutes: 2),
    playedAt: playedAt ?? DateTime(2026, 10, 20, 20),
    difficulty: Difficulty.pemula,
  );
}

void main() {
  group('LocalQuizRepository', () {
    final repository = testQuizBank();

    test('meneruskan katalog dan detail kategori dari bank soal', () {
      expect(repository.categories, bank.categories);
      for (final category in bank.categories) {
        expect(repository.categoryById(category.id).id, category.id);
      }
    });

    test('menghitung soal per kategori dan tingkat', () {
      for (final category in bank.categories) {
        final expectedTotal = Difficulty.values.fold<int>(
          0,
          (total, difficulty) =>
              total + repository.questionsFor(category.id, difficulty).length,
        );
        expect(repository.questionCountFor(category.id), expectedTotal);
      }

      expect(
        repository.questionsFor(CategoryId.sains, Difficulty.menengah),
        isNotEmpty,
      );
      expect(
        repository.questionsFor(CategoryId.logika, Difficulty.menengah),
        isEmpty,
      );
    });

    test('menandai tingkat yang tersedia sesuai isi bank soal', () {
      expect(repository.availableDifficulties(CategoryId.sains), [
        Difficulty.pemula,
        Difficulty.menengah,
        Difficulty.ahli,
      ]);
      expect(repository.availableDifficulties(CategoryId.logika), [
        Difficulty.pemula,
      ]);

      for (final category in bank.categories) {
        for (final difficulty in Difficulty.values) {
          expect(
            repository.hasQuestionsFor(category.id, difficulty),
            repository.questionsFor(category.id, difficulty).isNotEmpty,
          );
        }
      }
    });
  });

  group('InMemoryHistoryRepository', () {
    test('menyimpan salinan hasil dan mengembalikan daftar read-only', () {
      final repository = InMemoryHistoryRepository();
      final result = _result();

      repository.save([result]);

      final loaded = repository.load();
      expect(loaded, [same(result)]);
      expect(() => loaded.add(_result(score: 90)), throwsUnsupportedError);

      repository.clear();
      expect(repository.load(), isEmpty);
    });

    test('controller baru memulihkan riwayat dari repository yang sama', () {
      final repository = InMemoryHistoryRepository();
      final first = HistoryController(repository: repository);
      addTearDown(first.dispose);
      final older = _result(score: 70, playedAt: DateTime(2026, 10, 19));
      final newer = _result(score: 90, playedAt: DateTime(2026, 10, 20));

      first.addResult(older);
      first.addResult(newer);

      final second = HistoryController(repository: repository);
      addTearDown(second.dispose);
      expect(second.history.map((item) => item.score), [90, 70]);
      expect(second.totalQuizzes, 2);
    });

    test('clear pada controller mengosongkan repository bersama', () {
      final repository = InMemoryHistoryRepository();
      final controller = HistoryController(repository: repository);
      addTearDown(controller.dispose);
      controller.addResult(_result());

      controller.clear();

      expect(controller.history, isEmpty);
      expect(repository.load(), isEmpty);

      final restored = HistoryController(repository: repository);
      addTearDown(restored.dispose);
      expect(restored.history, isEmpty);
    });
  });

  group('InMemoryAuthRepository', () {
    test('menyimpan dan menghapus profil sesi', () {
      final repository = InMemoryAuthRepository();
      expect(repository.loadProfile(), isNull);

      repository.saveProfile(
        const AuthProfile(fullName: 'Budi', email: 'budi@example.com'),
      );

      expect(repository.loadProfile()?.fullName, 'Budi');
      expect(repository.loadProfile()?.email, 'budi@example.com');

      repository.clearProfile();
      expect(repository.loadProfile(), isNull);
    });

    test('controller memulihkan sesi dari repository yang sama', () {
      final repository = InMemoryAuthRepository();
      final first = AuthController(repository: repository);
      addTearDown(first.dispose);
      first.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );

      final restored = AuthController(repository: repository);
      addTearDown(restored.dispose);
      expect(restored.loggedIn, isTrue);
      expect(restored.fullName, 'Budi');
      expect(restored.email, 'budi@example.com');

      restored.logout();
      expect(repository.loadProfile(), isNull);

      final loggedOut = AuthController(repository: repository);
      addTearDown(loggedOut.dispose);
      expect(loggedOut.loggedIn, isFalse);
    });
  });

  group('AppServices', () {
    test('memakai repository yang disuntikkan', () {
      final authRepository = InMemoryAuthRepository();
      final historyRepository = InMemoryHistoryRepository();
      final quizRepository = testQuizBank();
      final app = AppServices(
        authRepository: authRepository,
        historyRepository: historyRepository,
        quizRepository: quizRepository,
      );
      addTearDown(app.dispose);

      expect(app.authRepository, same(authRepository));
      expect(app.historyRepository, same(historyRepository));
      expect(app.quizRepository, same(quizRepository));
    });

    test('hasil kuis tersimpan ke repository riwayat bersama', () {
      final historyRepository = InMemoryHistoryRepository();
      final app = AppServices(
        historyRepository: historyRepository,
        quizRepository: testQuizBank(),
      );
      addTearDown(app.dispose);
      app.auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );
      app.quiz.startQuiz(CategoryId.sains);
      app.quiz.finishQuiz();

      expect(historyRepository.load(), hasLength(1));
      expect(app.history.totalQuizzes, 1);

      final restored = HistoryController(repository: historyRepository);
      addTearDown(restored.dispose);
      expect(restored.totalQuizzes, 1);
    });
  });
}
