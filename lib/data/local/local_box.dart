import 'package:hive_flutter/hive_flutter.dart';

/// Nama kotak penyimpanan lokal untuk riwayat dan progres kuis.
const String kageBoxName = 'kage_local';

/// Membuka kotak Hive yang dipakai bersama oleh repository lokal.
///
/// Kotak dibuka sekali saat aplikasi mulai. Setelah terbuka, pembacaan data
/// bersifat sinkron sehingga controller tidak perlu menunggu saat memulihkan
/// riwayat, XP, atau kuis yang tersimpan.
Future<Box<dynamic>> openKageBox() async {
  await Hive.initFlutter();
  return Hive.openBox<dynamic>(kageBoxName);
}
