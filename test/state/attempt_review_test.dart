import 'package:flutter_test/flutter_test.dart';

import 'package:kage/app_services.dart';
import 'package:kage/data/local/quiz_codec.dart';
import 'package:kage/features/history/attempt_review.dart';
import 'package:kage/models/models.dart';

import '../support/quiz_bank.dart';

/// Menyelesaikan kuis aktif dengan [correct] jawaban benar pertama.
void _play(AppServices app, {required int correct}) {
  var index = 0;
  while (true) {
    final question = app.quiz.currentQuestion!;
    final answer = index < correct
        ? question.correctIndex
        : (question.correctIndex + 1) % question.options.length;
    app.quiz.selectAnswer(answer);
    app.quiz.submitCurrent();
    if (app.quiz.isLastQuestion) break;
    app.quiz.nextQuestion();
    index++;
  }
  app.quiz.finishQuiz();
}

void main() {
  group('U-11 rincian percobaan', () {
    test('menyusun ulang tinjauan jawaban sesuai yang dilihat pengguna', () {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains, difficulty: Difficulty.menengah);
      _play(app, correct: 6);

      final result = app.quiz.lastResult!;
      final original = app.quiz.review;
      final rebuilt = reviewFromResult(result, testQuizBank());

      expect(result.hasDetail, isTrue);
      expect(rebuilt, isNotNull);
      final list = rebuilt!;
      expect(list, hasLength(original.length));
      for (var i = 0; i < original.length; i++) {
        expect(list[i].question.prompt, original[i].question.prompt);
        expect(list[i].question.options, original[i].question.options);
        expect(
          list[i].question.correctIndex,
          original[i].question.correctIndex,
        );
        expect(list[i].chosenIndex, original[i].chosenIndex);
        expect(list[i].correct, original[i].correct);
      }
    });

    test('tetap benar meski urutan soal dan opsi diacak', () {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      final bank = testQuizBank();
      // Bank sumber tidak berubah, tetapi kuis mengacak urutannya.
      app.quiz.startQuiz(CategoryId.logika);
      _play(app, correct: 10);

      final result = app.quiz.lastResult!;
      final rebuilt = reviewFromResult(result, bank)!;

      expect(rebuilt.every((item) => item.correct), isTrue);
      expect(
        rebuilt.first.question.prompt,
        app.quiz.review.first.question.prompt,
      );
    });

    test('riwayat lama tanpa rincian mengembalikan null', () {
      final old = QuizResult(
        categoryId: CategoryId.sains,
        score: 70,
        correct: 7,
        total: 10,
        duration: const Duration(minutes: 2),
        playedAt: DateTime(2026, 1, 5),
        difficulty: Difficulty.pemula,
      );

      expect(old.hasDetail, isFalse);
      expect(reviewFromResult(old, testQuizBank()), isNull);
    });

    test('data rincian yang tidak konsisten ditolak', () {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains);
      _play(app, correct: 5);
      final result = app.quiz.lastResult!;

      // Urutan soal menunjuk di luar bank soal.
      final broken = QuizResult(
        categoryId: result.categoryId,
        score: result.score,
        correct: result.correct,
        total: result.total,
        duration: result.duration,
        playedAt: result.playedAt,
        difficulty: result.difficulty,
        answers: result.answers,
        questionOrder: [for (final _ in result.questionOrder) 999],
        optionOrders: result.optionOrders,
      );

      expect(reviewFromResult(broken, testQuizBank()), isNull);
    });

    test('kodek menyimpan dan membaca kembali rincian percobaan', () {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.umum);
      _play(app, correct: 4);
      final result = app.quiz.lastResult!;

      final decoded = quizResultFromJson(quizResultToJson(result))!;

      expect(decoded.answers, result.answers);
      expect(decoded.questionOrder, result.questionOrder);
      expect(decoded.optionOrders, result.optionOrders);
      expect(decoded.hasDetail, isTrue);
      expect(reviewFromResult(decoded, testQuizBank())!.length, result.total);
    });

    test('kodek tetap membaca riwayat lama tanpa kolom rincian', () {
      final legacy = <String, Object?>{
        'categoryId': 'sains',
        'score': 60,
        'correct': 6,
        'total': 10,
        'durationMs': 90000,
        'playedAt': '2026-02-01T10:00:00.000',
        'difficulty': 'pemula',
      };

      final decoded = quizResultFromJson(legacy)!;

      expect(decoded.score, 60);
      expect(decoded.hasDetail, isFalse);
    });
  });
}
