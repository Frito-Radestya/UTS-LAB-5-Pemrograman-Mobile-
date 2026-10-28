import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';

class KageProgressBar extends StatelessWidget {
  const KageProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.color = AppColors.primary,
    this.glow = false,
    this.semanticLabel,
  });

  final double value;
  final double height;
  final Color color;
  final bool glow;

  /// Kalimat yang dibacakan pembaca layar, misalnya "Soal 3 dari 10".
  /// Bila kosong, bilah hanya dianggap dekoratif.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final label = semanticLabel;
    if (label != null) {
      return Semantics(
        label: label,
        value: '${(value.clamp(0, 1) * 100).round()}%',
        child: _bar(),
      );
    }
    return _bar();
  }

  Widget _bar() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.borderStrong,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        widthFactor: value.clamp(0, 1),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.8),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
