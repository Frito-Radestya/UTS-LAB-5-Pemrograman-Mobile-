import 'package:flutter/material.dart';

class MountainClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path()
      ..moveTo(0, size.height * 0.70)
      ..lineTo(size.width * 0.12, size.height * 0.45)
      ..lineTo(size.width * 0.24, size.height * 0.62)
      ..lineTo(size.width * 0.38, size.height * 0.30)
      ..lineTo(size.width * 0.52, size.height * 0.58)
      ..lineTo(size.width * 0.66, size.height * 0.38)
      ..lineTo(size.width * 0.80, size.height * 0.60)
      ..lineTo(size.width * 0.92, size.height * 0.42)
      ..lineTo(size.width, size.height * 0.58)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class PathClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * 0.42, 0)
      ..lineTo(size.width * 0.58, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
