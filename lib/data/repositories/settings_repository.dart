import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kage/models/models.dart';

/// Penyimpanan preferensi aplikasi.
///
/// Halaman Pengaturan membaca nilai dari `SettingsController`, sedangkan
/// controller menyimpan setiap perubahan lewat kontrak ini agar preferensi tetap
/// sama setelah aplikasi dibuka ulang.
abstract interface class SettingsRepository {
  bool loadNotifications();

  void saveNotifications(bool value);

  bool loadHaptics();

  void saveHaptics(bool value);

  bool loadSound();

  void saveSound(bool value);

  KageTheme loadTheme();

  void saveTheme(KageTheme value);

  /// Jam pengingat harian dalam menit sejak tengah malam.
  int loadReminderMinutes();

  void saveReminderMinutes(int value);

  /// Timer per soal (U-06).
  bool loadTimerEnabled();

  void saveTimerEnabled(bool value);

  /// Bahasa aplikasi (R-03).
  String loadLocale();

  void saveLocale(String code);
}

/// Nilai bawaan preferensi.
class SettingsDefaults {
  SettingsDefaults._();

  static const bool notifications = true;
  static const bool haptics = true;
  static const bool sound = true;
  static const KageTheme theme = KageTheme.gelap;

  /// 19.00 waktu setempat.
  static const int reminderMinutes = 19 * 60;

  /// Timer aktif secara default (bisa dimatikan di Pengaturan).
  static const bool timerEnabled = true;

  static const String locale = 'id';
}

/// Penyimpanan sementara selama aplikasi berjalan.
class InMemorySettingsRepository implements SettingsRepository {
  bool _notifications = SettingsDefaults.notifications;
  bool _haptics = SettingsDefaults.haptics;
  bool _sound = SettingsDefaults.sound;
  KageTheme _theme = SettingsDefaults.theme;
  int _reminderMinutes = SettingsDefaults.reminderMinutes;
  bool _timerEnabled = SettingsDefaults.timerEnabled;
  String _locale = SettingsDefaults.locale;

  @override
  bool loadNotifications() => _notifications;

  @override
  void saveNotifications(bool value) {
    _notifications = value;
  }

  @override
  bool loadHaptics() => _haptics;

  @override
  void saveHaptics(bool value) {
    _haptics = value;
  }

  @override
  bool loadSound() => _sound;

  @override
  void saveSound(bool value) {
    _sound = value;
  }

  @override
  KageTheme loadTheme() => _theme;

  @override
  void saveTheme(KageTheme value) {
    _theme = value;
  }

  @override
  int loadReminderMinutes() => _reminderMinutes;

  @override
  void saveReminderMinutes(int value) {
    _reminderMinutes = value;
  }

  @override
  bool loadTimerEnabled() => _timerEnabled;

  @override
  void saveTimerEnabled(bool value) {
    _timerEnabled = value;
  }

  @override
  String loadLocale() => _locale;

  @override
  void saveLocale(String code) {
    _locale = code;
  }
}

/// Penyimpanan preferensi di `shared_preferences`.
class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._preferences);

  static const String _notificationsKey = 'settings.notifications';
  static const String _hapticsKey = 'settings.haptics';
  static const String _soundKey = 'settings.sound';
  static const String _themeKey = 'settings.theme';
  static const String _reminderKey = 'settings.reminderMinutes';
  static const String _timerKey = 'settings.timerEnabled';
  static const String _localeKey = 'settings.locale';

  final SharedPreferences _preferences;

  @override
  bool loadNotifications() =>
      _preferences.getBool(_notificationsKey) ?? SettingsDefaults.notifications;

  @override
  void saveNotifications(bool value) {
    unawaited(_preferences.setBool(_notificationsKey, value));
  }

  @override
  bool loadHaptics() =>
      _preferences.getBool(_hapticsKey) ?? SettingsDefaults.haptics;

  @override
  void saveHaptics(bool value) {
    unawaited(_preferences.setBool(_hapticsKey, value));
  }

  @override
  bool loadSound() => _preferences.getBool(_soundKey) ?? SettingsDefaults.sound;

  @override
  void saveSound(bool value) {
    unawaited(_preferences.setBool(_soundKey, value));
  }

  @override
  KageTheme loadTheme() {
    final stored = _preferences.getString(_themeKey);
    for (final value in KageTheme.values) {
      if (value.name == stored) return value;
    }
    return SettingsDefaults.theme;
  }

  @override
  void saveTheme(KageTheme value) {
    unawaited(_preferences.setString(_themeKey, value.name));
  }

  @override
  int loadReminderMinutes() =>
      _preferences.getInt(_reminderKey) ?? SettingsDefaults.reminderMinutes;

  @override
  void saveReminderMinutes(int value) {
    unawaited(_preferences.setInt(_reminderKey, value));
  }

  @override
  bool loadTimerEnabled() =>
      _preferences.getBool(_timerKey) ?? SettingsDefaults.timerEnabled;

  @override
  void saveTimerEnabled(bool value) {
    unawaited(_preferences.setBool(_timerKey, value));
  }

  @override
  String loadLocale() =>
      _preferences.getString(_localeKey) ?? SettingsDefaults.locale;

  @override
  void saveLocale(String code) {
    unawaited(_preferences.setString(_localeKey, code));
  }
}
