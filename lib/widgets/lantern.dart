import 'package:flutter/material.dart';

class Lantern extends StatelessWidget {
  const Lantern({super.key, this.opacity = 1});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 2, height: 26, color: const Color(0xFF6B5A3A)),
          Container(
            width: 16,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF2B45A),
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF2B45A).withValues(alpha: 0.5),
                  blurRadius: 28,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated version: sways like a lantern in the wind ───────────────────────
class AnimatedLantern extends StatefulWidget {
  const AnimatedLantern({
    super.key,
    this.opacity = 1,
    this.duration = const Duration(milliseconds: 2200),
    this.maxAngle = 0.18, // radians (~10°)
    this.delayFraction = 0.0,
  });

  final double opacity;
  final Duration duration;
  final double maxAngle;
  final double delayFraction;

  @override
  State<AnimatedLantern> createState() => _AnimatedLanternState();
}

class _AnimatedLanternState extends State<AnimatedLantern>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Animation<double>? _angle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      _ctrl?.dispose();
      _ctrl = null;
      _angle = null;
      return;
    }
    if (_ctrl != null) return;
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..value = widget.delayFraction.clamp(0.0, 1.0);
    _angle = Tween<double>(
      begin: -widget.maxAngle,
      end: widget.maxAngle,
    ).animate(CurvedAnimation(parent: _ctrl!, curve: Curves.easeInOut));
    _ctrl!.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 2, height: 26, color: const Color(0xFF6B5A3A)),
        Container(
          width: 16,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFF2B45A),
            borderRadius: BorderRadius.circular(7),
            boxShadow: const [
              BoxShadow(
                color: Color(0x80F2B45A),
                blurRadius: 28,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );

    return Opacity(
      opacity: widget.opacity,
      child: RepaintBoundary(
        child: reduce || _angle == null
            ? child
            : AnimatedBuilder(
                animation: _angle!,
                builder: (_, child) => Transform(
                  alignment: Alignment.topCenter,
                  transform: Matrix4.rotationZ(_angle!.value),
                  child: child,
                ),
                child: child,
              ),
      ),
    );
  }
}
