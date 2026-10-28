import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmblemMark extends StatelessWidget {
  const EmblemMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svg/logo_emblem.svg',
      width: size,
      height: size,
    );
  }
}
