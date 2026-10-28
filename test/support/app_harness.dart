import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:kage/app.dart';
import 'package:kage/app_services.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/settings/settings_controller.dart';
import 'package:kage/theme/app_theme.dart';

/// Menjalankan aplikasi sungguhan pada satu rute, sama seperti `main.dart`,
/// supaya pengujian halaman memakai provider dan router yang sebenarnya.
Future<void> pumpKageApp(
  WidgetTester tester,
  AppServices app,
  String location, {
  double textScale = 1.0,
}) async {
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
      child: MaterialApp.router(
        theme: AppTheme.dark(),
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Menyelesaikan kuis aktif dengan menjawab semua soal benar.
void answerAllCorrectly(QuizController quiz) {
  while (true) {
    final question = quiz.currentQuestion;
    if (question == null) return;
    quiz.selectAnswer(question.correctIndex);
    if (quiz.isLastQuestion) return;
    quiz.nextQuestion();
  }
}
