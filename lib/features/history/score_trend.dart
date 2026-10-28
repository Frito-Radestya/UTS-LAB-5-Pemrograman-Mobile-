import 'package:flutter/material.dart';

import 'package:kage/models/models.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';

/// Grafik batang sederhana tren skor beberapa kuis terakhir.
///
/// Warna batang mengikuti [scoreTint] sehingga palet tetap sama dengan bagian
/// lain aplikasi. Riwayat tersimpan dengan yang terbaru di depan, sedangkan
/// grafik dibaca dari kiri (terlama) ke kanan (terbaru).
class ScoreTrendChart extends StatelessWidget {
  const ScoreTrendChart({super.key, required this.results, this.maxBars = 10});

  final List<QuizResult> results;
  final int maxBars;

  /// Tinggi area batang dalam piksel, di luar label skor.
  static const double _barAreaHeight = 56;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();
    final ordered = results.take(maxBars).toList().reversed.toList();
    final first = ordered.first.score;
    final last = ordered.last.score;
    final showValues = ordered.length <= 6;

    return Semantics(
      label:
          'Tren skor ${ordered.length} kuis terakhir, '
          'dari $first menjadi $last',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Tren skor', style: AppTextStyles.titleSmall),
                ),
                Text('$first → $last', style: AppTextStyles.captionMuted),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final result in ordered)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: _barAreaHeight,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                // Skor 0 tetap mendapat batang setipis 4 px
                                // supaya terlihat sebagai data, bukan ruang
                                // kosong.
                                height: _barHeight(result.score),
                                decoration: BoxDecoration(
                                  color: scoreTint(result.score),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            showValues ? '${result.score}' : '',
                            style: AppTextStyles.captionMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static double _barHeight(int score) {
    final clamped = score.clamp(0, 100);
    return 4 + (_barAreaHeight - 4) * (clamped / 100);
  }
}
