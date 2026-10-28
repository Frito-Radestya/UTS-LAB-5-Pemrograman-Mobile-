import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kage/app_services.dart';
import 'package:kage/features/auth/validation.dart';

import '../support/app_harness.dart';
import '../support/quiz_bank.dart';

AppServices _app() => AppServices(quizRepository: testQuizBank());

void main() {
  group('U-09 aturan kata sandi', () {
    test('kekuatan mengikuti panjang dan ragam karakter', () {
      expect(passwordStrength(''), PasswordStrength.lemah);
      expect(passwordStrength('rahasia'), PasswordStrength.lemah);
      expect(passwordStrength('rahasia123'), PasswordStrength.sedang);
      expect(passwordStrength('rahasia123!'), PasswordStrength.kuat);
      expect(passwordStrength('rahasia123456!'), PasswordStrength.kuat);
    });

    test('aturan dasar dapat diperiksa satu-satu', () {
      expect(hasMinLength('rahasia123'), isTrue);
      expect(hasMinLength('rahasia'), isFalse);
      expect(hasLetter('12345678'), isFalse);
      expect(hasDigit('rahasiaku'), isFalse);

      expect(validateName('  '), isNotNull);
      expect(validateName('Budi'), isNull);
      expect(validateEmail('budi'), isNotNull);
      expect(validateEmail('budi@example.com'), isNull);
      expect(validatePassword('rahasia'), contains('8'));
      expect(validatePassword('rahasia123'), isNull);
    });
  });

  group('U-09 formulir registrasi', () {
    testWidgets('aturan dan kekuatan tampil saat mengetik', (tester) async {
      final app = _app();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/register');

      expect(find.text('Minimal 8 karakter'), findsOneWidget);
      expect(find.textContaining('Kekuatan'), findsNothing);

      await tester.enterText(find.byType(TextField).at(2), 'rahasia123');
      await tester.pump();

      expect(find.textContaining('Kekuatan'), findsOneWidget);
      expect(find.text('Sedang'), findsOneWidget);
      expect(find.text('Minimal 8 karakter ✓'), findsOneWidget);
      expect(find.text('Mengandung huruf ✓'), findsOneWidget);
      expect(find.text('Mengandung angka ✓'), findsOneWidget);
    });

    testWidgets('email diperiksa saat kolom kehilangan fokus', (tester) async {
      final app = _app();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/register');
      expect(find.text('Format email belum valid.'), findsNothing);

      await tester.enterText(find.byType(TextField).at(1), 'bukan-email');
      await tester.pump();
      // Pindah fokus ke kolom berikutnya.
      await tester.tap(find.byType(TextField).at(2));
      await tester.pump();

      expect(find.text('Format email belum valid.'), findsOneWidget);
    });

    testWidgets('kolom dibungkus AutofillGroup', (tester) async {
      final app = _app();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/register');

      expect(find.byType(AutofillGroup), findsOneWidget);
    });
  });

  group('U-09 lupa password', () {
    testWidgets('menjelaskan bahwa akun tersimpan di perangkat', (
      tester,
    ) async {
      final app = _app();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/login');
      expect(find.byType(AutofillGroup), findsOneWidget);

      await tester.tap(find.text('Lupa password?'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Lupa password?'), findsWidgets);
      expect(find.textContaining('tersimpan di perangkat ini'), findsOneWidget);
      expect(find.textContaining('Hapus semua data'), findsOneWidget);

      await tester.tap(find.text('Mengerti'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('tersimpan di perangkat ini'), findsNothing);
    });

    testWidgets('kolom login diperiksa saat fokus berpindah', (tester) async {
      final app = _app();
      addTearDown(app.dispose);

      await pumpKageApp(tester, app, '/login');

      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await tester.tap(find.byType(TextField).at(1));
      await tester.pump();

      expect(find.text('Email atau username wajib diisi.'), findsOneWidget);
    });
  });
}
