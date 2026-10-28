import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kage/app_services.dart';
import 'package:kage/models/models.dart';

import '../support/app_harness.dart';
import '../support/quiz_bank.dart';

const _letters = ['A', 'B', 'C', 'D'];

AppServices _quizApp() {
  final app = AppServices(quizRepository: testQuizBank());
  app.auth.register(
    name: 'Budi',
    email: 'budi@example.com',
    password: 'rahasia123',
  );
  app.quiz.startQuiz(CategoryId.sains);
  return app;
}

/// Menangkap panggilan getaran ke lapisan sistem.
List<MethodCall> _captureHaptics(WidgetTester tester) {
  final calls = <MethodCall>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add(call);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}

void main() {
  group('U-03 pembanding jawaban', () {
    testWidgets(
      'jawaban salah menampilkan jawaban pengguna dan jawaban benar',
      (tester) async {
        final app = _quizApp();
        addTearDown(app.dispose);

        final question = app.quiz.currentQuestion!;
        final wrongIndex =
            (question.correctIndex + 1) % question.options.length;
        app.quiz.selectAnswer(wrongIndex);
        app.quiz.submitCurrent();

        await pumpKageApp(tester, app, '/penjelasan');

        expect(find.textContaining('Jawabanmu'), findsOneWidget);
        expect(find.textContaining('Jawaban benar'), findsOneWidget);
        expect(
          find.textContaining(question.options[question.correctIndex]),
          findsWidgets,
        );
        expect(find.textContaining(question.options[wrongIndex]), findsWidgets);
        // Penanda selain warna.
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byIcon(Icons.cancel), findsOneWidget);
      },
    );

    testWidgets('jawaban benar tidak menampilkan baris pembanding tambahan', (
      tester,
    ) async {
      final app = _quizApp();
      addTearDown(app.dispose);

      final question = app.quiz.currentQuestion!;
      app.quiz.selectAnswer(question.correctIndex);
      app.quiz.submitCurrent();

      await pumpKageApp(tester, app, '/penjelasan');

      expect(find.textContaining('Jawabanmu'), findsOneWidget);
      expect(find.textContaining('Jawaban benar'), findsNothing);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsNothing);
    });

    testWidgets('semantik membedakan jawaban benar dan salah', (tester) async {
      final app = _quizApp();
      addTearDown(app.dispose);

      final question = app.quiz.currentQuestion!;
      final wrongIndex = (question.correctIndex + 1) % question.options.length;
      app.quiz.selectAnswer(wrongIndex);
      app.quiz.submitCurrent();

      await pumpKageApp(tester, app, '/penjelasan');

      expect(
        find.bySemanticsLabel(
          'Jawabanmu salah: ${_letters[wrongIndex]}. '
          '${question.options[wrongIndex]}',
        ),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          'Jawaban benar: ${_letters[question.correctIndex]}. '
          '${question.options[question.correctIndex]}',
        ),
        findsOneWidget,
      );
    });
  });

  group('U-03 getaran', () {
    testWidgets('memilih opsi memberi getaran ringan', (tester) async {
      final app = _quizApp();
      addTearDown(app.dispose);
      final calls = _captureHaptics(tester);

      await pumpKageApp(tester, app, '/kuis');
      await tester.tap(
        find.bySemanticsLabel(
          'Pilihan A. ${app.quiz.currentQuestion!.options[0]}',
        ),
      );
      await tester.pump();

      expect(
        calls.map((call) => call.arguments),
        contains('HapticFeedbackType.lightImpact'),
      );
    });

    testWidgets('getaran dimatikan bila pengguna mematikannya', (tester) async {
      final app = _quizApp();
      addTearDown(app.dispose);
      app.settings.setHaptics(false);
      final calls = _captureHaptics(tester);

      await pumpKageApp(tester, app, '/kuis');
      await tester.tap(
        find.bySemanticsLabel(
          'Pilihan A. ${app.quiz.currentQuestion!.options[0]}',
        ),
      );
      await tester.pump();

      expect(calls, isEmpty);
    });
    testWidgets('jawaban benar bergetar sedang', (tester) async {
      final app = _quizApp();
      addTearDown(app.dispose);
      final calls = _captureHaptics(tester);

      app.quiz.selectAnswer(app.quiz.currentQuestion!.correctIndex);
      app.quiz.submitCurrent();
      await pumpKageApp(tester, app, '/penjelasan');

      expect(
        calls.map((call) => call.arguments),
        contains('HapticFeedbackType.mediumImpact'),
      );
      expect(
        calls.map((call) => call.arguments),
        isNot(contains('HapticFeedbackType.heavyImpact')),
      );
    });

    testWidgets('jawaban salah bergetar kuat', (tester) async {
      final app = _quizApp();
      addTearDown(app.dispose);
      final calls = _captureHaptics(tester);

      final question = app.quiz.currentQuestion!;
      app.quiz.selectAnswer(
        (question.correctIndex + 1) % question.options.length,
      );
      app.quiz.submitCurrent();
      await pumpKageApp(tester, app, '/penjelasan');

      expect(
        calls.map((call) => call.arguments),
        contains('HapticFeedbackType.heavyImpact'),
      );
    });
  });
}
