import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/quiz/quiz_controller.dart';

import '../support/quiz_bank.dart';

void main() {
  group('K-02 pengacakan soal dan opsi', () {
    test('correctIndex dipetakan ke opsi hasil acak', () {
      final quiz = QuizController(questions: testQuizBank());
      addTearDown(quiz.dispose);
      quiz.startQuiz(CategoryId.sains, random: Random(42));

      final source = testQuizBank().questionsFor(
        CategoryId.sains,
        Difficulty.pemula,
      );
      expect(quiz.activeQuestions, hasLength(source.length));
      for (final question in quiz.activeQuestions) {
        final original = source.firstWhere((q) => q.prompt == question.prompt);
        expect(
          question.options[question.correctIndex],
          original.options[original.correctIndex],
        );
      }
    });

    test('seed yang sama menghasilkan urutan yang sama', () {
      final first = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains, random: Random(7));
      final second = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains, random: Random(7));
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      expect(
        first.activeQuestions.map((q) => q.prompt).toList(),
        second.activeQuestions.map((q) => q.prompt).toList(),
      );
      expect(
        first.activeQuestions.map((q) => q.options).toList(),
        second.activeQuestions.map((q) => q.options).toList(),
      );
    });

    test('seed berbeda menghasilkan urutan berbeda', () {
      final first = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains, random: Random(1));
      final second = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains, random: Random(2));
      addTearDown(first.dispose);
      addTearDown(second.dispose);

      expect(
        first.activeQuestions.map((q) => q.prompt).toList(),
        isNot(equals(second.activeQuestions.map((q) => q.prompt).toList())),
      );
    });

    test('menjawab semua opsi benar tetap bernilai 100', () {
      final quiz = QuizController(questions: testQuizBank());
      addTearDown(quiz.dispose);
      quiz.startQuiz(CategoryId.sains, random: Random(99));

      while (!quiz.isLastQuestion) {
        quiz.selectAnswer(quiz.currentQuestion!.correctIndex);
        quiz.submitCurrent();
        quiz.nextQuestion();
      }
      quiz.selectAnswer(quiz.currentQuestion!.correctIndex);
      quiz.submitCurrent();
      quiz.finishQuiz();

      expect(quiz.lastResult, isNotNull);
      expect(quiz.lastResult!.correct, quiz.lastResult!.total);
      expect(quiz.lastResult!.score, 100);
    });

    test('urutan acak dipertahankan saat melanjutkan kuis', () {
      final quiz = QuizController(questions: testQuizBank());
      addTearDown(quiz.dispose);
      quiz.startQuiz(CategoryId.sains, random: Random(11));
      final prompts = quiz.activeQuestions.map((q) => q.prompt).toList();
      final options = quiz.activeQuestions.map((q) => q.options).toList();
      quiz.saveProgress();

      quiz.startQuiz(CategoryId.sains, random: Random(22));
      quiz.continueAdventure();

      expect(quiz.activeQuestions.map((q) => q.prompt).toList(), prompts);
      expect(quiz.activeQuestions.map((q) => q.options).toList(), options);
    });
  });
}
