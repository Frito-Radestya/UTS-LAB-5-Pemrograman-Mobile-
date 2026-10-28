import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';

enum CategoryId { sains, teknologi, sejarah, logika, umum }

enum Difficulty { pemula, menengah, ahli }

/// Pilihan tema di Pengaturan (U-08).
///
/// Palet KAGE dirancang gelap dan tetap dipakai pada kedua pilihan; yang berbeda
/// adalah warna bilah sistem (status/navigasi), sehingga pengguna bisa meminta
/// bilah sistem mengikuti mode perangkat.
enum KageTheme {
  gelap,
  sistem;

  String get label => switch (this) {
    KageTheme.gelap => 'Gelap',
    KageTheme.sistem => 'Sistem',
  };

  String get description => switch (this) {
    KageTheme.gelap => 'Tampilan KAGE selalu gelap.',
    KageTheme.sistem => 'Bilah sistem mengikuti mode perangkat.',
  };
}

/// Pilihan bahasa aplikasi (R-03).
enum AppLanguage {
  indonesia,
  english;

  String get code => switch (this) {
        AppLanguage.indonesia => 'id',
        AppLanguage.english => 'en',
      };

  String get label => switch (this) {
        AppLanguage.indonesia => 'Bahasa Indonesia',
        AppLanguage.english => 'English',
      };
}

/// Pengaturan timer per soal (U-06).
class QuizTimerConfig {
  const QuizTimerConfig._();

  /// Durasi default per tingkat kesulitan (detik).
  static const int secondsPemula = 60;
  static const int secondsMenengah = 45;
  static const int secondsAhli = 30;

  static int secondsFor(Difficulty difficulty) => switch (difficulty) {
        Difficulty.pemula => secondsPemula,
        Difficulty.menengah => secondsMenengah,
        Difficulty.ahli => secondsAhli,
      };
}

class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.name,
    required this.shortName,
    required this.description,
    required this.tags,
    required this.color,
    required this.iconAsset,
    required this.gradientInner,
    required this.gradientOuter,
    this.available = true,
  });

  final CategoryId id;
  final String name;
  final String shortName;
  final String description;
  final List<String> tags;
  final Color color;
  final String iconAsset;
  final Color gradientInner;
  final Color gradientOuter;
  final bool available;
}

class Question {
  const Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.funFact,
    this.difficulty = Difficulty.pemula,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String funFact;
  final Difficulty difficulty;
}

class QuizResult {
  const QuizResult({
    required this.categoryId,
    required this.score,
    required this.correct,
    required this.total,
    required this.duration,
    required this.playedAt,
    required this.difficulty,
    this.answers = const [],
    this.questionOrder = const [],
    this.optionOrders = const [],
  });

  final CategoryId categoryId;
  final int score;
  final int correct;
  final int total;
  final Duration duration;
  final DateTime playedAt;
  final Difficulty difficulty;

  /// Jawaban yang dipilih pengguna pada urutan tampil, `null` bila kosong.
  ///
  /// Dipakai untuk membuka kembali tinjauan jawaban dari halaman Riwayat
  /// (U-11). Daftar kosong berarti rincian percobaan tidak tersimpan.
  final List<int?> answers;

  /// Posisi soal pada bank soal asli sesuai urutan tampil.
  final List<int> questionOrder;

  /// Urutan indeks opsi asli untuk setiap soal pada [questionOrder].
  final List<List<int>> optionOrders;

  int get accuracy => total == 0 ? 0 : ((correct / total) * 100).round();

  /// `true` bila rincian jawaban percobaan ini tersimpan lengkap.
  bool get hasDetail =>
      questionOrder.length == total &&
      optionOrders.length == total &&
      total > 0;
}

class BadgeItem {
  const BadgeItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.earned,
    this.progressLabel,
  });

  final String id;
  final String title;
  final String subtitle;
  final String asset;
  final bool earned;

  /// Syarat yang sudah dicapai, misalnya `3/5 kategori` (U-07).
  ///
  /// Ditampilkan pada badge yang masih terkunci supaya pengguna tahu seberapa
  /// dekat mereka dengan pencapaian itu.
  final String? progressLabel;
}

class InProgressQuiz {
  const InProgressQuiz({
    required this.categoryId,
    required this.difficulty,
    required this.index,
    required this.answers,
    this.submitted = const [],
    this.questionOrder = const [],
    this.optionOrders = const [],
    this.elapsed = Duration.zero,
  });

  final CategoryId categoryId;
  final Difficulty difficulty;
  final int index;
  final List<int?> answers;

  /// Soal yang sudah dikirim dan tidak boleh diubah lagi setelah dilanjutkan.
  final List<bool> submitted;

  /// Urutan indeks soal pada bank soal asli.
  final List<int> questionOrder;

  /// Urutan indeks opsi asli untuk setiap soal pada [questionOrder].
  final List<List<int>> optionOrders;

  /// Total waktu pengerjaan sebelum kuis disimpan.
  final Duration elapsed;
}

extension CategoryIdX on CategoryId {
  String get route => name;
}

extension DifficultyX on Difficulty {
  String get label => switch (this) {
    Difficulty.pemula => 'Pemula',
    Difficulty.menengah => 'Menengah',
    Difficulty.ahli => 'Ahli',
  };

  /// Pengali XP aturan KAGE: Pemula 1.0, Menengah 1.5, Ahli 2.0.
  double get xpMultiplier => switch (this) {
    Difficulty.pemula => 1.0,
    Difficulty.menengah => 1.5,
    Difficulty.ahli => 2.0,
  };
}

Color scoreTint(int score) {
  if (score >= 90) return AppColors.gold;
  if (score >= 80) return AppColors.success;
  if (score >= 70) return AppColors.sains;
  return AppColors.textSoft;
}
