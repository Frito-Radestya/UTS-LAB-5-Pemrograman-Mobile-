import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/widgets/kage_bottom_nav.dart';
import 'package:kage/widgets/sakura_petal.dart';

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.child,
    this.navIndex,
    this.stack = const [],
    this.showPetals = true,
  });

  final Widget child;
  final int? navIndex;
  final List<Widget> stack;
  final bool showPetals;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ...stack,
                if (showPetals) const SakuraPetalDrift(),
                SafeArea(bottom: false, child: child),
              ],
            ),
          ),
          if (navIndex != null) KageBottomNav(index: navIndex!),
        ],
      ),
    );
  }
}
