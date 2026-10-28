import 'package:flutter/material.dart';

class StarField extends StatelessWidget {
  const StarField({super.key, this.height = 360});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _StarPainter()),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
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
    for (final s in stars) {
      canvas.drawCircle(s, 1.1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
