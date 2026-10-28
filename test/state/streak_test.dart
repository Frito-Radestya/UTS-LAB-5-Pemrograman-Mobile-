import 'package:flutter_test/flutter_test.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/history/streak.dart';

QuizResult _result(DateTime playedAt) {
  return QuizResult(
    categoryId: CategoryId.sains,
    score: 80,
    correct: 8,
    total: 10,
    duration: const Duration(minutes: 2),
    playedAt: playedAt,
    difficulty: Difficulty.pemula,
  );
}

void main() {
  group('K-09 calculateStreak', () {
    final now = DateTime(2026, 10, 26, 21, 30);

    test('tidak ada riwayat menghasilkan 0', () {
      expect(calculateStreak(const [], now), 0);
    });

    test('main hari ini saja menghasilkan 1', () {
      expect(calculateStreak([_result(DateTime(2026, 10, 26, 8))], now), 1);
    });

    test('tiga hari berturut-turut menghasilkan 3', () {
      final history = [
        _result(DateTime(2026, 10, 26, 8)),
        _result(DateTime(2026, 10, 25, 20)),
        _result(DateTime(2026, 10, 24, 19)),
      ];
      expect(calculateStreak(history, now), 3);
    });

    test('hari yang terlewat memutus streak', () {
      final history = [
        _result(DateTime(2026, 10, 26, 8)),
        _result(DateTime(2026, 10, 25, 20)),
        _result(DateTime(2026, 10, 23, 19)),
      ];
      expect(calculateStreak(history, now), 2);
    });

    test('dua kuis pada hari yang sama dihitung satu hari', () {
      final history = [
        _result(DateTime(2026, 10, 26, 8)),
        _result(DateTime(2026, 10, 26, 18)),
      ];
      expect(calculateStreak(history, now), 1);
    });

    test('streak masih aktif jika aktivitas terakhir kemarin', () {
      final history = [
        _result(DateTime(2026, 10, 25, 20)),
        _result(DateTime(2026, 10, 24, 19)),
      ];
      expect(calculateStreak(history, now), 2);
    });

    test('streak berakhir jika aktivitas terakhir dua hari lalu', () {
      final history = [_result(DateTime(2026, 10, 24, 19))];
      expect(calculateStreak(history, now), 0);
    });
  });
}
