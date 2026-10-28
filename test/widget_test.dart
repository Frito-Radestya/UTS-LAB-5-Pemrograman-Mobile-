import 'package:flutter_test/flutter_test.dart';
import 'package:kage/app.dart';
import 'package:kage/app_services.dart';

import 'support/quiz_bank.dart';

void main() {
  testWidgets('Splash menampilkan wordmark KAGE', (tester) async {
    await tester.pumpWidget(
      KageApp(services: AppServices(quizRepository: testQuizBank())),
    );

    expect(find.text('KAGE'), findsWidgets);
    expect(find.text('THE QUIZ SANCTUARY'), findsOneWidget);
  });
}
