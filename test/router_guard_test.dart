import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kage/app.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/features/home/beranda_page.dart';
import 'package:kage/features/auth/login_page.dart';
import 'package:kage/app_services.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/settings/settings_controller.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'support/quiz_bank.dart';

Future<void> _pumpAt(
  WidgetTester tester,
  AppServices app,
  String location,
) async {
  final router = createRouter(app, initialLocation: location);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: app.auth),
        ChangeNotifierProvider<QuizController>.value(value: app.quiz),
        ChangeNotifierProvider<HistoryController>.value(value: app.history),
        ChangeNotifierProvider<ProgressController>.value(value: app.progress),
        ChangeNotifierProvider<SettingsController>.value(value: app.settings),
        Provider<QuizRepository>.value(value: app.quizRepository),
        Provider<HistoryRepository>.value(value: app.historyRepository),
      ],
      child: MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  group('K-05 route guard', () {
    testWidgets('rute privat tanpa login diarahkan ke /login', (tester) async {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);

      await _pumpAt(tester, app, '/profil');

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(BerandaPage), findsNothing);
    });

    testWidgets('pengguna yang sudah login diarahkan dari /login', (
      tester,
    ) async {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      app.auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );

      await _pumpAt(tester, app, '/login');

      expect(find.byType(BerandaPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('kuis tanpa sesi aktif diarahkan ke beranda', (tester) async {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      app.auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );

      await _pumpAt(tester, app, '/kuis');

      expect(find.byType(BerandaPage), findsOneWidget);
    });

    testWidgets('penjelasan tanpa sesi aktif diarahkan ke beranda', (
      tester,
    ) async {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      app.auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );

      await _pumpAt(tester, app, '/penjelasan');

      expect(find.byType(BerandaPage), findsOneWidget);
    });

    testWidgets('hasil tanpa sesi aktif diarahkan ke beranda', (tester) async {
      final app = AppServices(quizRepository: testQuizBank());
      addTearDown(app.dispose);
      app.auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );

      await _pumpAt(tester, app, '/hasil');

      expect(find.byType(BerandaPage), findsOneWidget);
    });
  });
}
