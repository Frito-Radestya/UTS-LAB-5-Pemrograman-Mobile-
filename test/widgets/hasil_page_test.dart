import 'package:flutter_test/flutter_test.dart';

import 'package:kage/app_services.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/models/models.dart';

import '../support/app_harness.dart';
import '../support/quiz_bank.dart';

AppServices _app() {
  final app = AppServices(quizRepository: testQuizBank());
  app.auth.register(
    name: 'Budi',
    email: 'budi@example.com',
    password: 'rahasia123',
  );
  return app;
}

/// Menyelesaikan kuis Sains Pemula dengan [correct] jawaban benar pertama.
void _playQuiz(QuizController quiz, {required int correct}) {
  var index = 0;
  while (true) {
    final question = quiz.currentQuestion!;
    final answer = index < correct
        ? question.correctIndex
        : (question.correctIndex + 1) % question.options.length;
    quiz.selectAnswer(answer);
    quiz.submitCurrent();
    if (quiz.isLastQuestion) break;
    quiz.nextQuestion();
    index++;
  }
  quiz.finishQuiz();
}

Future<void> _pumpHasil(WidgetTester tester, AppServices app) async {
  await pumpKageApp(tester, app, '/hasil');
}

void main() {
  group('U-04 tinjauan jawaban', () {
    testWidgets('menampilkan daftar soal beserta pembahasannya', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 7);

      await _pumpHasil(tester, app);

      expect(find.text('Tinjau jawaban'), findsOneWidget);
      expect(app.quiz.review, hasLength(10));
      expect(app.quiz.wrongReview, hasLength(3));

      // Membuka satu soal menampilkan pembahasannya.
      final first = app.quiz.review.first;
      final tile = find.textContaining(first.question.prompt);
      expect(tile, findsOneWidget);
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(first.question.explanation), findsOneWidget);
    });

    testWidgets('mengulang hanya soal yang salah', (tester) async {
      final app = _app();
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 7);

      await _pumpHasil(tester, app);

      final retry = find.text('Ulangi 3 soal yang salah');
      expect(retry, findsOneWidget);
      await tester.ensureVisible(retry);
      await tester.tap(retry);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(app.quiz.totalQuestions, 3);
      expect(
        app.quiz.activeQuestions.every(
          (question) =>
              app.quiz.review.isEmpty ? true : question.prompt.isNotEmpty,
        ),
        isTrue,
      );
      expect(app.quiz.currentQuestion, isNotNull);
    });

    testWidgets('sesi ulangan tidak disimpan sebagai kuis lanjutan', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 7);
      app.quiz.retryWrongOnly();

      app.quiz.saveProgress();

      expect(app.quiz.resume, isNull);
    });
  });

  group('U-04 rekor dan XP', () {
    testWidgets('percobaan pertama disebut catatan pertama', (tester) async {
      final app = _app();
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 7);

      await _pumpHasil(tester, app);

      expect(find.text('Catatan pertama untuk kategori ini.'), findsOneWidget);
      expect(find.text('+70 XP'), findsOneWidget);
      expect(find.textContaining('Level'), findsWidgets);
    });

    testWidgets('skor lebih tinggi menampilkan rekor baru', (tester) async {
      final app = _app();
      addTearDown(app.dispose);

      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 7);
      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 10);

      await _pumpHasil(tester, app);

      expect(
        find.text('Rekor baru! +30 dari terbaikmu sebelumnya.'),
        findsOneWidget,
      );
      expect(find.text('+100 XP'), findsOneWidget);
      // 70 + 100 = 170 XP, cukup untuk naik ke level 2.
      expect(find.text('Naik ke level 2'), findsOneWidget);
    });

    testWidgets('skor sama menampilkan menyamai rekor', (tester) async {
      final app = _app();
      addTearDown(app.dispose);

      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 10);
      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 10);

      await _pumpHasil(tester, app);

      expect(find.text('Menyamai rekor terbaikmu.'), findsOneWidget);
      // Tanpa jawaban salah, tidak ada tombol ulangan.
      expect(find.textContaining('Ulangi'), findsNothing);
    });

    testWidgets('skor lebih rendah menampilkan selisih dari terbaikmu', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);

      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 10);
      app.quiz.startQuiz(CategoryId.sains);
      _playQuiz(app.quiz, correct: 8);

      await _pumpHasil(tester, app);

      expect(find.text('-20 dari terbaikmu (skor 100).'), findsOneWidget);
      expect(find.textContaining('Ulangi 2 soal yang salah'), findsOneWidget);
    });
  });
}
