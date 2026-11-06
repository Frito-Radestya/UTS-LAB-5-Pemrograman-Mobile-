import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const _bodyFont = 'Onest';
  static const _displayFont = 'Cinzel';

  static TextStyle onest({
    double size = 16,
    double heightPx = 24,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: size,
      height: heightPx / size,
      fontWeight: weight,
      color: color ?? AppColors.text,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  static TextStyle cinzel({
    double size = 40,
    double heightPx = 48,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double letterSpacing = 8,
  }) {
    return TextStyle(
      fontFamily: _displayFont,
      fontSize: size,
      height: heightPx / size,
      fontWeight: weight,
      color: color ?? AppColors.gold,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData dark() {
    const bg = Color(0xFF0B0D12);
    const surf = Color(0xFF171A22);
    const txt = Color(0xFFE8E4DD);
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: surf,
        onPrimary: AppColors.onPrimary,
        onSurface: txt,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: _bodyFont,
        bodyColor: txt,
        displayColor: txt,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData light() {
    const bg = Color(0xFFF7F3EB);
    const surf = Color(0xFFFFFFFF);
    const txt = Color(0xFF1C1917);
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        surface: surf,
        onPrimary: AppColors.onPrimary,
        onSurface: txt,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: _bodyFont,
        bodyColor: txt,
        displayColor: txt,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}

/// Gaya teks bernama yang dipakai lintas halaman.
///
/// Semua nilai di sini berasal dari skala tipografi KAGE. Halaman tidak perlu
/// menulis ukuran, tinggi baris, atau warna berulang; variasi warna atau berat
/// huruf yang dinamis cukup memakai [TextStyle.copyWith].
class AppTextStyles {
  AppTextStyles._();

  // Angka dan judul besar.
  static TextStyle get displayScore => AppTheme.onest(
    size: 72,
    heightPx: 80,
    weight: FontWeight.w700,
  );
  static TextStyle get displayLevel => AppTheme.onest(
    size: 32,
    heightPx: 36,
    weight: FontWeight.w600,
    color: AppColors.gold,
  );
  static TextStyle get displayLarge => AppTheme.onest(
    size: 28,
    heightPx: 36,
    weight: FontWeight.w700,
  );
  static TextStyle get displayLargeGold => AppTheme.onest(
    size: 28,
    heightPx: 36,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );
  static TextStyle get displayMedium => AppTheme.onest(
    size: 26,
    heightPx: 34,
    weight: FontWeight.w700,
  );
  static TextStyle get displaySmall => AppTheme.onest(
    size: 24,
    heightPx: 32,
    weight: FontWeight.w700,
  );

  // Judul halaman dan bagian.
  static TextStyle get headlineLarge => AppTheme.onest(
    size: 22,
    heightPx: 32,
    weight: FontWeight.w600,
  );
  static TextStyle get headline => AppTheme.onest(
    size: 22,
    heightPx: 28,
    weight: FontWeight.w600,
  );
  static TextStyle get headlineGold => AppTheme.onest(
    size: 22,
    heightPx: 28,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );
  static TextStyle get headlineTightGold => AppTheme.onest(
    size: 22,
    heightPx: 26,
    weight: FontWeight.w600,
    color: AppColors.gold,
  );
  static TextStyle get headlineSmall => AppTheme.onest(
    size: 20,
    heightPx: 28,
    weight: FontWeight.w600,
  );
  static TextStyle get headlineSmallLoose => AppTheme.onest(
    size: 20,
    heightPx: 30,
    weight: FontWeight.w600,
  );
  static TextStyle get headlineSmallGold => AppTheme.onest(
    size: 20,
    heightPx: 26,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );
  static TextStyle get titleLarge => AppTheme.onest(
    size: 18,
    heightPx: 26,
    weight: FontWeight.w600,
  );
  static TextStyle get titleLargeGold => AppTheme.onest(
    size: 18,
    heightPx: 24,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );
  static TextStyle get titleMedium => AppTheme.onest(
    size: 16,
    heightPx: 24,
    weight: FontWeight.w600,
  );
  static TextStyle get titleMediumTight => AppTheme.onest(
    size: 16,
    heightPx: 22,
    weight: FontWeight.w600,
  );
  static TextStyle get titleSmall => AppTheme.onest(
    size: 15,
    heightPx: 22,
    weight: FontWeight.w600,
  );
  static TextStyle get titleSmallMedium => AppTheme.onest(
    size: 15,
    heightPx: 22,
    weight: FontWeight.w500,
  );
  static TextStyle get titleSmallCompact => AppTheme.onest(
    size: 15,
    heightPx: 20,
    weight: FontWeight.w600,
  );

  // Teks isi.
  static TextStyle get bodyLarge => AppTheme.onest(size: 15, heightPx: 22);
  static TextStyle get bodyLargeMedium => AppTheme.onest(
    size: 15,
    heightPx: 22,
    weight: FontWeight.w500,
  );
  static TextStyle get bodyLargeStrong => AppTheme.onest(
    size: 15,
    heightPx: 22,
    weight: FontWeight.w600,
  );
  static TextStyle get bodyLargeQuote => AppTheme.onest(
    size: 15,
    heightPx: 24,
    color: AppColors.textQuote,
  );
  static TextStyle get body => AppTheme.onest(size: 14, heightPx: 20);
  static TextStyle get bodyMedium => AppTheme.onest(
    size: 14,
    heightPx: 20,
    weight: FontWeight.w500,
  );
  static TextStyle get bodyStrong => AppTheme.onest(
    size: 14,
    heightPx: 20,
    weight: FontWeight.w600,
  );
  static TextStyle get bodyMuted => body.copyWith(color: AppColors.textMuted);
  static TextStyle get bodySoft => body.copyWith(color: AppColors.textSoft);
  static TextStyle get bodyPrimary => body.copyWith(color: AppColors.primaryText);
  static TextStyle get bodyGold => body.copyWith(color: AppColors.gold);
  static TextStyle get bodyQuote => body.copyWith(color: AppColors.textQuote);
  static TextStyle get bodyGoldWide => bodyGold.copyWith(letterSpacing: 4);
  static TextStyle get bodyRelaxed => AppTheme.onest(size: 14, heightPx: 21);
  static TextStyle get bodyRelaxedSoft => bodyRelaxed.copyWith(
    color: AppColors.textSoft,
  );
  static TextStyle get bodyLooseSoft => AppTheme.onest(
    size: 14,
    heightPx: 22,
    color: AppColors.textSoft,
  );
  static TextStyle get bodyLooseQuote => AppTheme.onest(
    size: 14,
    heightPx: 22,
    color: AppColors.textQuote,
  );
  static TextStyle get bodyLooseQuoteItalic => bodyLooseQuote.copyWith(
    fontStyle: FontStyle.italic,
  );

  // Teks kecil dan label.
  static TextStyle get bodySmall => AppTheme.onest(size: 13, heightPx: 18);
  static TextStyle get bodySmallMedium => AppTheme.onest(
    size: 13,
    heightPx: 18,
    weight: FontWeight.w500,
  );
  static TextStyle get bodySmallMediumSoft => bodySmallMedium.copyWith(
    color: AppColors.textSoft,
  );
  static TextStyle get bodySmallStrong => AppTheme.onest(
    size: 13,
    heightPx: 18,
    weight: FontWeight.w600,
  );
  static TextStyle get bodySmallMuted => bodySmall.copyWith(color: AppColors.textMuted);
  static TextStyle get bodySmallPrimary => bodySmall.copyWith(
    color: AppColors.primaryText,
  );
  static TextStyle get bodySmallGold => bodySmall.copyWith(color: AppColors.gold);
  static TextStyle get bodySmallStrongGold => bodySmallGold.copyWith(
    fontWeight: FontWeight.w600,
  );
  static TextStyle get bodySmallGoldSpaced => bodySmallGold.copyWith(letterSpacing: 1);
  static TextStyle get bodySmallRelaxed => AppTheme.onest(size: 13, heightPx: 19);
  static TextStyle get bodySmallRelaxedMuted => bodySmallRelaxed.copyWith(
    color: AppColors.textMuted,
  );
  static TextStyle get label => bodyStrong;
  static TextStyle get labelGold => bodyStrong.copyWith(color: AppColors.gold);
  static TextStyle get labelPrimary => bodyStrong.copyWith(color: AppColors.primaryText);
  static TextStyle get labelMuted => bodyStrong.copyWith(color: AppColors.textMuted);
  static TextStyle get labelLooseSuccess => AppTheme.onest(
    size: 14,
    heightPx: 24,
    weight: FontWeight.w600,
    color: AppColors.success,
  );
  static TextStyle get labelRelaxed => AppTheme.onest(size: 13, heightPx: 20);
  static TextStyle get labelRelaxedMuted => labelRelaxed.copyWith(
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  // Keterangan dan teks terkecil.
  static TextStyle get caption => AppTheme.onest(size: 12, heightPx: 16);
  static TextStyle get captionMuted => caption.copyWith(color: AppColors.textMuted);
  static TextStyle get captionPrimary => caption.copyWith(color: AppColors.primaryText);
  static TextStyle get captionSuccess => caption.copyWith(color: AppColors.success);
  static TextStyle get captionMutedSpaced => captionMuted.copyWith(letterSpacing: 0.5);
  static TextStyle get captionMutedWide => captionMuted.copyWith(letterSpacing: 1);
  static TextStyle get captionStrong => AppTheme.onest(
    size: 12,
    heightPx: 16,
    weight: FontWeight.w700,
    color: AppColors.background,
  );
  static TextStyle get captionRelaxedMuted => AppTheme.onest(
    size: 12,
    heightPx: 18,
    color: AppColors.textMuted,
  );
  static TextStyle get captionRelaxedGold => AppTheme.onest(
    size: 12,
    heightPx: 18,
    color: AppColors.gold,
  );
  static TextStyle get captionRelaxedSuccess => AppTheme.onest(
    size: 12,
    heightPx: 18,
    color: AppColors.success,
  );
  static TextStyle get captionLooseSuccess => AppTheme.onest(
    size: 12,
    heightPx: 20,
    color: AppColors.success,
  );
  // Teks terkecil tetap 12 sp agar terbaca pada skala font sistem (U-02).
  static TextStyle get captionSmall => AppTheme.onest(size: 12, heightPx: 16);
  static TextStyle get overlineGold => AppTheme.onest(
    size: 12,
    heightPx: 16,
    color: AppColors.gold,
    letterSpacing: 3,
  );

  // Elemen khusus.
  static TextStyle get answerLetter => AppTheme.onest(
    size: 14,
    heightPx: 18,
    weight: FontWeight.w600,
  );
  static TextStyle get scoreValue => AppTheme.onest(
    size: 22,
    heightPx: 28,
    weight: FontWeight.w700,
  );
  static TextStyle get scoreValueCompact => AppTheme.onest(
    size: 20,
    heightPx: 28,
    weight: FontWeight.w700,
  );
  static TextStyle get brandSmall => AppTheme.cinzel(
    size: 18,
    heightPx: 24,
    weight: FontWeight.w600,
    color: AppColors.gold,
    letterSpacing: 6,
  );

  /// Inisial avatar dengan ukuran yang mengikuti lingkarannya.
  static TextStyle avatarInitial(double size) {
    return AppTheme.onest(
      size: size,
      heightPx: size + 4,
      weight: FontWeight.w600,
      color: AppColors.gold,
    );
  }

  /// Wordmark KAGE yang dapat diskalakan.
  static TextStyle wordmark({
    required double size,
    required double heightPx,
    required double letterSpacing,
    required Color color,
  }) {
    return AppTheme.cinzel(
      size: size,
      heightPx: heightPx,
      letterSpacing: letterSpacing,
      color: color,
    );
  }
}
