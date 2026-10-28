import 'package:kage/models/models.dart';

/// Menghitung streak harian dari tanggal [QuizResult.playedAt].
///
/// Tanggal dibandingkan berdasarkan hari lokal. Streak masih dianggap aktif
/// jika aktivitas terakhir terjadi hari ini atau kemarin; rangkaian berhenti
/// ketika ada satu hari yang terlewat. Beberapa kuis pada hari yang sama
/// dihitung satu hari.
int calculateStreak(List<QuizResult> history, DateTime now) {
  if (history.isEmpty) return 0;

  final days = <DateTime>{};
  for (final result in history) {
    final date = result.playedAt;
    days.add(DateTime(date.year, date.month, date.day));
  }

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  var cursor = days.contains(today)
      ? today
      : days.contains(yesterday)
      ? yesterday
      : null;
  if (cursor == null) return 0;

  var streak = 0;
  while (cursor != null) {
    streak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    if (!days.contains(cursor)) break;
  }
  return streak;
}
