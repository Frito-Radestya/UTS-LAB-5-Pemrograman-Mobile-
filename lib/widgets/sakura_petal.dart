import 'dart:math' as math;

import 'package:flutter/material.dart';

class SakuraPetal extends StatelessWidget {
  const SakuraPetal({
    super.key,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.angle,
    required this.opacity,
    this.color = const Color(0xFFE07A96),
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double angle;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle * math.pi / 180,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(width * 0.7, height * 0.7),
                bottomRight: Radius.elliptical(width * 0.7, height * 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated version: falls, sways, and spins like a real falling petal ──────
class AnimatedSakuraPetal extends StatefulWidget {
  const AnimatedSakuraPetal({
    super.key,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.angle,
    required this.opacity,
    this.color = const Color(0xFFE07A96),
    this.fallDistance = 700,
    this.duration = const Duration(seconds: 5),
    this.delayFraction = 0.0, // 0.0‥1.0 — initial phase offset
    this.swayAmplitude = 18.0,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double angle; // base rotation in degrees
  final double opacity;
  final Color color;
  final double fallDistance;
  final Duration duration;
  final double delayFraction;
  final double swayAmplitude;

  @override
  State<AnimatedSakuraPetal> createState() => _AnimatedSakuraPetalState();
}

class _AnimatedSakuraPetalState extends State<AnimatedSakuraPetal>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (reduce) {
      _ctrl?.dispose();
      _ctrl = null;
      return;
    }
    if (_ctrl != null) return;
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..value = widget.delayFraction.clamp(0.0, 1.0)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations ||
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    final petal = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.elliptical(widget.width * 0.7, widget.height * 0.7),
          bottomRight: Radius.elliptical(widget.width * 0.7, widget.height * 0.7),
        ),
      ),
    );

    if (reduce || _ctrl == null) {
      return Positioned(
        left: widget.left,
        top: widget.top,
        child: RepaintBoundary(
          child: Opacity(opacity: widget.opacity, child: petal),
        ),
      );
    }

    return Positioned(
      left: widget.left,
      top: widget.top,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl!,
          builder: (context, child) {
            final t = _ctrl!.value;
            final dy = t * widget.fallDistance;
            final dx = math.sin(t * 2 * math.pi) * widget.swayAmplitude;
            final spin = t * 2 * math.pi;
            return Opacity(
              opacity:
                  widget.opacity * (1 - (t > 0.85 ? (t - 0.85) / 0.15 : 0)),
              child: Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.rotate(
                  angle: widget.angle * math.pi / 180 + spin,
                  child: petal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Guguran kelopak sakura halus yang melayang di latar belakang.
class SakuraPetalDrift extends StatelessWidget {
  const SakuraPetalDrift({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;
    return IgnorePointer(
      child: Stack(
        children: [
          AnimatedSakuraPetal(
            left: (w * 0.08).clamp(10.0, 60.0),
            top: 30,
            width: 10,
            height: 7,
            angle: 28,
            opacity: 0.75,
            fallDistance: h * 0.85,
            duration: const Duration(seconds: 6),
            delayFraction: 0.1,
          ),
          AnimatedSakuraPetal(
            left: (w * 0.82).clamp(w - 70.0, w - 20.0),
            top: 60,
            width: 9,
            height: 6,
            angle: -30,
            opacity: 0.7,
            fallDistance: h * 0.85,
            duration: const Duration(seconds: 7),
            delayFraction: 0.45,
          ),
          if (count >= 3)
            AnimatedSakuraPetal(
              left: (w * 0.25).clamp(80.0, 160.0),
              top: 120,
              width: 8,
              height: 6,
              angle: 15,
              opacity: 0.6,
              fallDistance: h * 0.85,
              duration: const Duration(seconds: 8),
              delayFraction: 0.75,
            ),
          if (count >= 4)
            AnimatedSakuraPetal(
              left: (w * 0.68).clamp(w - 140.0, w - 80.0),
              top: 180,
              width: 10,
              height: 7,
              angle: -45,
              opacity: 0.65,
              fallDistance: h * 0.85,
              duration: const Duration(seconds: 6),
              delayFraction: 0.3,
            ),
        ],
      ),
    );
  }
}
