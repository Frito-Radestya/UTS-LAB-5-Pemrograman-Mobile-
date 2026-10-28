import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ToriiArt extends StatelessWidget {
  const ToriiArt({
    super.key,
    this.width = 240,
    this.height = 200,
    this.opacity = 1,
  });

  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: SvgPicture.asset(
        'assets/svg/torii.svg',
        width: width,
        height: height,
      ),
    );
  }
}
