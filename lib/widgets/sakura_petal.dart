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
    final reduce = MediaQuery.of(context).disableAnimations;
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
    final reduce = MediaQuery.of(context).disableAnimations;
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
