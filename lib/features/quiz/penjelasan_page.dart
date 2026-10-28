import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/settings/haptics.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

class PenjelasanPage extends StatefulWidget {
  const PenjelasanPage({super.key});

  @override
  State<PenjelasanPage> createState() => _PenjelasanPageState();
}

class _PenjelasanPageState extends State<PenjelasanPage> {
  @override
  void initState() {
    super.initState();
    // Getaran penilaian dijalankan sekali saat pembahasan dibuka, bukan setiap
    // kali halaman digambar ulang.
    final quiz = context.read<QuizController>();
    kageHaptic(
      context,
      quiz.showingCorrect ? KageHaptic.medium : KageHaptic.heavy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizController>();
    final q = quiz.currentQuestion;
    if (q == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    const letters = ['A', 'B', 'C', 'D'];
    final correct = quiz.showingCorrect;
    final chosen = quiz.questionIndex < quiz.answers.length
        ? quiz.answers[quiz.questionIndex]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top colour wash
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    correct ? const Color(0xFF10261F) : const Color(0xFF2A1218),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          // Subtle animated petal accent
          const AnimatedSakuraPetal(
            left: 12,
            top: 60,
            width: 10,
            height: 7,
            angle: 40,
            opacity: 0.55,
            duration: Duration(seconds: 6),
            delayFraction: 0.3,
          ),
          SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-12, 0),
                          child: BackIconButton(
                            label: 'Kembali ke soal terkunci',
                            onTap: () => context.go('/kuis'),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Penjelasan Jawaban',
                            style: AppTextStyles.titleLarge,
                          ),
                        ),
                        Text(
                          '${quiz.questionIndex + 1}/${quiz.totalQuestions}',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                // Scrollable body – prevents overflow on small screens
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      children: [
                        // Result card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:
                                (correct
                                        ? AppColors.success
                                        : AppColors.primary)
                                    .withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: correct
                                  ? AppColors.successBorder
                                  : AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: correct
                                          ? AppColors.successFill
                                          : AppColors.primary,
                                    ),
                                    child: Icon(
                                      correct ? Icons.check : Icons.close,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          correct ? 'Benar!' : 'Belum tepat',
                                          style: AppTextStyles.scoreValue
                                              .copyWith(
                                                color: correct
                                                    ? AppColors.success
                                                    : AppColors.primaryText,
                                              ),
                                        ),
                                        const SizedBox(height: 10),
                                        _answerRow(
                                          label: 'Jawabanmu',
                                          value: chosen == null
                                              ? 'Tidak dijawab'
                                              : '${letters[chosen]}. '
                                                    '${q.options[chosen]}',
                                          correct: correct,
                                          semanticLabel: chosen == null
                                              ? 'Jawabanmu: tidak dijawab'
                                              : 'Jawabanmu ${correct ? 'benar' : 'salah'}: '
                                                    '${letters[chosen]}. '
                                                    '${q.options[chosen]}',
                                        ),
                                        if (!correct) ...[
                                          const SizedBox(height: 8),
                                          _answerRow(
                                            label: 'Jawaban benar',
                                            value:
                                                '${letters[q.correctIndex]}. '
                                                '${q.options[q.correctIndex]}',
                                            correct: true,
                                            semanticLabel:
                                                'Jawaban benar: '
                                                '${letters[q.correctIndex]}. '
                                                '${q.options[q.correctIndex]}',
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: AppColors.success.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                              Text(
                                q.explanation,
                                style: AppTextStyles.bodyLargeQuote,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Fun fact card
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.borderStrong),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome,
                                          color: AppColors.gold,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Fakta Menarik',
                                          style: AppTextStyles.labelGold,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      q.funFact,
                                      style: AppTextStyles.bodyLooseQuote,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    center: Alignment(-0.3, -0.4),
                                    colors: [
                                      Color(0xFFF28B5E),
                                      Color(0xFFB9432C),
                                      Color(0xFF5A1E18),
                                    ],
                                    stops: [0, 0.55, 1],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x59F28B5E),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Quote card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF3A3F4D)),
                          ),
                          child: Row(
                            children: [
                              const EmblemMark(size: 26),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Setiap jawaban adalah langkah menuju kebenaran.',
                                  style: AppTextStyles.bodyMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // CTA
                        PrimaryButton(
                          label: 'Lanjutkan',
                          onTap: () {
                            if (quiz.isLastQuestion) {
                              quiz.finishQuiz();
                              context.go('/hasil');
                            } else {
                              quiz.nextQuestion();
                              context.go('/kuis');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Satu baris pembanding jawaban.
  ///
  /// Selain warna, ada ikon dan penanda ✓/✗ supaya perbedaan jawaban benar dan
  /// jawaban pengguna tetap terbaca oleh pengguna dengan buta warna (U-03).
  Widget _answerRow({
    required String label,
    required String value,
    required bool correct,
    required String semanticLabel,
  }) {
    final color = correct ? AppColors.success : AppColors.primaryText;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label ${correct ? '✓' : '✗'} ',
                    style: AppTextStyles.bodySmallStrong.copyWith(color: color),
                  ),
                  TextSpan(text: value, style: AppTextStyles.bodySmallRelaxed),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
