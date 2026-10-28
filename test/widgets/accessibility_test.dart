import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kage/app_services.dart';
import 'package:kage/models/models.dart';
import 'package:kage/theme/app_colors.dart';

import '../support/app_harness.dart';
import '../support/quiz_bank.dart';

/// Rasio kontras WCAG 2.1 antara dua warna.
double _contrast(Color a, Color b) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color color) =>
      0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);

  final first = luminance(a);
  final second = luminance(b);
  final lighter = math.max(first, second);
  final darker = math.min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}

AppServices _signedInApp() {
  final app = AppServices(quizRepository: testQuizBank());
  app.auth.register(
    name: 'Budi',
    email: 'budi@example.com',
    password: 'rahasia123',
  );
  return app;
}

void main() {
  group('U-02 semantik', () {
    testWidgets('bilah progres kuis membacakan posisi soal', (tester) async {
      final app = _signedInApp();
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains);

      await pumpKageApp(tester, app, '/kuis');

      expect(find.bySemanticsLabel('Soal 1 dari 10'), findsOneWidget);
    });

    testWidgets('opsi jawaban membacakan huruf, teks, dan status terpilih', (
      tester,
    ) async {
      final app = _signedInApp();
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains);
      await pumpKageApp(tester, app, '/kuis');

      final question = app.quiz.currentQuestion!;
      app.quiz.selectAnswer(0);
      await tester.pump();

      expect(
        find.bySemanticsLabel('Pilihan A. ${question.options[0]}, terpilih'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Pilihan B. ${question.options[1]}'),
        findsOneWidget,
      );
    });

    testWidgets('navigasi bawah menyebut tab dan posisinya', (tester) async {
      final app = _signedInApp();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/beranda');

      expect(
        find.bySemanticsLabel('Beranda, tab 1 dari 4, aktif'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Profil, tab 4 dari 4'), findsOneWidget);
    });

    testWidgets('badge terbuka dan terkunci dibedakan', (tester) async {
      final app = _signedInApp();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/badge');

      List<String> badgeLabels() => tester
          .widgetList<Semantics>(find.byType(Semantics))
          .map((widget) => widget.properties.label)
          .whereType<String>()
          .where(
            (label) => label.contains('terbuka') || label.contains('terkunci'),
          )
          .toList();

      expect(
        badgeLabels(),
        hasLength(app.history.badges.length),
        reason: 'setiap badge harus punya satu label',
      );
      expect(
        badgeLabels().every((label) => label.contains('terkunci')),
        isTrue,
        reason: 'akun baru belum membuka badge apa pun',
      );

      // Setelah satu kuis selesai, badge pertama terbuka.
      app.quiz.startQuiz(CategoryId.sains);
      answerAllCorrectly(app.quiz);
      app.quiz.finishQuiz();
      await pumpKageApp(tester, app, '/badge');

      expect(
        badgeLabels().any(
          (label) =>
              label.startsWith('First Quiz') && label.contains('terbuka'),
        ),
        isTrue,
        reason: 'badge kuis pertama terbuka setelah kuis diselesaikan',
      );
    });

    testWidgets('kartu kategori menyebut jumlah soal', (tester) async {
      final app = _signedInApp();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/kategori');

      // Kartu menyebut jumlah soal dan status kategori (U-10).
      expect(
        find.bySemanticsLabel(
          'Kategori Sains, 30 soal, belum pernah dimainkan',
        ),
        findsOneWidget,
      );
    });
  });

  group('U-02 kontras teks', () {
    test('token teks memenuhi rasio 4.5:1', () {
      final backgrounds = <String, Color>{
        'background': AppColors.background,
        'surface': AppColors.surface,
      };
      final textColors = <String, Color>{
        'text': AppColors.text,
        'textSoft': AppColors.textSoft,
        'textMuted': AppColors.textMuted,
        'textQuote': AppColors.textQuote,
        'primaryText': AppColors.primaryText,
        'gold': AppColors.gold,
        'success': AppColors.success,
      };

      textColors.forEach((name, color) {
        backgrounds.forEach((backgroundName, background) {
          final ratio = _contrast(color, background);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason:
                '$name di atas $backgroundName hanya '
                '${ratio.toStringAsFixed(2)}:1',
          );
        });
      });
    });
  });

  group('U-02 area sentuh minimal 48 dp', () {
    Future<void> expectTouchTarget(
      WidgetTester tester,
      String label, {
      double min = 48,
    }) async {
      final finder = find.bySemanticsLabel(RegExp(RegExp.escape(label)));
      expect(finder, findsOneWidget, reason: 'label "$label" tidak ditemukan');
      final size = tester.getSize(finder);
      expect(
        size.height,
        greaterThanOrEqualTo(min),
        reason: 'tinggi area sentuh "$label" hanya ${size.height}',
      );
      expect(
        size.width,
        greaterThanOrEqualTo(min),
        reason: 'lebar area sentuh "$label" hanya ${size.width}',
      );
    }

    testWidgets('navigasi, filter, dan tombol kembali memenuhi 48 dp', (
      tester,
    ) async {
      final app = _signedInApp();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/beranda');
      await expectTouchTarget(tester, 'Beranda, tab 1 dari 4, aktif');
      await expectTouchTarget(tester, 'Kategori Sains, 30 soal');
      await expectTouchTarget(tester, 'Lihat semua kategori');

      await pumpKageApp(tester, app, '/riwayat');
      await expectTouchTarget(tester, 'Filter Semua, aktif');

      app.quiz.startQuiz(CategoryId.sains);
      await pumpKageApp(tester, app, '/kuis');
      await expectTouchTarget(tester, 'Keluar dari kuis');
      await expectTouchTarget(
        tester,
        'Pilihan A. ${app.quiz.currentQuestion!.options[0]}',
      );

      await pumpKageApp(tester, app, '/kategori');
      await expectTouchTarget(tester, 'Tab Semua, aktif');
      await expectTouchTarget(tester, 'Tab Tersedia');

      await pumpKageApp(tester, app, '/kategori/sains');
      await expectTouchTarget(tester, 'Tingkat Pemula, 10 soal');
    });

    testWidgets('formulir login memenuhi 48 dp', (tester) async {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/login');

      await expectTouchTarget(tester, 'Tampilkan password');
      await expectTouchTarget(tester, 'Masuk dengan Google');
    });
  });

  group('U-02 skala font sistem', () {
    for (final scale in <double>[1.3, 2.0]) {
      testWidgets('halaman utama tidak meluber pada skala ${scale}x', (
        tester,
      ) async {
        final app = _signedInApp();
        addTearDown(app.dispose);

        for (final route in <String>[
          '/beranda',
          '/kategori',
          '/kategori/sains',
          '/riwayat',
          '/profil',
          '/pengaturan',
          '/badge',
        ]) {
          await pumpKageApp(tester, app, route, textScale: scale);
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: 'rute $route meluber pada skala $scale',
          );
        }
      });
    }

    testWidgets('halaman kuis dan hasil tidak meluber pada skala 2.0x', (
      tester,
    ) async {
      final app = _signedInApp();
      addTearDown(app.dispose);
      app.quiz.startQuiz(CategoryId.sains);
      app.quiz.selectAnswer(0);

      await pumpKageApp(tester, app, '/kuis', textScale: 2.0);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'halaman kuis meluber');

      app.quiz.nextQuestion();
      await pumpKageApp(tester, app, '/penjelasan', textScale: 2.0);
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'halaman penjelasan meluber',
      );

      answerAllCorrectly(app.quiz);
      app.quiz.finishQuiz();
      await pumpKageApp(tester, app, '/hasil', textScale: 2.0);
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'halaman hasil meluber');
    });
  });
}
