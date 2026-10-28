import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/models/models.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

/// Kategori bisa dimainkan bila bank soal sudah menyediakan soalnya (U-10).
bool isPlayable(QuizRepository bank, QuizCategory category) =>
    category.available && bank.questionCountFor(category.id) > 0;

/// Urutan daftar kategori pada halaman Kategori (U-10).
enum CategorySort {
  nama('A-Z'),
  terbaru('Terbaru'),
  skor('Skor');

  const CategorySort(this.label);

  final String label;
}

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  int tab = 0;
  final TextEditingController _search = TextEditingController();
  String _query = '';

  CategorySort _sort = CategorySort.nama;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Daftar kategori setelah disaring dan diurutkan (U-10).
  List<QuizCategory> _visible(QuizRepository bank, HistoryController history) {
    final query = _query.trim().toLowerCase();
    final items = bank.categories.where((category) {
      // Kategori tanpa soal diperlakukan sama seperti kategori yang belum
      // dirilis, sehingga tidak pernah bisa dimainkan (U-10).
      if (tab == 1 && !isPlayable(bank, category)) return false;
      if (query.isEmpty) return true;
      final haystack = <String>[
        category.name,
        category.shortName,
        category.description,
        ...category.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();

    switch (_sort) {
      case CategorySort.nama:
        items.sort((a, b) => a.name.compareTo(b.name));
      case CategorySort.terbaru:
        items.sort((a, b) {
          final first = history.lastPlayedAt(a.id);
          final second = history.lastPlayedAt(b.id);
          if (first == null && second == null) return a.name.compareTo(b.name);
          if (first == null) return 1;
          if (second == null) return -1;
          return second.compareTo(first);
        });
      case CategorySort.skor:
        items.sort((a, b) {
          final byScore = history
              .bestFor(b.id)
              .compareTo(history.bestFor(a.id));
          return byScore != 0 ? byScore : a.name.compareTo(b.name);
        });
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final bank = context.read<QuizRepository>();
    final history = context.watch<HistoryController>();
    final items = _visible(bank, history);

    return ScreenScaffold(
      navIndex: 1,
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
                  Text('Pilih Kategori', style: AppTextStyles.headlineLarge),
                ],
              ),
            ),
            Text(
              'Tantang pengetahuanmu di berbagai bidang.',
              style: AppTextStyles.bodyMuted,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _search,
              hint: 'Cari kategori atau topik',
              icon: Icons.search,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final option in CategorySort.values) ...[
                  Expanded(
                    child: KageTappable(
                      onTap: () => setState(() => _sort = option),
                      borderRadius: BorderRadius.circular(12),
                      selected: _sort == option,
                      semanticLabel:
                          'Urutkan ${option.label}'
                          '${_sort == option ? ', aktif' : ''}',
                      excludeChildSemantics: true,
                      child: Container(
                        // Area sentuh minimal 48 dp (U-02).
                        constraints: const BoxConstraints(minHeight: 48),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _sort == option
                              ? AppColors.surface
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _sort == option
                                ? AppColors.gold
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          option.label,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.captionMuted.copyWith(
                            color: _sort == option
                                ? AppColors.gold
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Container(
              // Tinggi 58 = target sentuh 48 dp + padding 4 dp di tiap sisi
              // + tebal garis 1 dp (U-02).
              height: 58,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _seg(0, 'Semua'),
                  const SizedBox(width: 4),
                  _seg(1, 'Tersedia'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surface,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(
                                Icons.menu_book_outlined,
                                color: AppColors.textMuted,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Belum ada kategori tersedia',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Coba lihat semua kategori yang sedang disiapkan.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySmallRelaxedMuted,
                            ),
                            const SizedBox(height: 12),
                            OutlineButton(
                              label: 'Tampilkan semua',
                              width: 180,
                              height: 44,
                              onTap: () => setState(() => tab = 0),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final c = items[i];
                        final count = bank.questionCountFor(c.id);
                        final available = isPlayable(bank, c);
                        final best = history.bestFor(c.id);
                        final status = !available
                            ? 'Segera hadir'
                            : best > 0
                            ? 'Skor terbaik $best'
                            : 'Belum pernah dimainkan';
                        return KageTappable(
                          onTap: available
                              ? () => context.push('/kategori/${c.id.name}')
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          semanticLabel:
                              'Kategori ${c.name}, $count soal, '
                              '${status.toLowerCase()}',
                          excludeChildSemantics: true,
                          child: Container(
                            // Tinggi minimum, bukan tetap, supaya kartu tumbuh
                            // pada skala font sistem yang besar (U-02).
                            constraints: const BoxConstraints(minHeight: 92),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                CategoryIconBadge(
                                  category: c,
                                  size: 56,
                                  iconSize: 28,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: AppTextStyles.titleMedium,
                                      ),
                                      Text(
                                        '${bank.questionCountFor(c.id)} soal',
                                        style: AppTextStyles.bodySmallMuted,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (available
                                                      ? AppColors.success
                                                      : AppColors.textMuted)
                                                  .withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          status,
                                          style: AppTextStyles
                                              .captionRelaxedSuccess
                                              .copyWith(
                                                color: available
                                                    ? AppColors.success
                                                    : AppColors.textMuted,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textMuted,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seg(int i, String label) {
    final on = tab == i;
    return Expanded(
      child: KageTappable(
        onTap: () => setState(() => tab = i),
        borderRadius: BorderRadius.circular(9),
        selected: on,
        semanticLabel: 'Tab $label${on ? ', aktif' : ''}',
        excludeChildSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: on ? FontWeight.w600 : FontWeight.w500,
              color: on ? AppColors.text : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
