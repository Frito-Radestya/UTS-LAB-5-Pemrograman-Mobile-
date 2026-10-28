import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:kage/features/settings/settings_controller.dart';

/// Bunyi umpan balik yang dipakai KAGE.
enum KageSound {
  /// Saat pengguna memilih opsi jawaban.
  tap,

  /// Saat jawaban benar.
  correct,

  /// Saat jawaban salah.
  wrong,
}

/// Memainkan bunyi sistem bila pengguna belum mematikannya di Pengaturan.
///
/// Bunyi memakai [SystemSound] bawaan platform sehingga tidak menambah aset
/// audio; pemetaannya: klik untuk memilih, klik untuk benar, dan alarm untuk
/// salah agar berbeda jelas.
void kageSound(BuildContext context, KageSound kind) {
  if (!context.read<SettingsController>().sound) return;
  final sound = switch (kind) {
    KageSound.tap => SystemSoundType.click,
    KageSound.correct => SystemSoundType.click,
    KageSound.wrong => SystemSoundType.alert,
  };
  unawaited(SystemSound.play(sound));
}
