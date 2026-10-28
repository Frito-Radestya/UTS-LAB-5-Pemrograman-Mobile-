import 'package:flutter/material.dart';

import 'package:kage/models/models.dart';
import 'package:kage/theme/app_colors.dart';

/// Metadata tampilan kategori.
///
/// Bank soal tidak lagi berada di sini: setiap kategori dibaca dari
/// `assets/data/questions_<kategori>.json` lewat parser di `quiz_bank.dart`.
/// Yang tetap di Dart hanya hal yang tidak bisa dinyatakan sebagai data, yaitu
/// warna dan aset ikon.
const categories = <QuizCategory>[
  QuizCategory(
    id: CategoryId.sains,
    name: 'Sains',
    shortName: 'Sains',
    description: 'Jelajahi misteri alam semesta, tubuh manusia, dan fenomena sains lainnya.',
    tags: ['Antariksa', 'Tubuh manusia', 'Energi', 'Lingkungan'],
    color: AppColors.sains,
    iconAsset: 'assets/svg/icon_sains.svg',
    gradientInner: Color(0xFF3A2A20),
    gradientOuter: Color(0xFF14121A),
  ),
  QuizCategory(
    id: CategoryId.teknologi,
    name: 'Teknologi',
    shortName: 'Teknologi',
    description: 'Kenali internet, kecerdasan buatan, keamanan digital, dan inovasi masa kini.',
    tags: ['Internet', 'AI', 'Keamanan digital', 'Inovasi'],
    color: AppColors.teknologi,
    iconAsset: 'assets/svg/icon_teknologi.svg',
    gradientInner: Color(0xFF1F3358),
    gradientOuter: Color(0xFF10162B),
  ),
  QuizCategory(
    id: CategoryId.sejarah,
    name: 'Sejarah',
    shortName: 'Sejarah',
    description:
        'Telusuri peradaban, penemuan besar, dan jejak sejarah Indonesia.',
    tags: ['Peradaban', 'Penemuan', 'Sejarah Indonesia'],
    color: AppColors.sejarah,
    iconAsset: 'assets/svg/icon_sejarah.svg',
    gradientInner: Color(0xFF3A3020),
    gradientOuter: Color(0xFF14121A),
  ),
  QuizCategory(
    id: CategoryId.logika,
    name: 'Logika',
    shortName: 'Logika',
    description:
        'Latih pola angka, deduksi, dan penalaran untuk berpikir lebih tajam.',
    tags: ['Pola angka', 'Deduksi', 'Penalaran'],
    color: AppColors.logika,
    iconAsset: 'assets/svg/icon_logika.svg',
    gradientInner: Color(0xFF2D2650),
    gradientOuter: Color(0xFF10102A),
  ),
  QuizCategory(
    id: CategoryId.umum,
    name: 'Pengetahuan Umum',
    shortName: 'Umum',
    description:
        'Perluas wawasan geografi, budaya, dan fakta dunia yang menarik.',
    tags: ['Geografi', 'Budaya', 'Fakta dunia'],
    color: AppColors.umum,
    iconAsset: 'assets/svg/icon_umum.svg',
    gradientInner: Color(0xFF1C3A33),
    gradientOuter: Color(0xFF0F1A1E),
  ),
];

QuizCategory categoryById(CategoryId id) =>
    categories.firstWhere((c) => c.id == id);
