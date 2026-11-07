import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/app.dart';
import 'package:kage/app_services.dart';
import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/detail_riwayat_page.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/settings/settings_controller.dart';
import 'package:kage/l10n/app_localizations.dart';
import 'package:kage/models/models.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';

import 'support/quiz_bank.dart';

Future<void> loadFonts() async {
  final onest = FontLoader('Onest');
  for (final file in [
    'assets/fonts/Onest-Regular.ttf',
    'assets/fonts/Onest-Medium.ttf',
    'assets/fonts/Onest-SemiBold.ttf',
    'assets/fonts/Onest-Bold.ttf',
  ]) {
    final bytes = await File(file).readAsBytes();
    onest.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await onest.load();

  final cinzel = FontLoader('Cinzel');
  final cinzelBytes =
      await File('assets/fonts/Cinzel-SemiBold.ttf').readAsBytes();
  cinzel.addFont(Future.value(ByteData.view(cinzelBytes.buffer)));
  await cinzel.load();

  final icons = FontLoader('MaterialIcons');
  final iconBytes =
      await File('build/flutter_assets/fonts/MaterialIcons-Regular.otf')
          .readAsBytes();
  icons.addFont(Future.value(ByteData.view(iconBytes.buffer)));
  await icons.load();
}

void main() {
  testWidgets('Generate all screenshots for documentation', (tester) async {
    await tester.runAsync(() async {
      await loadFonts();
    });

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> capture(GlobalKey key, String filename) async {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        final file = File('docs/screenshots/$filename');
        file.parent.createSync(recursive: true);
        file.writeAsBytesSync(bytes);
      });
    }

    // ── Helper to pump app with given location, services, and theme ─────────
    Future<GlobalKey> pumpPage(
      AppServices app,
      String location, {
      bool isLight = false,
      Object? extra,
    }) async {
      AppColors.isLight = isLight;
      final navKey = GlobalKey<NavigatorState>();
      final router = createRouter(
        app,
        initialLocation: location,
        navigatorKey: navKey,
      );
      final repaintKey = GlobalKey();

      await tester.pumpWidget(
        RepaintBoundary(
          key: repaintKey,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthController>.value(value: app.auth),
              ChangeNotifierProvider<QuizController>.value(value: app.quiz),
              ChangeNotifierProvider<HistoryController>.value(
                value: app.history,
              ),
              ChangeNotifierProvider<ProgressController>.value(
                value: app.progress,
              ),
              ChangeNotifierProvider<SettingsController>.value(
                value: app.settings,
              ),
              Provider<AuthRepository>.value(value: app.authRepository),
              Provider<QuizRepository>.value(value: app.quizRepository),
              Provider<HistoryRepository>.value(value: app.historyRepository),
            ],
            child: MaterialApp.router(
              title: 'KAGE',
              debugShowCheckedModeBanner: false,
              theme: isLight ? AppTheme.light() : AppTheme.dark(),
              locale: const Locale('id'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));
      return repaintKey;
    }

    // 1. Splash Screen
    final emptyApp = AppServices(quizRepository: testQuizBank());
    addTearDown(emptyApp.dispose);
    var key = await pumpPage(emptyApp, '/');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'splash.png');

    // 2. Login Page
    key = await pumpPage(emptyApp, '/login');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'login.png');

    // 3. Register Page
    key = await pumpPage(emptyApp, '/register');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nama Lengkap'),
      'Frito Radestya. S',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'frito.radestya@gmail.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'KageSanctuary123!',
    );
    await tester.pump(const Duration(milliseconds: 200));
    await capture(key, 'register.png');

    // Setup active authenticated app with rich history
    final app = AppServices(quizRepository: testQuizBank());
    addTearDown(app.dispose);
    app.auth.register(
      name: 'Frito Radestya. S',
      email: 'frito.radestya@gmail.com',
      password: 'Password123!',
    );

    // Complete quiz 1: Sains
    app.quiz.startQuiz(CategoryId.sains, difficulty: Difficulty.pemula);
    while (true) {
      final q = app.quiz.currentQuestion!;
      app.quiz.selectAnswer(q.correctIndex);
      app.quiz.submitCurrent();
      if (app.quiz.isLastQuestion) break;
      app.quiz.nextQuestion();
    }
    app.quiz.finishQuiz();

    // Complete quiz 2: Teknologi
    app.quiz.startQuiz(CategoryId.teknologi, difficulty: Difficulty.menengah);
    var count = 0;
    while (true) {
      final q = app.quiz.currentQuestion!;
      app.quiz.selectAnswer(count % 2 == 0 ? q.correctIndex : (q.correctIndex + 1) % 4);
      app.quiz.submitCurrent();
      if (app.quiz.isLastQuestion) break;
      app.quiz.nextQuestion();
      count++;
    }
    app.quiz.finishQuiz();

    // Save active resume: Sejarah Menengah
    app.quiz.startQuiz(CategoryId.sejarah, difficulty: Difficulty.menengah);
    app.quiz.selectAnswer(0);
    app.quiz.saveProgress();

    // 4. Beranda (Mode Gelap)
    key = await pumpPage(app, '/beranda');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'beranda.png');

    // 5. Beranda (Mode Terang)
    app.settings.setTheme(KageTheme.terang);
    key = await pumpPage(app, '/beranda', isLight: true);
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'beranda_terang.png');

    // Reset back to dark mode
    app.settings.setTheme(KageTheme.gelap);

    // 6. Kategori Page
    key = await pumpPage(app, '/kategori');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'kategori.png');

    // 7. Detail Kategori Page (Sains)
    key = await pumpPage(app, '/kategori/sains');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'detail_kategori.png');

    // 8. Kuis Page (Dark)
    app.quiz.startQuiz(CategoryId.sains, difficulty: Difficulty.pemula);
    app.quiz.selectAnswer(1);
    key = await pumpPage(app, '/kuis');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'kuis.png');

    // 9. Kuis Page (Light)
    app.settings.setTheme(KageTheme.terang);
    key = await pumpPage(app, '/kuis', isLight: true);
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'kuis_terang.png');
    app.settings.setTheme(KageTheme.gelap);

    // 10. Penjelasan Page
    app.quiz.submitCurrent();
    key = await pumpPage(app, '/penjelasan');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'penjelasan.png');

    // 11. Hasil Kuis Page (Dark)
    while (true) {
      if (app.quiz.isLastQuestion) break;
      app.quiz.nextQuestion();
      final q = app.quiz.currentQuestion!;
      app.quiz.selectAnswer(q.correctIndex);
      app.quiz.submitCurrent();
    }
    app.quiz.finishQuiz();
    key = await pumpPage(app, '/hasil');
    await tester.pump(const Duration(milliseconds: 1000));
    await capture(key, 'hasil.png');

    // 12. Hasil Kuis Page (Light)
    app.settings.setTheme(KageTheme.terang);
    key = await pumpPage(app, '/hasil', isLight: true);
    await tester.pump(const Duration(milliseconds: 1000));
    await capture(key, 'hasil_terang.png');
    app.settings.setTheme(KageTheme.gelap);

    // 13. Riwayat Page
    key = await pumpPage(app, '/riwayat');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'riwayat.png');

    // 14. Detail Riwayat Page
    final lastResult = app.history.history.first;
    final navDetailKey = GlobalKey<NavigatorState>();
    final routerDetail = GoRouter(
      navigatorKey: navDetailKey,
      initialLocation: '/riwayat/detail',
      routes: [
        GoRoute(
          path: '/riwayat/detail',
          builder: (context, state) => DetailRiwayatPage(result: lastResult),
        ),
      ],
    );
    final repaintDetailKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: repaintDetailKey,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(value: app.auth),
            ChangeNotifierProvider<QuizController>.value(value: app.quiz),
            ChangeNotifierProvider<HistoryController>.value(value: app.history),
            ChangeNotifierProvider<ProgressController>.value(value: app.progress),
            ChangeNotifierProvider<SettingsController>.value(value: app.settings),
            Provider<AuthRepository>.value(value: app.authRepository),
            Provider<QuizRepository>.value(value: app.quizRepository),
            Provider<HistoryRepository>.value(value: app.historyRepository),
          ],
          child: MaterialApp.router(
            title: 'KAGE',
            theme: AppTheme.dark(),
            routerConfig: routerDetail,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await capture(repaintDetailKey, 'detail_riwayat.png');

    // 15. Profil Page
    key = await pumpPage(app, '/profil');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'profil.png');

    // 16. Badge Page
    key = await pumpPage(app, '/badge');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'badge.png');

    // 17. Pengaturan Page
    key = await pumpPage(app, '/pengaturan');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'pengaturan.png');

    // 18. Pengaturan Dialog Tema (Light)
    app.settings.setTheme(KageTheme.terang);
    key = await pumpPage(app, '/pengaturan', isLight: true);
    await tester.scrollUntilVisible(find.text('Tema'), 100);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tema'));
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'pengaturan_dialog_tema.png');
    app.settings.setTheme(KageTheme.gelap);

    // 19. Bantuan FAQ Page
    key = await pumpPage(app, '/bantuan');
    await tester.pump(const Duration(milliseconds: 300));
    await capture(key, 'bantuan.png');
  });
}
