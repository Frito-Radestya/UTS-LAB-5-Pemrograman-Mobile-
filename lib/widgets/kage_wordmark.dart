import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';

class KageWordmark extends StatelessWidget {
  const KageWordmark({
    super.key,
    this.size = 40,
    this.heightPx = 48,
    this.letterSpacing = 8,
    this.paddingLeft = 8,
  });

  final double size;
  final double heightPx;
  final double letterSpacing;
  final double paddingLeft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: paddingLeft),
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.goldLight, AppColors.gold],
        ).createShader(bounds),
        child: Text(
          'KAGE',
          style: AppTextStyles.wordmark(
            size: size,
            heightPx: heightPx,
            letterSpacing: letterSpacing,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
