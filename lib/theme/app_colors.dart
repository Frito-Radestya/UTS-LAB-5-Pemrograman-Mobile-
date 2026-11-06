import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isLight = false;

  static const primary = Color(0xFFB9232C);
  static const onPrimary = Color(0xFFFDFBF7);

  static Color get primaryText =>
      isLight ? const Color(0xFFA31621) : const Color(0xFFE4545C);
  static Color get background =>
      isLight ? const Color(0xFFF7F3EB) : const Color(0xFF0B0D12);
  static Color get surface =>
      isLight ? const Color(0xFFFFFFFF) : const Color(0xFF171A22);
  static Color get border =>
      isLight ? const Color(0xFFDDD6C6) : const Color(0xFF232734);
  static Color get borderStrong =>
      isLight ? const Color(0xFFCFC8B8) : const Color(0xFF2A2F3C);
  static Color get outline =>
      isLight ? const Color(0xFF9C9382) : const Color(0xFF4A4F5E);
  static Color get gold =>
      isLight ? const Color(0xFF7A5618) : const Color(0xFFC9A56A);
  static Color get goldLight =>
      isLight ? const Color(0xFF5C4010) : const Color(0xFFF3E3C0);
  static Color get text =>
      isLight ? const Color(0xFF1C1917) : const Color(0xFFE8E4DD);
  static Color get textMuted =>
      isLight ? const Color(0xFF5C554C) : const Color(0xFF8B909C);
  static Color get textSoft =>
      isLight ? const Color(0xFF3F3A34) : const Color(0xFFB4B8C2);
  static Color get textQuote =>
      isLight ? const Color(0xFF4A443D) : const Color(0xFFC9C5BE);
  static Color get success =>
      isLight ? const Color(0xFF176B45) : const Color(0xFF6FD0A0);
  static Color get successBorder =>
      isLight ? const Color(0xFF2E8F65) : const Color(0xFF3FA877);
  static Color get successFill =>
      isLight ? const Color(0xFF176B45) : const Color(0xFF2E8F65);
  static Color get navBar =>
      isLight ? const Color(0xFFEFEAE0) : const Color(0xFF0F1218);
  static Color get mutedIcon =>
      isLight ? const Color(0xFF756E63) : const Color(0xFF777C88);

  static Color get sains =>
      isLight ? const Color(0xFF8C4A0E) : const Color(0xFFF0A25A);
  static Color get teknologi =>
      isLight ? const Color(0xFF1D5699) : const Color(0xFF6EB6FF);
  static Color get sejarah =>
      isLight ? const Color(0xFF7A5618) : const Color(0xFFE0B86A);
  static Color get logika =>
      isLight ? const Color(0xFF563999) : const Color(0xFFB79CFF);
  static Color get umum =>
      isLight ? const Color(0xFF176B45) : const Color(0xFF6FD0A0);

  // Helper warna & gradasi lintas tema
  static List<Color> get topWashColors => isLight
      ? [const Color(0xFFE8DFC8), background]
      : [const Color(0xFF161433), background];

  static List<Color> get heroSkyColors => isLight
      ? [
          const Color(0xFFE5DAC0),
          const Color(0xFFEFE8D6),
          const Color(0xFFF4EFE2),
          background,
        ]
      : [
          const Color(0xFF070B1E),
          const Color(0xFF141A45),
          const Color(0xFF2B1D4A),
          background,
        ];

  static List<Color> get resumeBannerColors => isLight
      ? [
          const Color(0xFFF3EBDC),
          const Color(0xFFF6E6DF),
          const Color(0xFFEBE4D4),
        ]
      : [
          const Color(0xFF1A1440),
          const Color(0xFF2D1534),
          const Color(0xFF0F1A2A),
        ];

  static List<Color> get avatarGradientColors => isLight
      ? [const Color(0xFFE8DAC8), surface]
      : [const Color(0xFF3B2A4E), surface];

  static Color get emblemFill =>
      isLight ? const Color(0xFFF5EBE6) : const Color(0xFF1A0E12);

  static Color get lockedBadgeSurface =>
      isLight ? const Color(0xFFEDE8DC) : const Color(0xFF13151B);

  static Color get outerFrameBackground =>
      isLight ? const Color(0xFFEDE8DE) : const Color(0xFF05070C);
}
