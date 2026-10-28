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
    Color color = AppColors.text,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: _bodyFont,
      fontSize: size,
      height: heightPx / size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      fontStyle: fontStyle,
    );
  }

  static TextStyle cinzel({
    double size = 40,
    double heightPx = 48,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.gold,
    double letterSpacing = 8,
  }) {
    return TextStyle(
      fontFamily: _displayFont,
      fontSize: size,
      height: heightPx / size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        onPrimary: AppColors.text,
        onSurface: AppColors.text,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: _bodyFont,
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
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
  static final displayScore = AppTheme.onest(
    size: 72,
    heightPx: 80,
    weight: FontWeight.w700,
  );
  static final displayLevel = AppTheme.onest(
    size: 32,
    heightPx: 36,
    weight: FontWeight.w600,
    color: AppColors.gold,
  );
  static final displayLarge = AppTheme.onest(
    size: 28,
    heightPx: 36,
    weight: FontWeight.w700,
  );
  static final displayLargeGold = AppTheme.onest(
    size: 28,
    heightPx: 36,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );
  static final displayMedium = AppTheme.onest(
    size: 26,
    heightPx: 34,
    weight: FontWeight.w700,
  );
  static final displaySmall = AppTheme.onest(
    size: 24,
    heightPx: 32,
    weight: FontWeight.w700,
  );

  // Judul halaman dan bagian.
  static final headlineLarge = AppTheme.onest(
    size: 22,
    heightPx: 32,
    weight: FontWeight.w600,
  );
  static final headline = AppTheme.onest(
    size: 22,
    heightPx: 28,
    weight: FontWeight.w600,
  );
  static final headlineGold = AppTheme.onest(
    size: 22,
    heightPx: 28,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );
  static final headlineTightGold = AppTheme.onest(
    size: 22,
    heightPx: 26,
    weight: FontWeight.w600,
    color: AppColors.gold,
  );
  static final headlineSmall = AppTheme.onest(
    size: 20,
    heightPx: 28,
    weight: FontWeight.w600,
  );
  static final headlineSmallLoose = AppTheme.onest(
    size: 20,
    heightPx: 30,
    weight: FontWeight.w600,
  );
  static final headlineSmallGold = AppTheme.onest(
    size: 20,
    heightPx: 26,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );
  static final titleLarge = AppTheme.onest(
    size: 18,
    heightPx: 26,
    weight: FontWeight.w600,
  );
  static final titleLargeGold = AppTheme.onest(
    size: 18,
    heightPx: 24,
    weight: FontWeight.w700,
    color: AppColors.gold,
  );
  static final titleMedium = AppTheme.onest(
    size: 16,
    heightPx: 24,
    weight: FontWeight.w600,
  );
  static final titleMediumTight = AppTheme.onest(
    size: 16,
    heightPx: 22,
    weight: FontWeight.w600,
  );
  static final titleSmall = AppTheme.onest(
    size: 15,
    heightPx: 22,
    weight: FontWeight.w600,
  );
  static final titleSmallMedium = AppTheme.onest(
    size: 15,
    heightPx: 22,
    weight: FontWeight.w500,
  );
  static final titleSmallCompact = AppTheme.onest(
    size: 15,
    heightPx: 20,
    weight: FontWeight.w600,
  );

  // Teks isi.
  static final bodyLarge = AppTheme.onest(size: 15, heightPx: 22);
  static final bodyLargeMedium = AppTheme.onest(
    size: 15,
    heightPx: 22,
    weight: FontWeight.w500,
  );
  static final bodyLargeStrong = AppTheme.onest(
    size: 15,
    heightPx: 22,
    weight: FontWeight.w600,
  );
  static final bodyLargeQuote = AppTheme.onest(
    size: 15,
    heightPx: 24,
    color: const Color(0xFFD6D2CB),
  );
  static final body = AppTheme.onest(size: 14, heightPx: 20);
  static final bodyMedium = AppTheme.onest(
    size: 14,
    heightPx: 20,
    weight: FontWeight.w500,
  );
  static final bodyStrong = AppTheme.onest(
    size: 14,
    heightPx: 20,
    weight: FontWeight.w600,
  );
  static final bodyMuted = body.copyWith(color: AppColors.textMuted);
  static final bodySoft = body.copyWith(color: AppColors.textSoft);
  static final bodyPrimary = body.copyWith(color: AppColors.primaryText);
  static final bodyGold = body.copyWith(color: AppColors.gold);
  static final bodyQuote = body.copyWith(color: AppColors.textQuote);
  static final bodyGoldWide = bodyGold.copyWith(letterSpacing: 4);
  static final bodyRelaxed = AppTheme.onest(size: 14, heightPx: 21);
  static final bodyRelaxedSoft = bodyRelaxed.copyWith(
    color: AppColors.textSoft,
  );
  static final bodyLooseSoft = AppTheme.onest(
    size: 14,
    heightPx: 22,
    color: AppColors.textSoft,
  );
  static final bodyLooseQuote = AppTheme.onest(
    size: 14,
    heightPx: 22,
    color: AppColors.textQuote,
  );
  static final bodyLooseQuoteItalic = bodyLooseQuote.copyWith(
    fontStyle: FontStyle.italic,
  );

  // Teks kecil dan label.
  static final bodySmall = AppTheme.onest(size: 13, heightPx: 18);
  static final bodySmallMedium = AppTheme.onest(
    size: 13,
    heightPx: 18,
    weight: FontWeight.w500,
  );
  static final bodySmallMediumSoft = bodySmallMedium.copyWith(
    color: AppColors.textSoft,
  );
  static final bodySmallStrong = AppTheme.onest(
    size: 13,
    heightPx: 18,
    weight: FontWeight.w600,
  );
  static final bodySmallMuted = bodySmall.copyWith(color: AppColors.textMuted);
  static final bodySmallPrimary = bodySmall.copyWith(
    color: AppColors.primaryText,
  );
  static final bodySmallGold = bodySmall.copyWith(color: AppColors.gold);
  static final bodySmallStrongGold = bodySmallGold.copyWith(
    fontWeight: FontWeight.w600,
  );
  static final bodySmallGoldSpaced = bodySmallGold.copyWith(letterSpacing: 1);
  static final bodySmallRelaxed = AppTheme.onest(size: 13, heightPx: 19);
  static final bodySmallRelaxedMuted = bodySmallRelaxed.copyWith(
    color: AppColors.textMuted,
  );
  static final label = bodyStrong;
  static final labelGold = bodyStrong.copyWith(color: AppColors.gold);
  static final labelPrimary = bodyStrong.copyWith(color: AppColors.primaryText);
  static final labelMuted = bodyStrong.copyWith(color: AppColors.textMuted);
  static final labelLooseSuccess = AppTheme.onest(
    size: 14,
    heightPx: 24,
    weight: FontWeight.w600,
    color: AppColors.success,
  );
  static final labelRelaxed = AppTheme.onest(size: 13, heightPx: 20);
  static final labelRelaxedMuted = labelRelaxed.copyWith(
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  // Keterangan dan teks terkecil.
  static final caption = AppTheme.onest(size: 12, heightPx: 16);
  static final captionMuted = caption.copyWith(color: AppColors.textMuted);
  static final captionPrimary = caption.copyWith(color: AppColors.primaryText);
  static final captionSuccess = caption.copyWith(color: AppColors.success);
  static final captionMutedSpaced = captionMuted.copyWith(letterSpacing: 0.5);
  static final captionMutedWide = captionMuted.copyWith(letterSpacing: 1);
  static final captionStrong = AppTheme.onest(
    size: 12,
    heightPx: 16,
    weight: FontWeight.w700,
    color: AppColors.background,
  );
  static final captionRelaxedMuted = AppTheme.onest(
    size: 12,
    heightPx: 18,
    color: AppColors.textMuted,
  );
  static final captionRelaxedGold = AppTheme.onest(
    size: 12,
    heightPx: 18,
    color: AppColors.gold,
  );
  static final captionRelaxedSuccess = AppTheme.onest(
    size: 12,
    heightPx: 18,
    color: AppColors.success,
  );
  static final captionLooseSuccess = AppTheme.onest(
    size: 12,
    heightPx: 20,
    color: AppColors.success,
  );
  // Teks terkecil tetap 12 sp agar terbaca pada skala font sistem (U-02).
  static final captionSmall = AppTheme.onest(size: 12, heightPx: 16);
  static final overlineGold = AppTheme.onest(
    size: 12,
    heightPx: 16,
    color: AppColors.gold,
    letterSpacing: 3,
  );

  // Elemen khusus.
  static final answerLetter = AppTheme.onest(
    size: 14,
    heightPx: 18,
    weight: FontWeight.w600,
  );
  static final scoreValue = AppTheme.onest(
    size: 22,
    heightPx: 28,
    weight: FontWeight.w700,
  );
  static final scoreValueCompact = AppTheme.onest(
    size: 20,
    heightPx: 28,
    weight: FontWeight.w700,
  );
  static final brandSmall = AppTheme.cinzel(
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
