import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:kage/data/quiz_data.dart';
import 'package:kage/data/repositories/history_repository.dart';
import 'package:kage/models/models.dart';

import 'streak.dart';

/// Riwayat kuis beserta statistik dan pencapaian yang diturunkan darinya.
class HistoryController extends ChangeNotifier {
  HistoryController({HistoryRepository? repository})
    : _repository = repository ?? InMemoryHistoryRepository() {
    _items.addAll(_repository.load());
  }

  final HistoryRepository _repository;
  final List<QuizResult> _items = <QuizResult>[];

  List<QuizResult> get history => UnmodifiableListView<QuizResult>(_items);

  int get streak => calculateStreak(_items, DateTime.now());

  int get totalQuizzes => _items.length;

  int get bestScore => _items.isEmpty
      ? 0
      : _items.map((e) => e.score).reduce((a, b) => a > b ? a : b);

  int get averageScore => _items.isEmpty
      ? 0
      : (_items.map((e) => e.score).reduce((a, b) => a + b) / _items.length)
            .round();

  int get accuracyPercent {
    if (_items.isEmpty) return 0;
    final correct = _items.fold<int>(0, (p, e) => p + e.correct);
    final total = _items.fold<int>(0, (p, e) => p + e.total);
    if (total == 0) return 0;
    return ((correct / total) * 100).round();
  }

  int get completedCategories {
    final ids = _items.map((e) => e.categoryId).toSet();
    return ids.length;
  }

  int get learningPathDone => completedCategories;

  int bestFor(CategoryId id) {
    final items = _items.where((e) => e.categoryId == id);
    if (items.isEmpty) return 0;
    return items.map((e) => e.score).reduce((a, b) => a > b ? a : b);
  }

  /// Waktu main terakhir pada sebuah kategori, atau null jika belum pernah.
  DateTime? lastPlayedAt(CategoryId id) {
    final items = _items.where((e) => e.categoryId == id);
    if (items.isEmpty) return null;
    return items.map((e) => e.playedAt).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  List<BadgeItem> get badges {
    final hasQuiz = _items.isNotEmpty;
    final perfect = _items.any((e) => e.score == 100);
    final currentStreak = streak;
    final explorer = completedCategories >= categories.length;
    final perfectCategories = categories
        .where((c) => _items.any((h) => h.categoryId == c.id && h.score == 100))
        .length;
    final master = perfectCategories >= categories.length;
    return [
      BadgeItem(
        id: 'first',
        title: 'First Quiz',
        subtitle: 'Selesaikan kuis pertama',
        asset: 'assets/svg/badge_first_quiz.svg',
        earned: hasQuiz,
        progressLabel: '${hasQuiz ? 1 : 0}/1 kuis',
      ),
      BadgeItem(
        id: 'perfect',
        title: 'Perfect 10',
        subtitle: 'Dapatkan 100% benar',
        asset: 'assets/svg/badge_perfect_10.svg',
        earned: perfect,
        progressLabel: '${perfect ? 1 : 0}/1 kuis sempurna',
      ),
      BadgeItem(
        id: 'streak',
        title: 'Streak 7',
        subtitle: 'Main 7 hari berturut-turut',
        asset: 'assets/svg/badge_streak_7.svg',
        earned: currentStreak >= 7,
        progressLabel: '$currentStreak/7 hari',
      ),
      BadgeItem(
        id: 'explorer',
        title: 'Explorer',
        subtitle: 'Selesaikan semua kategori',
        asset: 'assets/svg/badge_explorer.svg',
        earned: explorer,
        progressLabel: '$completedCategories/${categories.length} kategori',
      ),
      BadgeItem(
        id: 'master',
        title: 'Master',
        subtitle: 'Raih skor sempurna di semua kategori',
        asset: 'assets/svg/badge_master_locked.svg',
        earned: master,
        progressLabel:
            '$perfectCategories/${categories.length} kategori sempurna',
      ),
    ];
  }

  /// Menambahkan hasil terbaru di urutan teratas riwayat.
  void addResult(QuizResult result) {
    _items.insert(0, result);
    _persist();
    notifyListeners();
  }

  /// Menambahkan beberapa hasil sekaligus, dipakai saat memulihkan data.
  void addResults(Iterable<QuizResult> results) {
    _items.addAll(results);
    _persist();
    notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    _repository.clear();
    notifyListeners();
  }

  void _persist() => _repository.save(List<QuizResult>.unmodifiable(_items));
}
