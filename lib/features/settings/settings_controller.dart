import 'package:flutter/material.dart';

import 'package:kage/data/repositories/settings_repository.dart';
import 'package:kage/features/settings/reminder_service.dart';
import 'package:kage/models/models.dart';

/// Preferensi aplikasi yang tidak terikat pada sesi kuis.
///
/// Nilai awal dibaca dari repository sehingga preferensi tetap sama setelah
/// aplikasi dibuka ulang.
class SettingsController extends ChangeNotifier {
  SettingsController({
    SettingsRepository? repository,
    ReminderService? reminder,
  }) : _repository = repository ?? InMemorySettingsRepository(),
       _reminder = reminder ?? NoopReminderService() {
    _notifications = _repository.loadNotifications();
    _haptics = _repository.loadHaptics();
    _sound = _repository.loadSound();
    _theme = _repository.loadTheme();
    _reminderMinutes = _repository.loadReminderMinutes();
    _timerEnabled = _repository.loadTimerEnabled();
    _localeCode = _repository.loadLocale();
  }

  final SettingsRepository _repository;
  final ReminderService _reminder;

  bool _notifications = true;
  bool _haptics = true;
  bool _sound = true;
  KageTheme _theme = KageTheme.gelap;
  int _reminderMinutes = SettingsDefaults.reminderMinutes;
  bool _timerEnabled = SettingsDefaults.timerEnabled;
  String _localeCode = SettingsDefaults.locale;

  bool get notifications => _notifications;

  /// Getaran saat menjawab dan saat jawaban dinilai.
  bool get haptics => _haptics;

  /// Bunyi klik saat memilih jawaban.
  bool get sound => _sound;

  /// Timer per soal (U-06).
  bool get timerEnabled => _timerEnabled;

  KageTheme get theme => _theme;

  String get localeCode => _localeCode;

  AppLanguage get language =>
      _localeCode == 'en' ? AppLanguage.english : AppLanguage.indonesia;

  /// Jam pengingat belajar harian.
  TimeOfDay get reminderTime =>
      TimeOfDay(hour: _reminderMinutes ~/ 60, minute: _reminderMinutes % 60);

  /// Jam pengingat dalam bentuk `19.00`.
  String get reminderLabel {
    final time = reminderTime;
    return '${time.hour.toString().padLeft(2, '0')}.'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  int get reminderMinutes => _reminderMinutes;

  /// Menyalakan notifikasi: izin diminta lebih dulu dan [notifications] hanya
  /// menyala bila pengguna mengizinkannya.
  ///
  /// Mengembalikan `true` bila pengingat aktif setelah pemanggilan ini.
  Future<bool> enableNotifications({int? hour, int? minute}) async {
    final granted = await _reminder.requestPermission();
    if (!granted) return false;

    final time = reminderTime;
    final targetHour = hour ?? time.hour;
    final targetMinute = minute ?? time.minute;
    _reminderMinutes = targetHour * 60 + targetMinute;
    _repository.saveReminderMinutes(_reminderMinutes);
    _notifications = true;
    _repository.saveNotifications(true);
    await _reminder.scheduleDaily(hour: targetHour, minute: targetMinute);
    notifyListeners();
    return true;
  }

  /// Mematikan atau menyalakan notifikasi tanpa meminta izin.
  ///
  /// Untuk menyalakan pengingat, pakai [enableNotifications] agar izin diminta
  /// lebih dulu.
  void setNotifications(bool value) {
    if (_notifications == value) return;
    _notifications = value;
    _repository.saveNotifications(value);
    notifyListeners();
    if (!value) _reminder.cancel();
  }

  /// Menggeser jam pengingat; jadwal lama diganti dengan jam baru.
  Future<void> setReminderTime(int hour, int minute) async {
    _reminderMinutes = hour * 60 + minute;
    _repository.saveReminderMinutes(_reminderMinutes);
    notifyListeners();
    if (_notifications) {
      await _reminder.scheduleDaily(hour: hour, minute: minute);
    }
  }

  void setHaptics(bool value) {
    if (_haptics == value) return;
    _haptics = value;
    _repository.saveHaptics(value);
    notifyListeners();
  }

  void setSound(bool value) {
    if (_sound == value) return;
    _sound = value;
    _repository.saveSound(value);
    notifyListeners();
  }

  void setTheme(KageTheme value) {
    if (_theme == value) return;
    _theme = value;
    _repository.saveTheme(value);
    notifyListeners();
  }

  void setTimerEnabled(bool value) {
    if (_timerEnabled == value) return;
    _timerEnabled = value;
    _repository.saveTimerEnabled(value);
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (language.code == _localeCode) return;
    _localeCode = language.code;
    _repository.saveLocale(_localeCode);
    notifyListeners();
  }
}
