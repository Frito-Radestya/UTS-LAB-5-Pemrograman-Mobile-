import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Stack(
            children: [
              // Background gradient
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF070B1E),
                        Color(0xFF141A45),
                        Color(0xFF2B1D4A),
                        Color(0xFF14122A),
                        AppColors.background,
                      ],
                      stops: [0, 0.36, 0.58, 0.78, 1],
                    ),
                  ),
                ),
              ),
              StarField(height: h),
              // Moon
              Positioned(
                top: h * 0.08,
                right: w * 0.14,
                child: const MoonGlow(size: 60, glow: 44),
              ),
              // Mountain
              Positioned(
                left: 0,
                right: 0,
                top: h * 0.38,
                height: h * 0.25,
                child: ClipPath(
                  clipper: MountainClipper(),
                  child: const ColoredBox(color: Color(0xE60C1030)),
                ),
              ),
              // Path wedge
              Positioned(
                left: 0,
                right: 0,
                top: h * 0.58,
                height: h * 0.42,
                child: ClipPath(
                  clipper: PathClipper(),
                  child: const Opacity(
                    opacity: 0.55,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF2A2742), AppColors.background],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Torii
              Positioned(
                left: w * 0.18,
                top: h * 0.20,
                child: ToriiArt(width: w * 0.63, height: w * 0.53),
              ),
              // Animated lanterns
              Positioned(
                left: w * 0.13,
                top: h * 0.375,
                child: const AnimatedLantern(
                  duration: Duration(milliseconds: 2000),
                ),
              ),
              Positioned(
                right: w * 0.13,
                top: h * 0.375,
                child: const AnimatedLantern(
                  duration: Duration(milliseconds: 2400),
                  delayFraction: 0.5,
                ),
              ),
              // Animated sakura petals – varied speeds & delays
              AnimatedSakuraPetal(
                left: w * 0.10,
                top: h * 0.08,
                width: 11,
                height: 8,
                angle: 30,
                opacity: 0.85,
                fallDistance: h,
                duration: const Duration(seconds: 5),
                delayFraction: 0.0,
              ),
              AnimatedSakuraPetal(
                left: w * 0.23,
                top: h * 0.05,
                width: 9,
                height: 6,
                angle: -20,
                opacity: 0.8,
                color: const Color(0xFFF09AB0),
                fallDistance: h,
                duration: const Duration(seconds: 6),
                delayFraction: 0.3,
              ),
              AnimatedSakuraPetal(
                left: w * 0.72,
                top: h * 0.04,
                width: 12,
                height: 8,
                angle: 60,
                opacity: 0.85,
                fallDistance: h,
                duration: const Duration(seconds: 4),
                delayFraction: 0.6,
              ),
              AnimatedSakuraPetal(
                left: w * 0.86,
                top: h * 0.06,
                width: 9,
                height: 6,
                angle: 10,
                opacity: 0.8,
                color: const Color(0xFFF09AB0),
                fallDistance: h,
                duration: const Duration(seconds: 7),
                delayFraction: 0.15,
              ),
              AnimatedSakuraPetal(
                left: w * 0.05,
                top: h * 0.10,
                width: 10,
                height: 7,
                angle: -50,
                opacity: 0.7,
                fallDistance: h,
                duration: const Duration(seconds: 5),
                delayFraction: 0.45,
              ),
              AnimatedSakuraPetal(
                left: w * 0.55,
                top: h * 0.03,
                width: 8,
                height: 6,
                angle: 70,
                opacity: 0.75,
                color: const Color(0xFFF09AB0),
                fallDistance: h,
                duration: const Duration(seconds: 6),
                delayFraction: 0.7,
              ),
              AnimatedSakuraPetal(
                left: w * 0.40,
                top: h * 0.07,
                width: 9,
                height: 6,
                angle: -35,
                opacity: 0.75,
                fallDistance: h,
                duration: const Duration(seconds: 8),
                delayFraction: 0.85,
              ),
              AnimatedSakuraPetal(
                left: w * 0.63,
                top: h * 0.09,
                width: 11,
                height: 7,
                angle: 25,
                opacity: 0.7,
                color: const Color(0xFFF09AB0),
                fallDistance: h,
                duration: const Duration(seconds: 5),
                delayFraction: 0.55,
              ),
              // Logo block
              Positioned(
                left: 0,
                right: 0,
                top: h * 0.52,
                child: KageTappable(
                  onTap: () => context.go('/login'),
                  child: Column(
                    children: [
                      const KageWordmark(
                        size: 76,
                        heightPx: 84,
                        letterSpacing: 12,
                        paddingLeft: 12,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'THE QUIZ SANCTUARY',
                        style: AppTextStyles.bodyGoldWide,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 1,
                            color: AppColors.gold.withValues(alpha: 0.6),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('知の道', style: AppTextStyles.bodyGold),
                          ),
                          Container(
                            width: 48,
                            height: 1,
                            color: AppColors.gold.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Sub-tagline
              Positioned(
                left: w * 0.10,
                right: w * 0.10,
                top: h * 0.73,
                child: Text(
                  'Kuis bukan sekadar permainan, tapi perjalanan untuk menjadi versi terbaik dari dirimu.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyRelaxed,
                ),
              ),
              // Loading bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 64,
                child: Center(
                  child: Semantics(
                    label: 'Memuat aplikasi',
                    child: SizedBox(
                      width: 160,
                      child: KageProgressBar(
                        value: 0.15 + _c.value * 0.85,
                        height: 4,
                        glow: true,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
