import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';

class TopWash extends StatelessWidget {
  const TopWash({
    super.key,
    this.height = 220,
    this.colors = const [Color(0xFF161433), AppColors.background],
  });

  final double height;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: height,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
        ),
      ),
    );
  }
}
