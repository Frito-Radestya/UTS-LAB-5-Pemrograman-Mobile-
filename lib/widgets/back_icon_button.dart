import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/widgets/kage_tappable.dart';

class BackIconButton extends StatelessWidget {
  const BackIconButton({super.key, this.onTap, this.label = 'Kembali'});

  final VoidCallback? onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: KageTappable(
        onTap: onTap ?? () => context.pop(),
        child: const SizedBox(
          // Area sentuh minimal 48x48 dp (U-02).
          width: 48,
          height: 48,
          child: Icon(Icons.chevron_left, size: 28, color: AppColors.text),
        ),
      ),
    );
  }
}
