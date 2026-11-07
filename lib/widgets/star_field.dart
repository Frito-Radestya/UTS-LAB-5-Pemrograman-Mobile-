import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';

class StarField extends StatelessWidget {
  const StarField({super.key, this.height = 360});

  final double height;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _StarPainter(isLight: AppColors.isLight)),
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter({required this.isLight});

  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isLight ? const Color(0x4D7A5618) : Colors.white;
    const stars = [
      Offset(30, 60),
      Offset(90, 130),
      Offset(150, 40),
      Offset(220, 100),
      Offset(310, 150),
      Offset(350, 220),
      Offset(60, 250),
      Offset(80, 160),
      Offset(330, 60),
      Offset(300, 190),
    ];
    final scaleX = size.width > 390 ? size.width / 390.0 : 1.0;
    for (final s in stars) {
      canvas.drawCircle(Offset(s.dx * scaleX, s.dy), 1.1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.isLight != isLight;
}
