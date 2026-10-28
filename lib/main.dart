import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/error_reporting.dart';
import 'features/splash/bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorReporter.initialize();
  // Kunci orientasi portrait untuk pengalaman mobile yang konsisten (U-13).
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // Data lokal (sesi login, riwayat, progres) dimuat setelah frame pertama
  // supaya pengguna melihat indikator memuat alih-alih layar diam (U-07).
  runApp(const KageBootstrap());
}
