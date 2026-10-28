import 'package:flutter_test/flutter_test.dart';

import 'package:kage/app_services.dart';
import 'package:kage/models/models.dart';

import '../support/app_harness.dart';
import '../support/quiz_bank.dart';

AppServices _quizApp() {
  final app = AppServices(quizRepository: testQuizBank());
  app.auth.register(
    name: 'Budi',
    email: 'budi@example.com',
    password: 'rahasia123',
  );
  app.quiz.startQuiz(CategoryId.sains);
  return app;
}

void main() {
  group('U-05 navigasi kuis', () {
    testWidgets('tombol sistem Back memunculkan konfirmasi keluar', (
      tester,
    ) async {
      final app = _quizApp();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/kuis');
      expect(find.text('Keluar dari kuis?'), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Keluar dari kuis?'), findsOneWidget);

      // Batal berarti tetap di kuis.
      await tester.tap(find.text('Batal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Keluar dari kuis?'), findsNothing);
      expect(app.quiz.activeCategory, CategoryId.sains);
    });

    testWidgets('konfirmasi keluar menyimpan progres lalu meninggalkan kuis', (
      tester,
    ) async {
      final app = _quizApp();
      addTearDown(app.dispose);
      app.quiz.selectAnswer(0);

      await pumpKageApp(tester, app, '/kuis');
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Simpan & keluar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(app.quiz.resume, isNotNull, reason: 'progres harus tersimpan');
      expect(app.quiz.resume!.answers.first, 0);
    });

    testWidgets('indikator soal menghitung soal terjawab', (tester) async {
      final app = _quizApp();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/kuis');
      expect(
        find.bySemanticsLabel('Soal 1 dari 10, 0 terjawab'),
        findsOneWidget,
      );

      await tester.tap(
        find.bySemanticsLabel(
          'Pilihan A. ${app.quiz.currentQuestion!.options[0]}',
        ),
      );
      await tester.pump();

      expect(
        find.bySemanticsLabel('Soal 1 dari 10, 1 terjawab'),
        findsOneWidget,
      );
    });

    testWidgets('soal terakhir memakai label Selesai', (tester) async {
      final app = _quizApp();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/kuis');
      expect(find.text('Selanjutnya'), findsOneWidget);

      while (!app.quiz.isLastQuestion) {
        app.quiz.selectAnswer(0);
        app.quiz.nextQuestion();
      }
      await tester.pump();

      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Selanjutnya'), findsNothing);
    });

    testWidgets('tombol Simpan pindah ke menu header', (tester) async {
      final app = _quizApp();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/kuis');
      expect(find.text('Simpan'), findsNothing);

      await tester.tap(find.byTooltip('Menu kuis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Simpan progres'), findsOneWidget);

      await tester.tap(find.text('Simpan progres'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(app.quiz.resume, isNotNull);
    });
  });
}
