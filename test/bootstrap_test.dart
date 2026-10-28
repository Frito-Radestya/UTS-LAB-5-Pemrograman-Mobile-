import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kage/app.dart';
import 'package:kage/app_services.dart';
import 'package:kage/features/splash/bootstrap.dart';

import 'support/quiz_bank.dart';

/// U-07: layar bootstrap dibangun di atas MaterialApp, jadi layar ini wajib
/// menyediakan arah baca sendiri. Bila tidak, Scaffold melempar
/// "No Directionality widget found" dan memunculkan dialog error debug.
void main() {
  group('KageBootstrap', () {
    testWidgets('layar memuat tampil tanpa error Directionality', (
      tester,
    ) async {
      final completer = Completer<AppServices>();
      await tester.pumpWidget(
        KageBootstrap(createServices: () => completer.future),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Menyiapkan data…'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      completer.complete(AppServices(quizRepository: testQuizBank()));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(KageApp), findsOneWidget);
      expect(find.text('Menyiapkan data…'), findsNothing);
    });

    testWidgets('layar memuat tidak melempar error selama proses berjalan', (
      tester,
    ) async {
      final completer = Completer<AppServices>();
      await tester.pumpWidget(
        KageBootstrap(createServices: () => completer.future),
      );

      // Beberapa frame berturut-turut, meniru bootstrap yang lama.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);

      completer.complete(AppServices(quizRepository: testQuizBank()));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('penyimpanan gagal menampilkan layar coba lagi yang bisa '
        'dipakai ulang', (tester) async {
      var attempts = 0;
      await tester.pumpWidget(
        KageBootstrap(
          createServices: () async {
            attempts += 1;
            if (attempts == 1) throw StateError('penyimpanan gagal');
            return AppServices(quizRepository: testQuizBank());
          },
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Gagal memuat data'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(attempts, 2);
      expect(find.byType(KageApp), findsOneWidget);
      expect(find.text('Gagal memuat data'), findsNothing);
    });
  });
}