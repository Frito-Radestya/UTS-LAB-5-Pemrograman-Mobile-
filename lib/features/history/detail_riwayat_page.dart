import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/features/history/attempt_review.dart';
import 'package:kage/features/quiz/answer_review.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/models/models.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

/// Rincian satu percobaan kuis dari Riwayat: ringkasan dan tinjauan jawabannya.
class DetailRiwayatPage extends StatelessWidget {
  const DetailRiwayatPage({super.key, required this.result});

  final QuizResult result;

  @override
  Widget build(BuildContext context) {
    final bank = context.read<QuizRepository>();
    final quiz = context.read<QuizController>();
    final category = bank.categoryById(result.categoryId);
    final reviews = reviewFromResult(result, bank);
    final time =
        '${result.duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
        '${result.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return ScreenScaffold(
      navIndex: 2,
      stack: const [TopWash(height: 200)],
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  Transform.translate(
                    offset: const Offset(-12, 0),
                    child: BackIconButton(
                      label: 'Kembali ke riwayat',
                      onTap: () => context.go('/riwayat'),
                    ),
                  ),
                  Text('Detail Kuis', style: AppTextStyles.headlineLarge),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CategoryIconBadge(
                        category: category,
                        size: 48,
                        iconSize: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: AppTextStyles.titleMedium,
                            ),
                            Text(
                              '${result.difficulty.label} · ${_date(result.playedAt)}',
                              style: AppTextStyles.captionMuted,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${result.score}',
                        style: AppTextStyles.scoreValue.copyWith(
                          color: scoreTint(result.score),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _stat('${result.correct}/${result.total}', 'Benar'),
                      _divider(),
                      _stat('${result.accuracy}%', 'Akurasi'),
                      _divider(),
                      _stat(time, 'Durasi'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (reviews != null)
              AnswerReviewPanel(
                reviews: reviews,
                title: 'Tinjau jawaban',
                subtitle:
                    'Jawaban dan pembahasan seperti saat kuis ini dikerjakan.',
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rincian jawaban tidak tersedia',
                      style: AppTextStyles.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Percobaan ini tidak menyimpan pilihan jawaban, '
                      'misalnya karena berasal dari latihan soal salah atau '
                      'riwayat versi lama.',
                      style: AppTextStyles.bodySmallRelaxedMuted,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Coba Lagi',
              onTap: () {
                quiz.startQuiz(
                  result.categoryId,
                  difficulty: result.difficulty,
                );
                context.go('/kuis');
              },
            ),
            const SizedBox(height: 12),
            OutlineButton(
              label: 'Kembali ke Riwayat',
              onTap: () => context.go('/riwayat'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.headlineSmallGold),
          Text(label, style: AppTextStyles.captionMuted),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: AppColors.borderStrong);

  static String _date(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.day} ${months[value.month - 1]} ${value.year} · '
        '$hour:$minute';
  }
}
