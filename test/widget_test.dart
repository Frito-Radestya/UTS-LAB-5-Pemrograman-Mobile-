import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kage/app.dart';
import 'package:kage/app_services.dart';
import 'package:kage/models/models.dart';

import 'support/quiz_bank.dart';

void main() {
  testWidgets('Splash menampilkan wordmark KAGE', (tester) async {
    await tester.pumpWidget(
      KageApp(services: AppServices(quizRepository: testQuizBank())),
    );

    expect(find.text('KAGE'), findsWidgets);
    expect(find.text('THE QUIZ SANCTUARY'), findsOneWidget);
  });

  testWidgets('KageApp resize across 520px and theme switch', (tester) async {
    final services = AppServices(quizRepository: testQuizBank());
    services.auth.register(
      name: 'Budi',
      email: 'budi@example.com',
      password: 'Password1!',
    );

    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(KageApp(services: services));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Resize from > 520 (800) to <= 520 (400)
    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();

    // Resize from <= 520 (400) to > 520 (800)
    tester.view.physicalSize = const Size(800, 800);
    await tester.pumpAndSettle();

    // Switch theme
    services.settings.setTheme(KageTheme.terang);
    await tester.pumpAndSettle();
    services.settings.setTheme(KageTheme.sistem);
    await tester.pumpAndSettle();
    services.settings.setTheme(KageTheme.gelap);
    await tester.pumpAndSettle();
  });
}
