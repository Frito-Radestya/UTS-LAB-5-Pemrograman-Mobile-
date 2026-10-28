import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/models/models.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/history/score_trend.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

/// Rentang waktu riwayat yang ditampilkan (U-11).
enum HistoryRange {
  semua('Semua waktu', null),
  tujuhHari('7 hari', 7),
  tigaPuluhHari('30 hari', 30);

  const HistoryRange(this.label, this.days);

  final String label;

  /// Jumlah hari ke belakang, `null` berarti tanpa batas.
  final int? days;
}

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  CategoryId? category;
  Difficulty? difficulty;
  HistoryRange range = HistoryRange.semua;

  bool get _hasFilter =>
      category != null || difficulty != null || range != HistoryRange.semua;

  /// Riwayat setelah disaring kategori, tingkat kesulitan, dan rentang waktu.
  List<QuizResult> _visible(HistoryController history, DateTime now) {
    return history.history.where((item) {
      if (category != null && item.categoryId != category) return false;
      if (difficulty != null && item.difficulty != difficulty) return false;
      final days = range.days;
      if (days != null &&
          item.playedAt.isBefore(now.subtract(Duration(days: days)))) {
        return false;
      }
      return true;
    }).toList();
  }

  void _resetFilters() => setState(() {
    category = null;
    difficulty = null;
    range = HistoryRange.semua;
  });

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryController>();
    final items = _visible(history, DateTime.now());

    return ScreenScaffold(
      navIndex: 2,
      stack: const [TopWash(height: 200)],
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                      label: 'Kembali ke beranda',
                      onTap: () => context.go('/beranda'),
                    ),
                  ),
                  Text('Riwayat Skor', style: AppTextStyles.headlineLarge),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _chipRow([
              _chip(null, 'Semua'),
              for (final id in CategoryId.values)
                _chip(
                  id,
                  context.read<QuizRepository>().categoryById(id).shortName,
                ),
            ]),
            const SizedBox(height: 8),
            _chipRow([
              _difficultyChip(null, 'Semua tingkat'),
              for (final value in Difficulty.values)
                _difficultyChip(value, value.label),
            ]),
            const SizedBox(height: 8),
            _chipRow([
              for (final value in HistoryRange.values) _rangeChip(value),
            ]),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _mini('${items.length}', 'Ditampilkan'),
                  _div(),
                  _mini('${_average(items)}', 'Rata-rata Skor'),
                  _div(),
                  _mini('${_best(items)}', 'Skor Terbaik'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (items.length >= 2) ...[
              ScoreTrendChart(results: items),
              const SizedBox(height: 12),
            ],
            Expanded(
              child: items.isEmpty
                  ? Center(
                      // Dapat digulir supaya teks tidak meluber pada skala font
                      // sistem yang besar (U-02).
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ilustrasi kuil yang sama dengan layar lain, agar
                            // keadaan kosong tetap terasa bagian dari KAGE.
                            const Opacity(
                              opacity: 0.9,
                              child: ToriiArt(width: 120, height: 100),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _hasFilter
                                  ? 'Belum ada riwayat pada filter ini'
                                  : 'Belum ada riwayat kuis',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _hasFilter
                                  ? 'Coba longgarkan filter atau tampilkan semua riwayat.'
                                  : 'Jejak perjalananmu akan tercatat di sini. '
                                        'Mulai satu kuis untuk mengisi kuil ini.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmallRelaxedMuted,
                            ),
                            const SizedBox(height: 12),
                            if (_hasFilter)
                              OutlineButton(
                                label: 'Tampilkan semua',
                                width: 180,
                                height: 44,
                                onTap: _resetFilters,
                              )
                            else
                              OutlineButton(
                                label: 'Mulai kuis pertama',
                                width: 200,
                                height: 44,
                                onTap: () => context.go('/kategori'),
                              ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final result = items[i];
                        final cat = context.read<QuizRepository>().categoryById(
                          result.categoryId,
                        );
                        return KageTappable(
                          onTap: () =>
                              context.push('/riwayat/detail', extra: result),
                          borderRadius: BorderRadius.circular(14),
                          semanticLabel:
                              'Riwayat ${cat.name} ${result.difficulty.label}, '
                              'skor ${result.score}, buka detail',
                          excludeChildSemantics: true,
                          child: ScoreRow(result: result),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipRow(List<Widget> children) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _chip(CategoryId? id, String label) {
    final on = category == id;
    return KageTappable(
      onTap: () => setState(() => category = id),
      borderRadius: BorderRadius.circular(24),
      selected: on,
      semanticLabel: 'Filter $label${on ? ', aktif' : ''}',
      excludeChildSemantics: true,
      child: Container(
        // Area sentuh minimal 48 dp (U-02).
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: on ? null : Border.all(color: AppColors.borderStrong),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: on ? FontWeight.w600 : FontWeight.w400,
            color: on ? AppColors.text : AppColors.textSoft,
          ),
        ),
      ),
    );
  }

  Widget _difficultyChip(Difficulty? value, String label) {
    final on = difficulty == value;
    return KageTappable(
      onTap: () => setState(() => difficulty = value),
      borderRadius: BorderRadius.circular(24),
      selected: on,
      semanticLabel: 'Filter tingkat $label${on ? ', aktif' : ''}',
      excludeChildSemantics: true,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on
              ? AppColors.gold.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: on ? AppColors.gold : AppColors.borderStrong,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.captionMuted.copyWith(
            color: on ? AppColors.gold : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _rangeChip(HistoryRange value) {
    final on = range == value;
    return KageTappable(
      onTap: () => setState(() => range = value),
      borderRadius: BorderRadius.circular(24),
      selected: on,
      semanticLabel: 'Rentang ${value.label}${on ? ', aktif' : ''}',
      excludeChildSemantics: true,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: on ? AppColors.borderStrong : AppColors.border,
          ),
        ),
        child: Text(
          value.label,
          style: AppTextStyles.captionMuted.copyWith(
            color: on ? AppColors.text : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  static int _average(List<QuizResult> items) {
    if (items.isEmpty) return 0;
    final total = items.fold<int>(0, (sum, item) => sum + item.score);
    return (total / items.length).round();
  }

  static int _best(List<QuizResult> items) {
    if (items.isEmpty) return 0;
    return items.map((item) => item.score).reduce((a, b) => a > b ? a : b);
  }

  Widget _mini(String v, String l) {
    return Expanded(
      child: Column(
        children: [
          Text(v, style: AppTextStyles.headlineSmallGold),
          Text(l, style: AppTextStyles.captionMuted),
        ],
      ),
    );
  }

  Widget _div() =>
      Container(width: 1, height: 36, color: AppColors.borderStrong);
}
