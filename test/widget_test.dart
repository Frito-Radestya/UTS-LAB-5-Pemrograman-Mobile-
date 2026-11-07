import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kage/app.dart';
import 'package:kage/app_services.dart';
import 'package:kage/features/settings/reminder_service.dart';
import 'package:kage/models/models.dart';
import 'package:kage/theme/app_colors.dart';

import 'support/quiz_bank.dart';

void main() {
  testWidgets('Splash menampilkan wordmark KAGE', (tester) async {
    await tester.pumpWidget(
      KageApp(services: AppServices(quizRepository: testQuizBank())),
    );

    expect(find.text('KAGE'), findsWidgets);
    expect(find.text('THE QUIZ SANCTUARY'), findsOneWidget);
  });

  testWidgets('KageApp resize across Android, Tablet, Laptop and theme switch', (
    tester,
  ) async {
    final services = AppServices(
      quizRepository: testQuizBank(),
      reminderService: LocalReminderService(),
    );
    services.auth.register(
      name: 'Budi',
      email: 'budi@example.com',
      password: 'Password1!',
    );

    // Start on Laptop (1366x768)
    tester.view.physicalSize = const Size(1366, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(KageApp(services: services));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Navigate to Profil -> Pengaturan
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Buka pengaturan'));
    await tester.pumpAndSettle();

    // Initially Notifikasi is ON and Jam Pengingat is visible
    expect(find.text('Jam Pengingat'), findsOneWidget);

    // Turn OFF Notifikasi -> Jam Pengingat disappears immediately
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
    expect(services.settings.notifications, isFalse);
    expect(find.text('Jam Pengingat'), findsNothing);

    // Turn ON Notifikasi -> Jam Pengingat reappears immediately in 1 click!
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();
    expect(services.settings.notifications, isTrue);
    expect(find.text('Jam Pengingat'), findsOneWidget);

    // Switch theme to Terang from Pengaturan dialog
    await tester.scrollUntilVisible(find.text('Tema'), 100);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tema'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terang'));
    await tester.pumpAndSettle();

    // Verify BackIconButton on PengaturanPage has Light Mode text color
    final backIcon = tester.widget<Icon>(find.byIcon(Icons.chevron_left).last);
    expect(backIcon.color, equals(const Color(0xFF1C1917)));

    // Pop back to ProfilPage and verify ProfilPage is also 100% Light Mode
    await tester.tap(find.bySemanticsLabel('Kembali ke profil'));
    await tester.pumpAndSettle();
    final profilBackIcon =
        tester.widget<Icon>(find.byIcon(Icons.chevron_left).first);
    expect(profilBackIcon.color, equals(const Color(0xFF1C1917)));

    // Resize to Tablet (800x1024) and Android Phone (390x844)
    tester.view.physicalSize = const Size(800, 1024);
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();

    // Reset theme
    services.settings.setTheme(KageTheme.gelap);
    await tester.pumpAndSettle();
    expect(AppColors.isLight, isFalse);
  });
}
