import 'package:flutter_test/flutter_test.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/quiz/quiz_controller.dart';

import '../support/quiz_bank.dart';

void main() {
  group('K-04 resume kesulitan dan waktu', () {
    test('resume mempertahankan tingkat dan total waktu pengerjaan', () {
      final quiz = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains, difficulty: Difficulty.ahli);
      addTearDown(quiz.dispose);
      quiz.selectAnswer(quiz.currentQuestion!.correctIndex);
      quiz.quizStartedAt = DateTime.now().subtract(const Duration(minutes: 3));
      quiz.saveProgress();

      expect(quiz.resume!.difficulty, Difficulty.ahli);
      expect(
        quiz.resume!.elapsed,
        greaterThanOrEqualTo(const Duration(minutes: 3)),
      );

      quiz.startQuiz(CategoryId.teknologi, difficulty: Difficulty.pemula);
      quiz.continueAdventure();

      expect(quiz.activeCategory, CategoryId.sains);
      expect(quiz.selectedDifficulty, Difficulty.ahli);
      expect(
        quiz.activeQuestions.every((q) => q.difficulty == Difficulty.ahli),
        isTrue,
      );

      quiz.finishQuiz();

      expect(quiz.lastResult!.difficulty, Difficulty.ahli);
      expect(
        quiz.lastResult!.duration,
        greaterThanOrEqualTo(const Duration(minutes: 3)),
      );
    });

    test('waktu setelah resume ditambahkan ke waktu tersimpan', () {
      final quiz = QuizController(questions: testQuizBank());
      addTearDown(quiz.dispose);
      quiz.resume = const InProgressQuiz(
        categoryId: CategoryId.sains,
        difficulty: Difficulty.menengah,
        index: 0,
        answers: [],
        elapsed: Duration(minutes: 5),
      );

      quiz.continueAdventure();
      quiz.quizStartedAt = DateTime.now().subtract(const Duration(minutes: 1));

      expect(
        quiz.currentElapsed,
        greaterThanOrEqualTo(const Duration(minutes: 6)),
      );
      quiz.saveProgress();
      expect(
        quiz.resume!.elapsed,
        greaterThanOrEqualTo(const Duration(minutes: 6)),
      );
    });

    test('continueAdventure tanpa resume tidak memulai kuis palsu', () {
      final quiz = QuizController(questions: testQuizBank());
      addTearDown(quiz.dispose);

      quiz.continueAdventure();

      expect(quiz.activeCategory, isNull);
      expect(quiz.currentQuestion, isNull);
      expect(quiz.totalQuestions, 0);
    });
  });
}
