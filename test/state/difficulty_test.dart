import 'package:flutter_test/flutter_test.dart';
import 'package:kage/models/models.dart';
import 'package:kage/app_services.dart';
import 'package:kage/features/quiz/quiz_controller.dart';

import '../support/quiz_bank.dart';

void main() {
  group('K-03 tingkat kesulitan', () {
    test('questionsFor menyaring soal sesuai tingkat', () {
      expect(
        testQuizBank().questionsFor(CategoryId.sains, Difficulty.pemula),
        hasLength(10),
      );
      expect(
        testQuizBank().questionsFor(CategoryId.sains, Difficulty.menengah),
        hasLength(10),
      );
      expect(
        testQuizBank().questionsFor(CategoryId.sains, Difficulty.ahli),
        hasLength(10),
      );

      for (final question in testQuizBank().questionsFor(
        CategoryId.sains,
        Difficulty.ahli,
      )) {
        expect(question.difficulty, Difficulty.ahli);
      }
      expect(
        testQuizBank().questionsFor(CategoryId.teknologi, Difficulty.menengah),
        isEmpty,
      );
    });

    test('bank soal memiliki opsi dan correctIndex yang valid', () {
      final prompts = <String>{};
      for (final entry in testQuizBankData().entries) {
        for (final question in entry.value) {
          expect(question.options, isNotEmpty);
          expect(
            question.options.any((option) => option.trim().isEmpty),
            isFalse,
          );
          expect(
            question.correctIndex,
            inInclusiveRange(0, question.options.length - 1),
          );
          expect(question.explanation.trim(), isNotEmpty);
          expect(prompts.add('${entry.key.name}:${question.prompt}'), isTrue);
        }
      }
      expect(testQuizBank().questionCountFor(CategoryId.sains), 30);
    });

    test('tingkat berbeda menghasilkan XP berbeda', () {
      int xpFor(Difficulty difficulty) {
        final app = AppServices(quizRepository: testQuizBank())
          ..quiz.startQuiz(CategoryId.sains, difficulty: difficulty);
        addTearDown(app.dispose);
        for (var i = 0; i < app.quiz.totalQuestions; i++) {
          app.quiz.selectAnswer(app.quiz.currentQuestion!.correctIndex);
          app.quiz.submitCurrent();
          if (!app.quiz.isLastQuestion) app.quiz.nextQuestion();
        }
        app.quiz.finishQuiz();
        return app.progress.xp;
      }

      expect(xpFor(Difficulty.pemula), 100);
      expect(xpFor(Difficulty.menengah), 150);
      expect(xpFor(Difficulty.ahli), 200);
    });

    test('tingkat tanpa soal tidak bisa dipakai untuk memulai sesi', () {
      final quiz = QuizController(questions: testQuizBank());
      addTearDown(quiz.dispose);
      quiz.setDifficulty(Difficulty.menengah);

      quiz.startQuiz(CategoryId.teknologi);

      expect(quiz.selectedDifficulty, Difficulty.pemula);
      expect(quiz.totalQuestions, greaterThan(0));
      expect(quiz.currentQuestion, isNotNull);
      expect(quiz.currentQuestion!.difficulty, Difficulty.pemula);
    });

    test('sesi memakai soal dari tingkat yang dipilih', () {
      final quiz = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains, difficulty: Difficulty.menengah);
      addTearDown(quiz.dispose);

      expect(quiz.selectedDifficulty, Difficulty.menengah);
      expect(quiz.activeQuestions, hasLength(10));
      for (final question in quiz.activeQuestions) {
        expect(question.difficulty, Difficulty.menengah);
      }
    });
  });
}
