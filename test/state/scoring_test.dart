import 'package:flutter_test/flutter_test.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/quiz/quiz_controller.dart';

import '../support/quiz_bank.dart';

void main() {
  group('K-06 penilaian dinamis', () {
    test('jumlah jawaban mengikuti total soal aktif', () {
      final quiz = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains);
      addTearDown(quiz.dispose);

      expect(quiz.answers, hasLength(quiz.totalQuestions));
      expect(quiz.totalQuestions, greaterThan(0));
    });

    test('skor kuis kosong berada di rentang 0-100', () {
      final quiz = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains);
      addTearDown(quiz.dispose);

      quiz.finishQuiz();

      expect(quiz.lastResult!.score, 0);
      expect(quiz.lastResult!.score, inInclusiveRange(0, 100));
    });

    test('skor sempurna selalu 100 berapa pun jumlah soalnya', () {
      final quiz = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains);
      addTearDown(quiz.dispose);

      for (var i = 0; i < quiz.totalQuestions; i++) {
        quiz.selectAnswer(quiz.currentQuestion!.correctIndex);
        quiz.submitCurrent();
        if (!quiz.isLastQuestion) quiz.nextQuestion();
      }
      quiz.finishQuiz();

      expect(quiz.lastResult!.score, 100);
      expect(quiz.lastResult!.correct, quiz.totalQuestions);
    });
  });
}
