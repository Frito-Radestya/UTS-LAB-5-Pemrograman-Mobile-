import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final history = context.watch<HistoryController>();
    final quiz = context.watch<QuizController>();
    final bank = context.read<QuizRepository>();
    final resume = quiz.resume;
    final categoryCount = bank.categories.length;

    return ScreenScaffold(
      navIndex: 0,
      stack: const [TopWash(height: 220)],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        children: [
          // Header. Tinggi mengikuti isi, bukan angka tetap, supaya teks tetap
          // utuh pada skala font sistem yang besar (U-02).
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${auth.firstName}',
                      style: AppTextStyles.headline,
                    ),
                    Text(
                      'Terus belajar, terus berkembang.',
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              KageTappable(
                onTap: () => context.go('/profil'),
                borderRadius: BorderRadius.circular(24),
                semanticLabel: 'Buka profil ${auth.firstName}',
                excludeChildSemantics: true,
                child: _avatar(auth.initial, 48, 16),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Akun baru mendapat ajakan memulai, bukan progres kosong.
          if (history.history.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.gold,
                    size: 22,
                  ),
                  const SizedBox(height: 10),
                  Text('Mulai kuis pertamamu', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih satu kategori dan mulai perjalanan pengetahuanmu.',
                    style: AppTextStyles.bodyRelaxedSoft,
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    label: 'Pilih kategori',
                    onTap: () => context.go('/kategori'),
                  ),
                ],
              ),
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
                  Row(
                    children: [
                      Text('Progres Belajar', style: AppTextStyles.bodyMuted),
                      const Spacer(),
                      Text(
                        '${((history.learningPathDone / categoryCount) * 100).round()}%',
                        style: AppTextStyles.labelGold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${history.learningPathDone} / $categoryCount Kategori',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  KageProgressBar(
                    value: history.learningPathDone / categoryCount,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // "Lanjutkan Petualangan" hanya muncul jika ada kuis tersimpan.
          if (resume != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1440),
                      Color(0xFF2D1534),
                      Color(0xFF0F1A2A),
                    ],
                    stops: [0, 0.55, 1],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.gold),
                                ),
                                child: Text(
                                  bank.categoryById(resume.categoryId).name,
                                  style: AppTextStyles.captionRelaxedGold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Lanjutkan Petualangan',
                                style: AppTextStyles.titleLarge,
                              ),
                              Text(
                                'Soal ${resume.index + 1} dari '
                                '${bank.questionsFor(resume.categoryId, resume.difficulty).length}',
                                style: AppTextStyles.bodySoft,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Torii art + moon as decorative overlay
                        Stack(
                          children: [
                            const Opacity(
                              opacity: 0.55,
                              child: ToriiArt(width: 120, height: 100),
                            ),
                            const Positioned(
                              right: 12,
                              top: 8,
                              child: MoonGlow(size: 22, glow: 16),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: KageTappable(
                                onTap: () {
                                  quiz.continueAdventure();
                                  context.push('/kuis');
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    KageProgressBar(
                      value:
                          (resume.index + 1) /
                          bank
                              .questionsFor(
                                resume.categoryId,
                                resume.difficulty,
                              )
                              .length,
                      height: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _stat('${history.totalQuizzes}', 'Total Kuis'),
              const SizedBox(width: 12),
              _stat('${history.accuracyPercent}%', 'Akurasi'),
              const SizedBox(width: 12),
              _stat('${history.streak}', 'Streak'),
            ],
          ),
          const SizedBox(height: 18),
          // Category section header
          Row(
            children: [
              Text('Kategori Kuis', style: AppTextStyles.titleLarge),
              const Spacer(),
              KageTappable(
                onTap: () => context.go('/kategori'),
                semanticLabel: 'Lihat semua kategori',
                excludeChildSemantics: true,
                child: SizedBox(
                  // Area sentuh minimal 48 dp (U-02).
                  height: 48,
                  child: Center(
                    child: Text(
                      'Lihat Semua',
                      style: AppTextStyles.bodyPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Category icons – uses Row with Expanded so each is equally spaced
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final c in bank.categories)
                Expanded(
                  child: KageTappable(
                    onTap: () => context.push('/kategori/${c.id.name}'),
                    semanticLabel:
                        'Kategori ${c.name}, ${bank.questionCountFor(c.id)} soal',
                    excludeChildSemantics: true,
                    child: Column(
                      children: [
                        CategoryIconBadge(category: c),
                        const SizedBox(height: 6),
                        Text(
                          c.shortName,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.captionSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Quote banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const EmblemMark(size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pengetahuan adalah cahaya yang tak pernah padam.',
                    style: AppTextStyles.bodyQuote,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.headlineGold),
            Text(label, style: AppTextStyles.captionMuted),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String initial, double size, double font) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.4, -0.5),
          colors: [Color(0xFF3B2A4E), AppColors.surface],
        ),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Text(initial, style: AppTextStyles.avatarInitial(font)),
    );
  }
}
