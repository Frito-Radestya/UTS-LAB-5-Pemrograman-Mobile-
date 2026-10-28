import 'package:flutter_test/flutter_test.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/quiz/quiz_controller.dart';

import '../support/quiz_bank.dart';

void main() {
  group('K-01 kunci jawaban', () {
    test('selectAnswer menolak perubahan setelah soal dikirim', () {
      final quiz = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains);

      quiz.selectAnswer(0);
      expect(quiz.answers[quiz.questionIndex], 0);
      expect(quiz.currentQuestionLocked, isFalse);

      quiz.submitCurrent();

      expect(quiz.currentQuestionLocked, isTrue);
      quiz.selectAnswer(2);
      expect(quiz.answers[quiz.questionIndex], 0);
    });

    test('status terkunci ikut tersimpan saat progres disimpan', () {
      final quiz = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains);

      quiz.selectAnswer(1);
      quiz.submitCurrent();
      quiz.saveProgress();

      expect(quiz.resume, isNotNull);
      expect(quiz.resume!.submitted[0], isTrue);
    });

    test('soal yang terkunci tetap terkunci setelah dilanjutkan', () {
      final quiz = QuizController(questions: testQuizBank())
        ..startQuiz(CategoryId.sains);

      quiz.selectAnswer(1);
      quiz.submitCurrent();
      quiz.saveProgress();
      quiz.startQuiz(CategoryId.sains);
      quiz.continueAdventure();

      expect(quiz.isQuestionLocked(0), isTrue);
      expect(quiz.answers[0], 1);
      quiz.selectAnswer(3);
      expect(quiz.answers[0], 1);
    });
  });
}
