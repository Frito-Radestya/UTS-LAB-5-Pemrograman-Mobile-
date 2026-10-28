import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/answer_review.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

class HasilPage extends StatelessWidget {
  const HasilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizController>();
    final r = quiz.lastResult;
    if (r == null) {
      // Router mengalihkan halaman ini bila tidak ada kuis, tetapi bila dibuka
      // langsung tetap ada pesan yang jelas, bukan layar kosong (U-07).
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Opacity(
                    opacity: 0.9,
                    child: ToriiArt(width: 120, height: 100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada hasil kuis',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selesaikan satu kuis dulu untuk melihat hasilnya di sini.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmallRelaxedMuted,
                  ),
                  const SizedBox(height: 16),
                  OutlineButton(
                    label: 'Kembali ke Beranda',
                    width: 200,
                    height: 44,
                    onTap: () => context.go('/beranda'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    final cat = context.read<QuizRepository>().categoryById(r.categoryId);
    final time =
        '${r.duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${r.duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    final title = r.score >= 90
        ? 'Luar Biasa!'
        : r.score >= 70
        ? 'Kamu Hebat!'
        : r.score >= 50
        ? 'Terus Berlatih!'
        : 'Jangan Menyerah!';
    final subtitle = r.score >= 90
        ? 'Penguasaan materimu sangat baik.'
        : r.score >= 70
        ? 'Sedikit lagi menuju skor sempurna.'
        : 'Setiap percobaan membuatmu semakin paham.';
    final difficulty = switch (r.difficulty) {
      Difficulty.pemula => 'Pemula',
      Difficulty.menengah => 'Menengah',
      Difficulty.ahli => 'Ahli',
    };

    // Perbandingan dengan percobaan lain di kategori yang sama.
    final history = context.watch<HistoryController>();
    final others = history.history.where(
      (item) => item.categoryId == r.categoryId && !identical(item, r),
    );
    final previousBest = others.isEmpty
        ? null
        : others.map((item) => item.score).reduce(math.max);
    final recordText = switch (previousBest) {
      null => 'Catatan pertama untuk kategori ini.',
      _ when r.score > previousBest =>
        'Rekor baru! +${r.score - previousBest} dari terbaikmu sebelumnya.',
      _ when r.score == previousBest => 'Menyamai rekor terbaikmu.',
      _ => '${r.score - previousBest} dari terbaikmu (skor $previousBest).',
    };

    // XP yang baru diperoleh dan perubahan levelnya.
    final progress = context.watch<ProgressController>();
    final xpGained = (r.score * r.difficulty.xpMultiplier).round();
    final xpBefore = math.max(0, progress.xp - xpGained);
    final levelBefore = levelFromXp(xpBefore);
    final levelAfter = progress.level;
    final levelText = levelAfter > levelBefore
        ? 'Naik ke level $levelAfter'
        : 'Level $levelAfter';
    final remainingText = '${progress.remainingXp} XP lagi ke level berikutnya';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top radial glow
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 380,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.44),
                  radius: 0.9,
                  colors: [
                    Color(0x73B9232C),
                    Color(0x405A1428),
                    Color(0x000B0D12),
                  ],
                  stops: [0, 0.38, 0.72],
                ),
              ),
            ),
          ),
          // Animated petals
          const AnimatedSakuraPetal(
            left: 16,
            top: 40,
            width: 11,
            height: 8,
            angle: 30,
            opacity: 0.85,
            duration: Duration(seconds: 5),
            delayFraction: 0.0,
          ),
          const AnimatedSakuraPetal(
            left: 60,
            top: 20,
            width: 9,
            height: 6,
            angle: -20,
            opacity: 0.8,
            color: Color(0xFFF09AB0),
            duration: Duration(seconds: 6),
            delayFraction: 0.4,
          ),
          // Right side petals via LayoutBuilder so they don't overflow
          LayoutBuilder(
            builder: (context, constraints) {
              final w = MediaQuery.sizeOf(context).width;
              return Stack(
                children: [
                  AnimatedSakuraPetal(
                    left: w - 52,
                    top: 30,
                    width: 12,
                    height: 8,
                    angle: 60,
                    opacity: 0.85,
                    duration: const Duration(seconds: 4),
                    delayFraction: 0.65,
                  ),
                  AnimatedSakuraPetal(
                    left: w - 72,
                    top: 20,
                    width: 9,
                    height: 6,
                    angle: 10,
                    opacity: 0.8,
                    color: const Color(0xFFF09AB0),
                    duration: const Duration(seconds: 7),
                    delayFraction: 0.2,
                  ),
                  const AnimatedSakuraPetal(
                    left: 16,
                    top: 80,
                    width: 10,
                    height: 7,
                    angle: -50,
                    opacity: 0.7,
                    duration: Duration(seconds: 5),
                    delayFraction: 0.8,
                  ),
                  AnimatedSakuraPetal(
                    left: w - 62,
                    top: 60,
                    width: 10,
                    height: 7,
                    angle: 40,
                    opacity: 0.7,
                    color: const Color(0xFFF09AB0),
                    duration: const Duration(seconds: 6),
                    delayFraction: 0.5,
                  ),
                ],
              );
            },
          ),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  const _HasilEmblem(),
                  const SizedBox(height: 16),
                  Text(title, style: AppTextStyles.displayLargeGold),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmallRelaxedMuted,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CategoryIconBadge(category: cat, size: 28, iconSize: 14),
                      const SizedBox(width: 8),
                      Text(
                        '${cat.name} · $difficulty',
                        style: AppTextStyles.bodySmallMediumSoft,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Skor Akhir', style: AppTextStyles.bodySoft),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: r.score),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Text(
                      '$value',
                      style: AppTextStyles.displayScore.copyWith(
                        shadows: [
                          Shadow(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${r.correct}/${r.total} Benar',
                      style: AppTextStyles.labelLooseSuccess,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _card(Icons.schedule, 'Waktu', time),
                      const SizedBox(width: 12),
                      _card(Icons.gps_fixed, 'Akurasi', '${r.accuracy}%'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderStrong),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.bolt,
                              size: 18,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '+$xpGained XP',
                              style: AppTextStyles.titleLargeGold,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                levelText,
                                textAlign: TextAlign.right,
                                style: AppTextStyles.bodySmallMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        KageProgressBar(
                          value: progress.levelProgress,
                          height: 4,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          remainingText,
                          style: AppTextStyles.captionRelaxedMuted,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              previousBest != null && r.score > previousBest
                                  ? Icons.emoji_events
                                  : Icons.insights,
                              size: 16,
                              color:
                                  previousBest != null && r.score > previousBest
                                  ? AppColors.gold
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                recordText,
                                style: AppTextStyles.bodySmallRelaxedMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 24),
                    child: Text(
                      '"Pengetahuan adalah cahaya yang tak pernah padam."',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLooseQuoteItalic,
                    ),
                  ),
                  if (quiz.review.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    AnswerReviewPanel(reviews: quiz.review),
                  ],
                  const SizedBox(height: 16),
                  if (quiz.wrongReview.isNotEmpty) ...[
                    OutlineButton(
                      label:
                          'Ulangi ${quiz.wrongReview.length} soal yang salah',
                      onTap: () {
                        if (quiz.retryWrongOnly()) context.go('/kuis');
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  PrimaryButton(
                    label: 'Coba Lagi',
                    onTap: () {
                      quiz.startQuiz(r.categoryId);
                      context.go('/kuis');
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlineButton(
                    label: 'Kembali ke Beranda',
                    onTap: () => context.go('/beranda'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(label, style: AppTextStyles.bodySmallMuted),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.displaySmall),
          ],
        ),
      ),
    );
  }
}

class _HasilEmblem extends StatelessWidget {
  const _HasilEmblem();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(painter: _EmblemPainter()),
    );
  }
}

class _EmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(
      c,
      74,
      Paint()
        ..color = const Color(0xFF1A0E12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      c,
      74,
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      c,
      54,
      Paint()
        ..color = const Color(0xFFE0B86A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    final petal = Paint()..color = AppColors.gold;
    for (var i = 0; i < 5; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * 72 * 3.14159 / 180);
      canvas.drawOval(const Rect.fromLTWH(-11, -34, 22, 40), petal);
      canvas.restore();
    }
    canvas.drawCircle(c, 11, Paint()..color = AppColors.primary);
    canvas.drawCircle(
      c,
      11,
      Paint()
        ..color = AppColors.goldLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
