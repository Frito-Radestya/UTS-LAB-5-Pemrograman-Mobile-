import 'package:flutter/material.dart';

import 'package:kage/app.dart';
import 'package:kage/app_services.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

/// Menyiapkan layanan aplikasi sambil menampilkan keadaan memuat.
///
/// Pembacaan `shared_preferences` dan Hive membutuhkan waktu sekejap. Layar ini
/// memastikan pengguna melihat indikator yang jelas, dan bila penyimpanan gagal
/// dibuka, ada pesan beserta tombol coba lagi alih-alih aplikasi yang diam di
/// layar kosong (U-07).
class KageBootstrap extends StatefulWidget {
  const KageBootstrap({super.key, this.createServices = AppServices.create});

  /// Cara menyusun layanan; bisa diganti saat pengujian.
  final Future<AppServices> Function() createServices;

  @override
  State<KageBootstrap> createState() => _KageBootstrapState();
}

class _KageBootstrapState extends State<KageBootstrap> {
  AppServices? _services;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final services = await widget.createServices();
      if (!mounted) {
        services.dispose();
        return;
      }
      setState(() => _services = services);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  // Layanan yang sudah diserahkan menjadi milik KageApp, jadi pembuangannya
  // dilakukan di sana. Bila widget ini dibuang sebelum data siap, layanan yang
  // telanjur dibuat dibuang di _load().

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (services != null) return KageApp(services: services);
    // Layar ini dibangun sebelum MaterialApp, jadi Directionality (biasanya
    // disediakan WidgetsApp) harus dipasang di sini agar Scaffold tidak gagal.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: _error == null
          ? const _LoadingScreen()
          : _ErrorScreen(onRetry: _load),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EmblemMark(size: 72),
                const SizedBox(height: 18),
                Text(
                  'KAGE',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineLarge,
                ),
                const SizedBox(height: 6),
                Semantics(
                  label: 'Menyiapkan data',
                  child: const SizedBox(
                    width: 180,
                    child: KageProgressBar(value: 0.55, height: 4, glow: true),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Menyiapkan data…',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmallMuted,
                ),
                const SizedBox(height: 24),
                // Rangka kartu sebagai gambaran konten yang akan muncul.
                const _SkeletonBlock(width: double.infinity, height: 72),
                const SizedBox(height: 12),
                const _SkeletonBlock(width: double.infinity, height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.primaryText,
                  size: 40,
                ),
                const SizedBox(height: 14),
                Text(
                  'Gagal memuat data',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Riwayat dan progres tersimpanmu belum bisa dibuka. '
                  'Coba lagi; bila tetap gagal, buka ulang aplikasi.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmallRelaxedMuted,
                ),
                const SizedBox(height: 18),
                PrimaryButton(label: 'Coba Lagi', onTap: onRetry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
