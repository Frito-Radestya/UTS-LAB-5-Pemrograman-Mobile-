import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

/// Bantuan singkat berisi pertanyaan yang paling sering muncul (U-08).
class BantuanPage extends StatelessWidget {
  const BantuanPage({super.key});

  static const List<({String question, String answer})> _faq = [
    (
      question: 'Bagaimana cara memulai kuis?',
      answer:
          'Buka tab Kategori, pilih kategori, lalu pilih tingkat kesulitan yang '
          'sudah tersedia. Tingkat yang belum punya soal ditandai "Segera hadir".',
    ),
    (
      question: 'Kenapa jawabanku tidak bisa diubah lagi?',
      answer:
          'Setelah menekan Selanjutnya, jawaban soal itu terkunci supaya skor '
          'mencerminkan hasil yang jujur. Jawaban dan pembahasannya bisa dibaca '
          'lagi di halaman hasil maupun di Riwayat.',
    ),
    (
      question: 'Apa arti pengali XP per tingkat?',
      answer:
          'Pemula 1.0×, Menengah 1.5×, dan Ahli 2.0× dari skor jawaban benar. '
          'Level dihitung dari total XP, bukan disimpan terpisah.',
    ),
    (
      question: 'Bagaimana streak dihitung?',
      answer:
          'Streak dihitung dari tanggal main yang berurutan: satu kuis per hari '
          'sudah cukup, dan beberapa kuis di hari yang sama tetap dihitung satu.',
    ),
    (
      question: 'Apakah datanya tersimpan?',
      answer:
          'Ya. Akun, riwayat, XP, pengaturan, dan kuis yang sedang berjalan '
          'disimpan di perangkat, jadi tetap ada setelah aplikasi ditutup.',
    ),
    (
      question: 'Bagaimana cara mengosongkan semua data?',
      answer:
          'Buka Pengaturan, pilih Hapus Semua Data. Tindakan itu menghapus akun, '
          'riwayat, XP, dan kuis tersimpan di perangkat ini.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const TopWash(
            height: 200,
            colors: [Color(0xFF1D1535), AppColors.background],
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-12, 0),
                          child: BackIconButton(
                            label: 'Kembali ke pengaturan',
                            onTap: () => context.go('/pengaturan'),
                          ),
                        ),
                        Text('Bantuan', style: AppTextStyles.titleLarge),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    children: [
                      Text(
                        'Pertanyaan yang sering muncul',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      for (final item in _faq)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Theme(
                              data: Theme.of(context)
                                  .copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                childrenPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  14,
                                ),
                                iconColor: AppColors.gold,
                                collapsedIconColor: AppColors.textMuted,
                                title: Text(
                                  item.question,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      item.answer,
                                      style:
                                          AppTextStyles.bodySmallRelaxedMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Masih butuh bantuan? Sampaikan lewat menu Kontribusi di '
                        'repositori proyek.',
                        style: AppTextStyles.captionRelaxedMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
