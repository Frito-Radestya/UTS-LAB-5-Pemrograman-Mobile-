import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/widgets/kage_bottom_nav.dart';

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.child,
    this.navIndex,
    this.stack = const [],
  });

  final Widget child;
  final int? navIndex;
  final List<Widget> stack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ...stack,
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
