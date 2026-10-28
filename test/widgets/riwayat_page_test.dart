import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kage/app_services.dart';
import 'package:kage/features/history/score_trend.dart';
import 'package:kage/models/models.dart';
import 'package:kage/widgets/score_row.dart';

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

QuizResult _result({
  CategoryId categoryId = CategoryId.sains,
  int score = 80,
  Difficulty difficulty = Difficulty.pemula,
  DateTime? playedAt,
}) => QuizResult(
  categoryId: categoryId,
  score: score,
  correct: score ~/ 10,
  total: 10,
  duration: const Duration(minutes: 2),
  playedAt: playedAt ?? DateTime.now(),
  difficulty: difficulty,
);

Future<void> _pumpRiwayat(WidgetTester tester, AppServices app) async {
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await pumpKageApp(tester, app, '/riwayat');
}

/// Menekan chip filter berdasarkan label semantiknya.
Future<void> _tap(WidgetTester tester, String label) async {
  await tester.tap(find.bySemanticsLabel(RegExp(RegExp.escape(label))).first);
  await tester.pumpAndSettle();
}

void main() {
  group('U-11 riwayat yang lebih informatif', () {
    testWidgets('filter tingkat kesulitan menyaring daftar', (tester) async {
      final app = _app();
      addTearDown(app.dispose);
      app.history.addResult(
        _result(categoryId: CategoryId.sains, difficulty: Difficulty.pemula),
      );
      app.history.addResult(
        _result(categoryId: CategoryId.logika, difficulty: Difficulty.ahli),
      );

      await _pumpRiwayat(tester, app);
      expect(find.byType(ScoreRow), findsNWidgets(2));

      await _tap(tester, 'Filter tingkat Ahli');

      expect(find.byType(ScoreRow), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ScoreRow),
          matching: find.text('Logika'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('filter rentang waktu membuang riwayat lama', (tester) async {
      final app = _app();
      addTearDown(app.dispose);
      final now = DateTime.now();
      app.history.addResult(_result(playedAt: now));
      app.history.addResult(
        _result(
          categoryId: CategoryId.logika,
          playedAt: now.subtract(const Duration(days: 20)),
        ),
      );
      app.history.addResult(
        _result(
          categoryId: CategoryId.sejarah,
          playedAt: now.subtract(const Duration(days: 60)),
        ),
      );

      await _pumpRiwayat(tester, app);
      expect(find.byType(ScoreRow), findsNWidgets(3));

      await _tap(tester, 'Rentang 7 hari');
      expect(find.byType(ScoreRow), findsOneWidget);

      await _tap(tester, 'Rentang 30 hari');
      expect(find.byType(ScoreRow), findsNWidgets(2));

      await _tap(tester, 'Rentang Semua waktu');
      expect(find.byType(ScoreRow), findsNWidgets(3));
    });

    testWidgets('grafik tren muncul saat ada minimal dua percobaan', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);
      app.history.addResult(_result(score: 60));

      await _pumpRiwayat(tester, app);
      expect(find.byType(ScoreTrendChart), findsNothing);

      app.history.addResult(_result(score: 90));
      await tester.pumpAndSettle();

      expect(find.byType(ScoreTrendChart), findsOneWidget);
      expect(find.text('60 → 90'), findsOneWidget);
    });

    testWidgets(
      'filter tanpa hasil menampilkan keadaan kosong dan bisa direset',
      (tester) async {
        final app = _app();
        addTearDown(app.dispose);
        app.history.addResult(_result(difficulty: Difficulty.pemula));

        await _pumpRiwayat(tester, app);
        await _tap(tester, 'Filter tingkat Ahli');

        expect(find.text('Belum ada riwayat pada filter ini'), findsOneWidget);
        await tester.tap(find.text('Tampilkan semua'));
        await tester.pumpAndSettle();

        expect(find.byType(ScoreRow), findsOneWidget);
      },
    );

    testWidgets('mengetuk entri membuka detail beserta tinjauan jawabannya', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains);
      answerAllCorrectly(app.quiz);
      app.quiz.finishQuiz();
      expect(app.history.history.first.hasDetail, isTrue);

      await _pumpRiwayat(tester, app);
      await tester.tap(find.byType(ScoreRow));
      await tester.pumpAndSettle();

      expect(find.text('Detail Kuis'), findsOneWidget);
      expect(find.text('Tinjau jawaban'), findsOneWidget);
      expect(find.textContaining('Jawabanmu benar'), findsWidgets);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('entri tanpa rincian menjelaskan kenapa tidak tersedia', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);
      app.history.addResult(_result());

      await _pumpRiwayat(tester, app);
      await tester.tap(find.byType(ScoreRow));
      await tester.pumpAndSettle();

      expect(find.text('Rincian jawaban tidak tersedia'), findsOneWidget);
      expect(find.text('Tinjau jawaban'), findsNothing);
    });
  });
}
