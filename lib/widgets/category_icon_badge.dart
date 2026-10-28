import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:kage/models/models.dart';

class CategoryIconBadge extends StatelessWidget {
  const CategoryIconBadge({
    super.key,
    required this.category,
    this.size = 52,
    this.iconSize = 26,
  });

  final QuizCategory category;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.4, -0.5),
          colors: [category.gradientInner, category.gradientOuter],
        ),
        border: Border.all(color: category.color, width: 1.5),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        category.iconAsset,
        width: iconSize,
        height: iconSize,
      ),
    );
  }
}
