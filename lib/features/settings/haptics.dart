import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:kage/features/settings/settings_controller.dart';

/// Jenis getaran yang dipakai KAGE.
enum KageHaptic {
  /// Saat pengguna memilih opsi jawaban.
  light,

  /// Saat jawaban benar.
  medium,

  /// Saat jawaban salah.
  heavy,
}

/// Menjalankan getaran bila pengguna belum mematikannya di Pengaturan.
///
/// Dipusatkan di satu tempat supaya setiap pemanggil tidak perlu mengingat
/// preferensi [SettingsController.haptics].
void kageHaptic(BuildContext context, KageHaptic kind) {
  if (!context.read<SettingsController>().haptics) return;
  unawaited(switch (kind) {
    KageHaptic.light => HapticFeedback.lightImpact(),
    KageHaptic.medium => HapticFeedback.mediumImpact(),
    KageHaptic.heavy => HapticFeedback.heavyImpact(),
  });
}
