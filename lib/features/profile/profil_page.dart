import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final history = context.watch<HistoryController>();
    final progress = context.watch<ProgressController>();

    return ScreenScaffold(
      navIndex: 3,
      stack: const [
        TopWash(height: 260, colors: [Color(0xFF1D1535), AppColors.background]),
      ],
      child: Column(
        children: [
          // App bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: SizedBox(
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
                  Expanded(
                    child: Text(
                      'Skor & Profil',
                      style: AppTextStyles.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Buka pengaturan',
                    onPressed: () => context.push('/pengaturan'),
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar + name
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            center: Alignment(-0.4, -0.5),
                            colors: [Color(0xFF3B2A4E), AppColors.surface],
                          ),
                          border: Border.all(color: AppColors.gold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.35),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Text(
                          auth.initial,
                          style: AppTextStyles.displayLevel,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.fullName,
                              style: AppTextStyles.headlineSmall,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.gold),
                              ),
                              child: Text(
                                'Level ${progress.level} · Pembelajar',
                                style: AppTextStyles.bodySmallGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // XP bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Menuju Level ${progress.level + 1}',
                              style: AppTextStyles.bodySmallMuted,
                            ),
                            const Spacer(),
                            Text(
                              '${_xp(progress.xp)} / ${_xp(progress.nextLevelXp)} XP',
                              style: AppTextStyles.bodySmallStrongGold,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        KageProgressBar(value: progress.levelProgress),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tabs
                  Row(
                    children: [
                      _tab('Riwayat', true, () {}),
                      _tab('Badge', false, () => context.push('/badge')),
                      _tab('Statistik', false, () => context.go('/riwayat')),
                    ],
                  ),
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  // History list
                  for (final r in history.history.take(4)) ...[
                    ScoreRow(result: r, compact: true),
                    const SizedBox(height: 10),
                  ],
                  KageTappable(
                    onTap: () => context.go('/riwayat'),
                    child: SizedBox(
                      // Area sentuh minimal 48 dp (U-02).
                      height: 48,
                      child: Center(
                        child: Text(
                          'Lihat semua riwayat',
                          style: AppTextStyles.bodyPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool on, VoidCallback tap) {
    return Expanded(
      child: KageTappable(
        onTap: tap,
        selected: on,
        semanticLabel: 'Tab $label${on ? ', aktif' : ''}',
        excludeChildSemantics: true,
        child: Container(
          // Area sentuh minimal 48 dp (U-02).
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: on ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: on ? FontWeight.w600 : FontWeight.w400,
              color: on ? AppColors.primaryText : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  String _xp(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)}.${s.substring(s.length - 3)}';
  }
}
