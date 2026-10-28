import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';

class OutlineButton extends StatelessWidget {
  const OutlineButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onTap;
  final double? width;
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
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled ? AppColors.outline : AppColors.borderStrong,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.bodyLargeMedium.copyWith(
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
