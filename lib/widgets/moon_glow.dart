import 'package:flutter/material.dart';

class MoonGlow extends StatelessWidget {
  const MoonGlow({super.key, required this.size, this.glow = 30});

  final double size;
  final double glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [Color(0xFFFFFBE8), Color(0xFFDCD6C4), Color(0xFF9AA3BD)],
          stops: [0, 0.62, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC8D2FF).withValues(alpha: 0.32),
            blurRadius: glow,
            spreadRadius: glow * 0.28,
          ),
        ],
      ),
    );
  }
}
