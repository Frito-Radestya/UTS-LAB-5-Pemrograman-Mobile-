import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Pengingat belajar harian.
///
/// Halaman Pengaturan hanya berbicara lewat kontrak ini, sehingga pengujian bisa
/// memakai [NoopReminderService] tanpa menyentuh plugin platform.
abstract interface class ReminderService {
  /// Meminta izin notifikasi. Mengembalikan `true` bila diizinkan.
  Future<bool> requestPermission();

  /// Menjadwalkan pengingat harian berulang pada jam [hour]:[minute].
  Future<void> scheduleDaily({required int hour, required int minute});

  /// Membatalkan pengingat yang sedang terjadwal.
  Future<void> cancel();
}

/// Implementasi tanpa efek samping, dipakai pada pengujian dan di platform yang
/// tidak mendukung notifikasi lokal.
class NoopReminderService implements ReminderService {
  NoopReminderService({this.permissionGranted = true});

  /// Hasil yang dikembalikan [requestPermission].
  final bool permissionGranted;

  bool scheduled = false;
  int? scheduledHour;
  int? scheduledMinute;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    scheduled = true;
    scheduledHour = hour;
    scheduledMinute = minute;
  }

  @override
  Future<void> cancel() async {
    scheduled = false;
  }
}

/// Pengingat harian memakai `flutter_local_notifications`.
///
/// Penjadwalan memakai mode *inexact* supaya tidak memerlukan izin alarm tepat
/// waktu: Android boleh menggeser pengirimannya beberapa menit, dan itu cukup
/// untuk pengingat belajar.
class LocalReminderService implements ReminderService {
  LocalReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// ID notifikasi pengingat; dipakai tetap agar jadwal lama tertimpa.
  static const int notificationId = 1001;

  static const String _channelId = 'kage_reminder';
  static const String _title = 'Waktunya belajar';
  static const String _body =
      'Sempatkan satu kuis hari ini agar streak-mu tetap hidup.';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          // Izin diminta lewat requestPermission agar penjelasannya bisa
          // ditampilkan lebih dulu (U-08).
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    // Platform lain (web/desktop) tidak memerlukan izin notifikasi.
    return true;
  }

  @override
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    await _ensureInitialized();
    await _plugin.zonedSchedule(
      id: notificationId,
      title: _title,
      body: _body,
      scheduledDate: _nextOccurrence(hour: hour, minute: minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Pengingat belajar',
          channelDescription: 'Pengingat harian untuk mengerjakan satu kuis.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancel() => _plugin.cancel(id: notificationId);

  /// Waktu setempat berikutnya pada [hour]:[minute].
  ///
  /// `DateTime` di sini sudah berupa waktu perangkat; `TZDateTime.from`
  /// mempertahankan momen absolutnya, sehingga notifikasi tetap jatuh pada jam
  /// yang diminta pengguna selama selisih zona perangkat tidak berubah.
  static tz.TZDateTime _nextOccurrence({
    required int hour,
    required int minute,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    var target = DateTime(
      current.year,
      current.month,
      current.day,
      hour,
      minute,
    );
    if (!target.isAfter(current)) target = target.add(const Duration(days: 1));
    return tz.TZDateTime.from(target, tz.local);
  }
}
