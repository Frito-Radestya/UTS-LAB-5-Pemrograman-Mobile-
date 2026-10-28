// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'KAGE';

  @override
  String get home => 'Home';

  @override
  String get quiz => 'Quiz';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get logout => 'Logout';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get explanation => 'Explanation';

  @override
  String get result => 'Result';

  @override
  String get correct => 'Correct';

  @override
  String get wrong => 'Wrong';

  @override
  String get score => 'Score';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get time => 'Time';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String get retryWrong => 'Retry Wrong Answers';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get newBest => 'New record!';

  @override
  String vsBest(Object diff) {
    return '+$diff from your best';
  }

  @override
  String get language => 'Language';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get english => 'English';
}
