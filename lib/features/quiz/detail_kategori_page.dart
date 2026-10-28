import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

class DetailKategoriPage extends StatelessWidget {
  const DetailKategoriPage({super.key, required this.id});

  final CategoryId id;

  @override
  Widget build(BuildContext context) {
    final bank = context.read<QuizRepository>();
    final cat = bank.categoryById(id);
    final quiz = context.watch<QuizController>();
    final history = context.watch<HistoryController>();
    final counts = {
      for (final difficulty in Difficulty.values)
        difficulty: bank.questionsFor(id, difficulty).length,
    };
    final available = Difficulty.values
        .where((difficulty) => counts[difficulty]! > 0)
        .toList();
    final effective = available.contains(quiz.selectedDifficulty)
        ? quiz.selectedDifficulty
        : available.isEmpty
        ? null
        : available.first;
    final activeCount = effective == null ? 0 : counts[effective]!;
    // Header height: 30% of screen, min 220, max 320
    final headerH = (MediaQuery.sizeOf(context).height * 0.30).clamp(
      220.0,
      320.0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Hero header
          SizedBox(
            height: headerH,
            child: Stack(
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF070B1E),
                        Color(0xFF141A45),
                        Color(0xFF2B1D4A),
                        AppColors.background,
                      ],
                      stops: [0, 0.55, 0.85, 1],
                    ),
                  ),
                  child: SizedBox.expand(),
                ),
                StarField(height: headerH),
                Positioned.fill(
                  top: 52,
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svg/astrolab.svg',
                      width: headerH * 0.65,
                      height: headerH * 0.65,
                    ),
                  ),
                ),
                SafeArea(
                  child: SizedBox(
                    height: 64,
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        BackIconButton(
                          label: 'Kembali ke daftar kategori',
                          onTap: () => context.pop(),
                        ),
                        Text(
                          'Detail Kategori',
                          style: AppTextStyles.titleMediumTight,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cat.name,
                          style: AppTextStyles.displayMedium,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Tersedia',
                          style: AppTextStyles.captionLooseSuccess,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(cat.description, style: AppTextStyles.bodyLooseSoft),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in cat.tags)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderStrong),
                          ),
                          child: Text(
                            t,
                            style: AppTextStyles.captionRelaxedMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pilih tingkat kesulitan',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _diff(
                        quiz,
                        Difficulty.pemula,
                        counts[Difficulty.pemula]!,
                        effective == Difficulty.pemula,
                      ),
                      const SizedBox(width: 10),
                      _diff(
                        quiz,
                        Difficulty.menengah,
                        counts[Difficulty.menengah]!,
                        effective == Difficulty.menengah,
                      ),
                      const SizedBox(width: 10),
                      _diff(
                        quiz,
                        Difficulty.ahli,
                        counts[Difficulty.ahli]!,
                        effective == Difficulty.ahli,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _row(
                          Icons.assignment_outlined,
                          '$activeCount Soal',
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        _row(
                          Icons.emoji_events_outlined,
                          'Skor Terbaik',
                          trailing: Text(
                            '${history.bestFor(id)}',
                            style: AppTextStyles.titleLargeGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Mulai',
                    onTap: effective == null
                        ? null
                        : () {
                            quiz.startQuiz(id, difficulty: effective);
                            context.push('/kuis');
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _diff(QuizController quiz, Difficulty d, int count, bool selected) {
    final enabled = count > 0;
    final on = enabled && selected;
    return Expanded(
      child: Column(
        children: [
          KageTappable(
            onTap: enabled ? () => quiz.setDifficulty(d) : null,
            borderRadius: BorderRadius.circular(24),
            selected: on,
            semanticLabel: enabled
                ? 'Tingkat ${d.label}, $count soal'
                : 'Tingkat ${d.label}, belum tersedia',
            excludeChildSemantics: true,
            child: Container(
              // Area sentuh minimal 48 dp (U-02).
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on
                    ? AppColors.success.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: on ? AppColors.success : AppColors.borderStrong,
                  width: 1.5,
                ),
              ),
              child: Text(
                d.label,
                style: AppTextStyles.labelRelaxed.copyWith(
                  fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                  color: on
                      ? AppColors.success
                      : enabled
                      ? AppColors.textMuted
                      : AppColors.textMuted.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            enabled ? '$count soal' : 'Segera hadir',
            textAlign: TextAlign.center,
            style: AppTextStyles.captionMuted,
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, {required Widget trailing}) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyLargeMedium)),
            trailing,
          ],
        ),
      ),
    );
  }
}
