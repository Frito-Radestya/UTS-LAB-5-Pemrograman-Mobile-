import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/widgets/kage_tappable.dart';
import 'package:kage/theme/app_theme.dart';

class KageBottomNav extends StatelessWidget {
  const KageBottomNav({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.paddingOf(context).bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _item(context, 0, Icons.home_outlined, 'Beranda', '/beranda'),
          _item(context, 1, Icons.assignment_outlined, 'Kuis', '/kategori'),
          _item(context, 2, Icons.bar_chart_rounded, 'Skor', '/riwayat'),
          _item(context, 3, Icons.person_outline, 'Profil', '/profil'),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int i,
    IconData icon,
    String label,
    String path,
  ) {
    final active = index == i;
    return Expanded(
      child: KageTappable(
        onTap: () => context.go(path),
        selected: active,
        semanticLabel: '$label, tab ${i + 1} dari 4${active ? ', aktif' : ''}',
        excludeChildSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: active ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: active ? AppColors.primaryText : AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: active ? AppColors.primaryText : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
