import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kage/app_services.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/models/models.dart';
import 'package:kage/widgets/app_text_field.dart';
import 'package:kage/widgets/kage_tappable.dart';

import '../support/app_harness.dart';
import '../support/quiz_bank.dart';

AppServices _app({QuizRepository? bank}) {
  final app = AppServices(quizRepository: bank ?? testQuizBank());
  app.auth.register(
    name: 'Budi',
    email: 'budi@example.com',
    password: 'rahasia123',
  );
  return app;
}

/// Halaman kategori memakai daftar malas, jadi permukaan uji diperbesar supaya
/// seluruh kartu benar-benar terbangun.
Future<void> _pumpKategori(WidgetTester tester, AppServices app) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await pumpKageApp(tester, app, '/kategori');
}

/// Menekan tombol urutan, bukan teks di kartu atau navigasi bawah.
Future<void> _tapSort(WidgetTester tester, String label) async {
  await tester.tap(
    find
        .ancestor(of: find.text(label), matching: find.byType(KageTappable))
        .first,
  );
  await tester.pumpAndSettle();
}

QuizResult _result(CategoryId id, {required int score, DateTime? playedAt}) =>
    QuizResult(
      categoryId: id,
      score: score,
      correct: score ~/ 10,
      total: 10,
      duration: const Duration(minutes: 2),
      playedAt: playedAt ?? DateTime.now(),
      difficulty: Difficulty.pemula,
    );

void main() {
  group('U-10 pencarian dan penyaringan kategori', () {
    testWidgets('kolom cari menyaring kategori berdasarkan nama', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);

      await _pumpKategori(tester, app);
      expect(find.text('Logika'), findsOneWidget);
      expect(find.text('Sejarah'), findsOneWidget);

      await tester.enterText(find.byType(AppTextField), 'sejarah');
      await tester.pumpAndSettle();

      expect(find.text('Sejarah'), findsOneWidget);
      expect(find.text('Logika'), findsNothing);
      expect(find.text('Sains'), findsNothing);
    });

    testWidgets('kata kunci tanpa hasil menampilkan keadaan kosong', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);

      await _pumpKategori(tester, app);
      await tester.enterText(find.byType(AppTextField), 'astronaut');
      await tester.pumpAndSettle();

      expect(find.text('Belum ada kategori tersedia'), findsOneWidget);
    });

    testWidgets(
      'urutan terbaru menempatkan kategori yang baru dimainkan di atas',
      (tester) async {
        final app = _app();
        addTearDown(app.dispose);
        app.history.addResult(_result(CategoryId.logika, score: 80));

        await _pumpKategori(tester, app);
        await _tapSort(tester, 'Terbaru');

        final logika = tester.getTopLeft(find.text('Logika')).dy;
        final sains = tester.getTopLeft(find.text('Sains')).dy;
        expect(logika, lessThan(sains));
      },
    );

    testWidgets('urutan skor menempatkan skor tertinggi di atas', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);
      app.history.addResult(_result(CategoryId.sejarah, score: 100));

      await _pumpKategori(tester, app);
      await _tapSort(tester, 'Skor');

      final sejarah = tester.getTopLeft(find.text('Sejarah')).dy;
      final logika = tester.getTopLeft(find.text('Logika')).dy;
      expect(sejarah, lessThan(logika));
    });

    testWidgets(
      'kategori tanpa soal ditandai "Segera hadir" dan tidak dibuka',
      (tester) async {
        final bank = testQuizBankData();
        bank[CategoryId.logika] = const <Question>[];
        final app = _app(bank: LocalQuizRepository(bank));
        addTearDown(app.dispose);

        await _pumpKategori(tester, app);

        expect(find.text('Segera hadir'), findsOneWidget);
        // Kartu tersedia tetap menampilkan ajakan, bukan status menunggu.
        expect(find.text('Belum pernah dimainkan'), findsNWidgets(4));

        await tester.tap(
          find
              .ancestor(
                of: find.text('Segera hadir'),
                matching: find.byType(KageTappable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        // Masih di halaman kategori, bukan halaman detail.
        expect(find.text('Pilih Kategori'), findsOneWidget);
      },
    );

    testWidgets('tab Tersedia menyembunyikan kategori yang belum siap', (
      tester,
    ) async {
      final bank = testQuizBankData();
      bank[CategoryId.logika] = const <Question>[];
      final app = _app(bank: LocalQuizRepository(bank));
      addTearDown(app.dispose);

      await _pumpKategori(tester, app);
      await tester.tap(find.text('Tersedia'));
      await tester.pumpAndSettle();

      expect(find.text('Logika'), findsNothing);
      expect(find.text('Sains'), findsOneWidget);
    });
  });
}
