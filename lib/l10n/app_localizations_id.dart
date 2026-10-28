// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'KAGE';

  @override
  String get home => 'Beranda';

  @override
  String get quiz => 'Kuis';

  @override
  String get history => 'Riwayat';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Pengaturan';

  @override
  String get help => 'Bantuan';

  @override
  String get logout => 'Keluar';

  @override
  String get startQuiz => 'Mulai Kuis';

  @override
  String get next => 'Selanjutnya';

  @override
  String get finish => 'Selesai';

  @override
  String get explanation => 'Penjelasan';

  @override
  String get result => 'Hasil';

  @override
  String get correct => 'Benar';

  @override
  String get wrong => 'Salah';

  @override
  String get score => 'Skor';

  @override
  String get accuracy => 'Akurasi';

  @override
  String get time => 'Waktu';

  @override
  String get reviewAnswers => 'Tinjau Jawaban';

  @override
  String get retryWrong => 'Ulangi Soal yang Salah';

  @override
  String get backToHome => 'Kembali ke Beranda';

  @override
  String get newBest => 'Rekor baru!';

  @override
  String vsBest(Object diff) {
    return '+$diff dari terbaikmu';
  }

  @override
  String get language => 'Bahasa';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get english => 'English';
}
