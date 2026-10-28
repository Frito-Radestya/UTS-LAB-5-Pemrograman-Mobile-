import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/settings/haptics.dart';
import 'package:kage/features/settings/settings_controller.dart';
import 'package:kage/features/settings/sounds.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

class KuisPage extends StatefulWidget {
  const KuisPage({super.key});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> with TickerProviderStateMixin {
  /// Diaktifkan sesaat sebelum keluar supaya _PopScope tidak menahan pop yang
  /// sudah dikonfirmasi pengguna.
  bool _leaving = false;
  AnimationController? _timerController;
  int _timerQuestionIndex = -1;

  @override
  void dispose() {
    _timerController?.dispose();
    super.dispose();
  }

  void _startTimer(
    QuizController quiz,
    SettingsController settings,
    Difficulty difficulty,
  ) {
    if (!settings.timerEnabled) {
      _timerController?.stop();
      _timerController?.dispose();
      _timerController = null;
      _timerQuestionIndex = quiz.questionIndex;
      return;
    }
    if (_timerQuestionIndex == quiz.questionIndex && _timerController != null) {
      return;
    }
    _timerController?.dispose();
    final seconds = QuizTimerConfig.secondsFor(difficulty);
    final controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds),
    );
    _timerController = controller;
    _timerQuestionIndex = quiz.questionIndex;
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        final q = context.read<QuizController>();
        if (q.questionIndex == _timerQuestionIndex && !q.currentQuestionLocked) {
          q.timeoutCurrent();
          // Jika belum menjawab, kunci soal sebagai tidak terjawab lalu
          // arahkan ke penjelasan agar pengguna bisa lanjut (U-06).
          if (q.answers[q.questionIndex] == null) {
            context.push('/penjelasan');
          }
        }
      }
    });
    if (!MediaQuery.of(context).disableAnimations) {
      controller.forward();
    } else {
      controller.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizController>();
    final settings = context.watch<SettingsController>();
    final q = quiz.currentQuestion;
    final cat = quiz.activeCategory == null
        ? null
        : context.read<QuizRepository>().categoryById(quiz.activeCategory!);
    if (q == null || cat == null) {
      _timerController?.stop();
      return const Scaffold(backgroundColor: AppColors.background);
    }
    if (!quiz.currentQuestionLocked) {
      _startTimer(quiz, settings, quiz.selectedDifficulty);
    } else {
      _timerController?.stop();
    }
    final selected = quiz.answers[quiz.questionIndex];
    final locked = quiz.currentQuestionLocked;
    const letters = ['A', 'B', 'C', 'D'];
    final total = quiz.totalQuestions;
    final diff = switch (quiz.selectedDifficulty) {
      Difficulty.pemula => 'PEMULA',
      Difficulty.menengah => 'MENENGAH',
      Difficulty.ahli => 'AHLI',
    };

    return PopScope(
      canPop: _leaving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExit(context, quiz);
      },
      child: _body(
        context,
        quiz,
        q,
        cat,
        selected,
        locked,
        letters,
        total,
        diff,
        settings,
      ),
    );
  }

  Widget _body(
    BuildContext context,
    QuizController quiz,
    Question q,
    QuizCategory cat,
    int? selected,
    bool locked,
    List<String> letters,
    int total,
    String diff,
    SettingsController settings,
  ) {
    final showTimer =
        settings.timerEnabled && !locked && _timerController != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Bottom glow
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 300,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, 1),
                  radius: 1.1,
                  colors: [
                    Color(0x47F28C3C),
                    Color(0x1FB9232C),
                    Color(0x000B0D12),
                  ],
                  stops: [0, 0.4, 0.75],
                ),
              ),
            ),
          ),
          // Animated lanterns
          const Positioned(
            left: 16,
            bottom: 100,
            child: RepaintBoundary(
              child: AnimatedLantern(
                opacity: 0.75,
                duration: Duration(milliseconds: 1900),
              ),
            ),
          ),
          const Positioned(
            right: 16,
            bottom: 120,
            child: RepaintBoundary(
              child: AnimatedLantern(
                opacity: 0.75,
                duration: Duration(milliseconds: 2300),
                delayFraction: 0.5,
              ),
            ),
          ),
          // Main scrollable content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: SizedBox(
                    // Tinggi minimum, bukan tetap, agar target 48 dp tidak
                    // terpotong dan judul tetap utuh pada font besar (U-02).
                    height: 48,
                    child: Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-12, 0),
                          child: BackIconButton(
                            label: 'Keluar dari kuis',
                            onTap: () => _confirmExit(context, quiz),
                          ),
                        ),
                        Expanded(
                          child: KageProgressBar(
                            value: (quiz.questionIndex + 1) / total,
                            glow: true,
                            semanticLabel:
                                'Soal ${quiz.questionIndex + 1} dari $total',
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${quiz.questionIndex + 1}/$total',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.label,
                          ),
                        ),
                        // Tombol lain dipindah ke menu agar tombol utama tidak
                        // berdesakan di layar kecil (U-05).
                        PopupMenuButton<String>(
                          tooltip: 'Menu kuis',
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppColors.textMuted,
                          ),
                          color: AppColors.surface,
                          onSelected: (value) {
                            if (value != 'save') return;
                            quiz.saveProgress();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Progres disimpan. Lanjutkan kapan saja dari Beranda.',
                                ),
                                backgroundColor: AppColors.surface,
                              ),
                            );
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'save',
                              child: Text(
                                'Simpan progres',
                                style: AppTextStyles.body,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (showTimer)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Semantics(
                      label: 'Waktu tersisa untuk soal ini',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: AnimatedBuilder(
                          animation: _timerController!,
                          builder: (context, child) {
                            final value = 1.0 - _timerController!.value;
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 4,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                value > 0.25
                                    ? AppColors.gold
                                    : AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                // Scrollable body so options never overflow
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cat.name.toUpperCase()} · $diff',
                          style: AppTextStyles.bodySmallGoldSpaced,
                        ),
                        const SizedBox(height: 8),
                        Text(q.prompt, style: AppTextStyles.headlineSmallLoose),
                        const SizedBox(height: 16),
                        _indicator(quiz),
                        const SizedBox(height: 20),
                        for (var i = 0; i < q.options.length; i++) ...[
                          _option(
                            letter: letters[i],
                            text: q.options[i],
                            selected: selected == i,
                            locked: locked,
                            onTap: locked
                                ? null
                                : () {
                                    kageHaptic(context, KageHaptic.light);
                                    kageSound(context, KageSound.tap);
                                    quiz.selectAnswer(i);
                                  },
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (locked) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Jawaban sudah dikirim dan terkunci.',
                                  style: AppTextStyles.captionRelaxedMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 4),
                        PrimaryButton(
                          label: locked
                              ? 'Lihat Penjelasan'
                              : quiz.isLastQuestion
                              ? 'Selesai'
                              : 'Selanjutnya',
                          onTap: locked
                              ? () => context.push('/penjelasan')
                              : selected == null
                              ? null
                              : () {
                                  quiz.submitCurrent();
                                  context.push('/penjelasan');
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

  Future<void> _confirmExit(BuildContext context, QuizController quiz) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
        title: Text('Keluar dari kuis?', style: AppTextStyles.titleLarge),
        content: Text(
          'Progres jawabanmu akan disimpan dan bisa dilanjutkan dari Beranda.',
          style: AppTextStyles.bodyRelaxedSoft,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Batal', style: AppTextStyles.labelMuted),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Simpan & keluar', style: AppTextStyles.labelPrimary),
          ),
        ],
      ),
    );
    if (shouldLeave == true && context.mounted) {
      quiz.saveProgress();
      setState(() => _leaving = true);
      // Halaman kuis bisa dibuka langsung dari resume tanpa tumpukan rute,
      // jadi kembali ke Beranda bila tidak ada yang bisa di-pop.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/beranda');
      }
    }
  }

  /// Indikator soal terjawab dan belum.
  Widget _indicator(QuizController quiz) {
    final answered = quiz.answers.where((answer) => answer != null).length;
    return Semantics(
      label:
          'Soal ${quiz.questionIndex + 1} dari ${quiz.totalQuestions}, '
          '$answered terjawab',
      excludeSemantics: true,
      child: SizedBox(
        height: 26,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: quiz.totalQuestions,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, i) {
            final filled = i < quiz.answers.length && quiz.answers[i] != null;
            final current = i == quiz.questionIndex;
            return Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: filled ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: current
                      ? AppColors.gold
                      : filled
                      ? AppColors.primary
                      : AppColors.borderStrong,
                  width: current ? 2 : 1,
                ),
              ),
              child: Text(
                '${i + 1}',
                style: AppTextStyles.caption.copyWith(
                  color: filled ? AppColors.text : AppColors.textMuted,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _option({
    required String letter,
    required String text,
    required bool selected,
    required bool locked,
    required VoidCallback? onTap,
  }) {
    return KageTappable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      selected: selected,
      semanticLabel:
          'Pilihan $letter. $text'
          '${locked ? ', terkunci' : (selected ? ', terpilih' : '')}',
      excludeChildSemantics: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: locked ? 0.1 : 0.16)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          boxShadow: selected && !locked
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: selected
                    ? null
                    : Border.all(color: AppColors.outline, width: 1.5),
              ),
              child: Text(
                letter,
                style: AppTextStyles.answerLetter.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected ? AppColors.text : AppColors.textSoft,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (selected)
              Icon(
                locked ? Icons.lock_outline : Icons.check,
                color: AppColors.text,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
