import 'package:flutter/material.dart';

import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';

/// Daftar tinjauan jawaban yang bisa dibuka satu per satu.
///
/// Dipakai halaman Hasil (U-04) dan halaman detail Riwayat (U-11) supaya
/// keduanya menampilkan bentuk yang sama.
class AnswerReviewPanel extends StatelessWidget {
  const AnswerReviewPanel({
    super.key,
    required this.reviews,
    this.title = 'Tinjau jawaban',
    this.subtitle = 'Buka satu soal untuk membaca pembahasannya.',
  });

  final List<QuizReview> reviews;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return const SizedBox.shrink();
    // Material, bukan Container, agar perluasan tile tetap menggambar latarnya
    // dengan benar.
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderStrong),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmallMuted),
            const SizedBox(height: 8),
            for (var i = 0; i < reviews.length; i++)
              _ReviewTile(item: reviews[i], index: i),
          ],
        ),
      ),
    );
  }
}

/// Satu soal pada tinjauan jawaban: status, yang dipilih, dan pembahasan.
class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.item, required this.index});

  final QuizReview item;
  final int index;

  @override
  Widget build(BuildContext context) {
    const letters = ['A', 'B', 'C', 'D'];
    final color = item.correct ? AppColors.success : AppColors.primaryText;
    final chosen = item.chosenIndex;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 12),
        iconColor: AppColors.textMuted,
        collapsedIconColor: AppColors.textMuted,
        leading: Icon(
          item.correct ? Icons.check_circle : Icons.cancel,
          color: color,
          size: 20,
        ),
        title: Text(
          '${index + 1}. ${item.question.prompt}',
          style: AppTextStyles.bodyMedium,
        ),
        subtitle: Text(
          item.correct
              ? 'Jawabanmu benar'
              : chosen == null
              ? 'Tidak dijawab'
              : 'Jawabanmu ${letters[chosen]}. ${item.chosenOption}',
          style: AppTextStyles.bodySmallMuted,
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Jawaban benar: '
              '${letters[item.question.correctIndex]}. ${item.correctOption}',
              style: AppTextStyles.bodySmallStrong.copyWith(
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.question.explanation,
              style: AppTextStyles.bodySmallRelaxedMuted,
            ),
          ),
        ],
      ),
    );
  }
}
