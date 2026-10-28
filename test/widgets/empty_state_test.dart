import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kage/app_services.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/hasil_page.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/splash/bootstrap.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/models/models.dart';
import 'package:kage/theme/app_theme.dart';

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

void main() {
  group('U-07 keadaan kosong', () {
    testWidgets('beranda akun baru mengajak memulai kuis pertama', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/beranda');

      expect(find.text('Mulai kuis pertamamu'), findsOneWidget);
      expect(find.text('Pilih kategori'), findsOneWidget);
      // Kartu progres kosong tidak lagi ditampilkan.
      expect(find.text('Progres Belajar'), findsNothing);
    });

    testWidgets('riwayat kosong memakai ilustrasi kuil dan ajakan', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/riwayat');

      expect(find.text('Belum ada riwayat kuis'), findsOneWidget);
      expect(find.text('Mulai kuis pertama'), findsOneWidget);
    });

    testWidgets('badge terkunci menyebut syarat dan progresnya', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);
      app.history.addResult(
        QuizResult(
          categoryId: CategoryId.sains,
          score: 80,
          correct: 8,
          total: 10,
          duration: const Duration(minutes: 2),
          playedAt: DateTime.now(),
          difficulty: Difficulty.pemula,
        ),
      );

      await pumpKageApp(tester, app, '/badge');

      // Satu kategori sudah diselesaikan dari lima.
      expect(find.text('1/5 kategori'), findsOneWidget);
      // Badge yang masih terkunci menyebut syaratnya juga di pembaca layar.
      expect(
        find.bySemanticsLabel(
          RegExp(RegExp.escape('Perfect 10')),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(find.text('0/1 kuis sempurna'), findsOneWidget);
    });

    testWidgets('hasil tanpa kuis aktif menjelaskan keadaannya', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);

      // Router mengalihkan halaman ini saat tidak ada kuis, tetapi bila dibuka
      // langsung halaman tetap menampilkan pesan, bukan layar kosong.
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<QuizController>.value(value: app.quiz),
            ChangeNotifierProvider<HistoryController>.value(value: app.history),
            ChangeNotifierProvider<ProgressController>.value(
              value: app.progress,
            ),
            Provider<QuizRepository>.value(value: app.quizRepository),
          ],
          child: MaterialApp(theme: AppTheme.dark(), home: const HasilPage()),
        ),
      );
      await tester.pump();

      expect(find.text('Belum ada hasil kuis'), findsOneWidget);
      expect(find.text('Kembali ke Beranda'), findsOneWidget);
    });
  });

  group('U-07 keadaan memuat dan gagal', () {
    testWidgets('menampilkan indikator saat data sedang dimuat', (
      tester,
    ) async {
      final completer = Completer<AppServices>();
      addTearDown(() {
        if (!completer.isCompleted) completer.complete(AppServices());
      });

      await tester.pumpWidget(
        MaterialApp(
          home: KageBootstrap(createServices: () => completer.future),
        ),
      );
      await tester.pump();

      expect(find.text('Menyiapkan data…'), findsOneWidget);
      expect(find.bySemanticsLabel('Menyiapkan data'), findsOneWidget);
      expect(find.text('KAGE'), findsOneWidget);
    });

    testWidgets(
      'penyimpanan yang gagal dibuka menampilkan pesan dan coba lagi',
      (tester) async {
        var attempts = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: KageBootstrap(
              createServices: () async {
                attempts++;
                if (attempts == 1) throw StateError('penyimpanan rusak');
                return AppServices();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Gagal memuat data'), findsOneWidget);

        await tester.tap(find.text('Coba Lagi'));
        // Setelah berhasil, aplikasi sungguhan tampil dan animasi latarnya tetap
        // berjalan, jadi cukup beberapa frame tanpa pumpAndSettle.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(attempts, 2);
        expect(find.text('Gagal memuat data'), findsNothing);
      },
    );
  });
}
