import 'package:flutter/material.dart';

import 'package:kage/models/models.dart';
import 'package:kage/theme/app_colors.dart';

/// Metadata tampilan kategori.
///
/// Bank soal tidak lagi berada di sini: setiap kategori dibaca dari
/// `assets/data/questions_<kategori>.json` lewat parser di `quiz_bank.dart`.
/// Yang tetap di Dart hanya hal yang tidak bisa dinyatakan sebagai data, yaitu
/// warna dan aset ikon.
const _darkCategories = <QuizCategory>[
  QuizCategory(
    id: CategoryId.sains,
    name: 'Sains',
    shortName: 'Sains',
    description:
        'Jelajahi misteri alam semesta, tubuh manusia, dan fenomena sains lainnya.',
    tags: ['Antariksa', 'Tubuh manusia', 'Energi', 'Lingkungan'],
    color: Color(0xFFF0A25A),
    iconAsset: 'assets/svg/icon_sains.svg',
    gradientInner: Color(0xFF3A2A20),
    gradientOuter: Color(0xFF14121A),
  ),
  QuizCategory(
    id: CategoryId.teknologi,
    name: 'Teknologi',
    shortName: 'Teknologi',
    description:
        'Kenali internet, kecerdasan buatan, keamanan digital, dan inovasi masa kini.',
    tags: ['Internet', 'AI', 'Keamanan digital', 'Inovasi'],
    color: Color(0xFF6EB6FF),
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
    color: Color(0xFFE0B86A),
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
    color: Color(0xFFB79CFF),
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
    color: Color(0xFF6FD0A0),
    iconAsset: 'assets/svg/icon_umum.svg',
    gradientInner: Color(0xFF1C3A33),
    gradientOuter: Color(0xFF0F1A1E),
  ),
];

const _lightCategories = <QuizCategory>[
  QuizCategory(
    id: CategoryId.sains,
    name: 'Sains',
    shortName: 'Sains',
    description:
        'Jelajahi misteri alam semesta, tubuh manusia, dan fenomena sains lainnya.',
    tags: ['Antariksa', 'Tubuh manusia', 'Energi', 'Lingkungan'],
    color: Color(0xFF8C4A0E),
    iconAsset: 'assets/svg/icon_sains.svg',
    gradientInner: Color(0xFFFDF0E2),
    gradientOuter: Color(0xFFF7E4CF),
  ),
  QuizCategory(
    id: CategoryId.teknologi,
    name: 'Teknologi',
    shortName: 'Teknologi',
    description:
        'Kenali internet, kecerdasan buatan, keamanan digital, dan inovasi masa kini.',
    tags: ['Internet', 'AI', 'Keamanan digital', 'Inovasi'],
    color: Color(0xFF1D5699),
    iconAsset: 'assets/svg/icon_teknologi.svg',
    gradientInner: Color(0xFFE6F0FC),
    gradientOuter: Color(0xFFD6E6FA),
  ),
  QuizCategory(
    id: CategoryId.sejarah,
    name: 'Sejarah',
    shortName: 'Sejarah',
    description:
        'Telusuri peradaban, penemuan besar, dan jejak sejarah Indonesia.',
    tags: ['Peradaban', 'Penemuan', 'Sejarah Indonesia'],
    color: Color(0xFF7A5618),
    iconAsset: 'assets/svg/icon_sejarah.svg',
    gradientInner: Color(0xFFFAF1DF),
    gradientOuter: Color(0xFFF3E5C8),
  ),
  QuizCategory(
    id: CategoryId.logika,
    name: 'Logika',
    shortName: 'Logika',
    description:
        'Latih pola angka, deduksi, dan penalaran untuk berpikir lebih tajam.',
    tags: ['Pola angka', 'Deduksi', 'Penalaran'],
    color: Color(0xFF563999),
    iconAsset: 'assets/svg/icon_logika.svg',
    gradientInner: Color(0xFFEEE9FC),
    gradientOuter: Color(0xFFE3DBF8),
  ),
  QuizCategory(
    id: CategoryId.umum,
    name: 'Pengetahuan Umum',
    shortName: 'Umum',
    description:
        'Perluas wawasan geografi, budaya, dan fakta dunia yang menarik.',
    tags: ['Geografi', 'Budaya', 'Fakta dunia'],
    color: Color(0xFF176B45),
    iconAsset: 'assets/svg/icon_umum.svg',
    gradientInner: Color(0xFFE4F5ED),
    gradientOuter: Color(0xFFD3EDE0),
  ),
];

List<QuizCategory> get categories =>
    AppColors.isLight ? _lightCategories : _darkCategories;

QuizCategory categoryById(CategoryId id) =>
    categories.firstWhere((c) => c.id == id);
