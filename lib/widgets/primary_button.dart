import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              color: enabled ? AppColors.primary : AppColors.borderStrong,
              borderRadius: BorderRadius.circular(12),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(
                  color: enabled ? AppColors.text : AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
