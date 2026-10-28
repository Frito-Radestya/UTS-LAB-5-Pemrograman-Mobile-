import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/data/local/quiz_codec.dart';
import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/history/history_controller.dart';
import 'package:kage/features/profile/progress_controller.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/features/settings/settings_controller.dart';
import 'package:kage/models/models.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final settings = context.watch<SettingsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const TopWash(
            height: 220,
            colors: [Color(0xFF1D1535), AppColors.background],
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-12, 0),
                          child: const BackIconButton(
                            label: 'Kembali ke profil',
                          ),
                        ),
                        Text('Pengaturan', style: AppTextStyles.titleLarge),
                      ],
                    ),
                  ),
                ),
                // Scrollable settings body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    center: Alignment(-0.4, -0.5),
                                    colors: [
                                      Color(0xFF3B2A4E),
                                      AppColors.surface,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.gold,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  auth.initial,
                                  style: AppTextStyles.headlineTightGold,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      auth.fullName,
                                      style: AppTextStyles.titleMedium,
                                    ),
                                    Text(
                                      auth.email,
                                      style: AppTextStyles.bodySmallMuted,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _sectionLabel('AKUN'),
                        _group([
                          _tile(
                            Icons.person_outline,
                            'Edit Profil',
                            () => _editProfile(context, auth),
                          ),
                          _tile(
                            Icons.lock_outline,
                            'Ubah Password',
                            () => _changePassword(context, auth),
                          ),
                          _switchTile(
                            icon: Icons.notifications_none,
                            label: 'Notifikasi',
                            subtitle: settings.notifications
                                ? 'Pengingat harian pukul '
                                      '${settings.reminderLabel}'
                                : 'Pengingat belajar dimatikan',
                            value: settings.notifications,
                            onChanged: (value) =>
                                _toggleNotifications(context, settings, value),
                          ),
                          if (settings.notifications)
                            _tile(
                              Icons.schedule,
                              'Jam Pengingat',
                              () => _pickReminderTime(context, settings),
                              trailing: settings.reminderLabel,
                            ),
                          _switchTile(
                            icon: Icons.vibration,
                            label: 'Getaran',
                            subtitle: 'Getaran saat memilih dan menjawab',
                            value: settings.haptics,
                            onChanged: settings.setHaptics,
                          ),
                          _switchTile(
                            icon: Icons.volume_up_outlined,
                            label: 'Suara',
                            subtitle: 'Bunyi umpan balik jawaban',
                            value: settings.sound,
                            onChanged: settings.setSound,
                          ),
                          _switchTile(
                            icon: Icons.timer_outlined,
                            label: 'Timer per soal',
                            subtitle: settings.timerEnabled
                                ? 'Aktif sesuai tingkat kesulitan'
                                : 'Dimatikan',
                            value: settings.timerEnabled,
                            onChanged: settings.setTimerEnabled,
                          ),
                        ]),
                        _sectionLabel('APLIKASI'),
                        _group([
                          _tile(
                            Icons.dark_mode_outlined,
                            'Tema',
                            () => _pickTheme(context, settings),
                            trailing: settings.theme.label,
                          ),
                          _tile(
                            Icons.translate,
                            'Bahasa',
                            () => _pickLanguage(context, settings),
                            trailing: settings.language.label,
                          ),
                          _tile(
                            Icons.help_outline,
                            'Bantuan',
                            () => context.push('/bantuan'),
                          ),
                          _tile(
                            Icons.download_outlined,
                            'Ekspor Riwayat',
                            () => _exportHistory(context),
                          ),
                          _tile(Icons.info_outline, 'Tentang Aplikasi', () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'KAGE',
                              applicationVersion: 'v1.0.0',
                              applicationLegalese: 'The Quiz Sanctuary',
                            );
                          }),
                        ]),
                        _sectionLabel('DATA'),
                        _group([
                          _tile(
                            Icons.delete_outline,
                            'Hapus Semua Data',
                            () => _confirmDeleteAll(context),
                            danger: true,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: 'Logout',
                          onTap: () => _confirmLogout(context, auth),
                        ),
                        const SizedBox(height: 14),
                        Center(
                          child: Text(
                            'KAGE · The Quiz Sanctuary · v1.0.0',
                            style: AppTextStyles.captionMutedSpaced,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
      child: Text(text, style: AppTextStyles.captionMutedWide),
    );
  }

  Widget _group(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, color: AppColors.border),
          ],
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String label,
    VoidCallback onTap, {
    String? trailing,
    bool danger = false,
  }) {
    return KageTappable(
      onTap: onTap,
      semanticLabel: trailing == null ? label : '$label, $trailing',
      excludeChildSemantics: true,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: danger ? AppColors.primaryText : AppColors.gold,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: danger ? AppColors.primaryText : null,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(trailing, style: AppTextStyles.bodySmallMuted),
                const SizedBox(width: 6),
              ],
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Semantics(
      toggled: value,
      label: '$label, ${value ? 'aktif' : 'nonaktif'}, $subtitle',
      excludeSemantics: true,
      child: ConstrainedBox(
        // Tinggi minimum, bukan tetap, agar teks tetap utuh pada skala font
        // sistem yang besar (U-02).
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.gold),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: AppTextStyles.bodyLarge),
                    Text(subtitle, style: AppTextStyles.captionMuted),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.gold,
                activeTrackColor: AppColors.gold.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleNotifications(
    BuildContext context,
    SettingsController settings,
    bool value,
  ) async {
    if (!value) {
      settings.setNotifications(false);
      _snack(context, 'Pengingat harian dimatikan.');
      return;
    }

    // Izin dijelaskan lebih dulu supaya pengguna tahu kenapa diminta (U-08).
    final explained = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
        title: Text('Izinkan notifikasi?', style: AppTextStyles.titleLarge),
        content: Text(
          'KAGE memakai notifikasi untuk mengingatkanmu belajar satu kali '
          'sehari. Kamu bisa mematikannya kapan saja di halaman ini.',
          style: AppTextStyles.bodyRelaxedSoft,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Nanti', style: AppTextStyles.labelMuted),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Lanjutkan', style: AppTextStyles.labelPrimary),
          ),
        ],
      ),
    );
    if (explained != true || !context.mounted) return;

    final granted = await settings.enableNotifications();
    if (!context.mounted) return;
    _snack(
      context,
      granted
          ? 'Pengingat harian aktif pukul ${settings.reminderLabel}.'
          : 'Izin notifikasi ditolak, jadi pengingat belum bisa diaktifkan.',
    );
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    SettingsController settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
      helpText: 'Pilih jam pengingat',
    );
    if (picked == null || !context.mounted) return;
    await settings.setReminderTime(picked.hour, picked.minute);
    if (!context.mounted) return;
    _snack(context, 'Pengingat diatur pukul ${settings.reminderLabel}.');
  }

  Future<void> _pickTheme(
    BuildContext context,
    SettingsController settings,
  ) async {
    final picked = await showDialog<KageTheme>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        backgroundColor: AppColors.surface,
        title: Text('Pilih Tema', style: AppTextStyles.titleLarge),
        children: [
          for (final option in KageTheme.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(option),
              child: Row(
                children: [
                  Icon(
                    option == settings.theme
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: option == settings.theme
                        ? AppColors.gold
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.label, style: AppTextStyles.bodyLarge),
                        Text(
                          option.description,
                          style: AppTextStyles.captionMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked == null || !context.mounted) return;
    settings.setTheme(picked);
  }

  Future<void> _pickLanguage(
    BuildContext context,
    SettingsController settings,
  ) async {
    final picked = await showDialog<AppLanguage>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        backgroundColor: AppColors.surface,
        title: Text('Pilih Bahasa', style: AppTextStyles.titleLarge),
        children: [
          for (final option in AppLanguage.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(option),
              child: Row(
                children: [
                  Icon(
                    option == settings.language
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: option == settings.language
                        ? AppColors.gold
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Text(option.label, style: AppTextStyles.bodyLarge),
                ],
              ),
            ),
        ],
      ),
    );
    if (picked == null || !context.mounted) return;
    settings.setLanguage(picked);
  }

  Future<void> _exportHistory(BuildContext context) async {
    final history = context.read<HistoryController>().history;
    if (history.isEmpty) {
      _snack(context, 'Belum ada riwayat untuk diekspor.');
      return;
    }

    final payload = const JsonEncoder.withIndent('  ')
        .convert([for (final item in history) quizResultToJson(item)]);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
        title: Text('Ekspor Riwayat', style: AppTextStyles.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${history.length} percobaan dalam format JSON:',
                style: AppTextStyles.bodySmallMuted,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(payload, style: AppTextStyles.captionRelaxedMuted),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: payload));
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              _snack(context, 'Riwayat disalin ke papan klip.');
            },
            child: Text('Salin', style: AppTextStyles.labelPrimary),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Tutup', style: AppTextStyles.labelMuted),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(
    BuildContext context,
    AuthController auth,
  ) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    String? error;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.borderStrong),
          ),
          title: Text('Ubah Password', style: AppTextStyles.titleLarge),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: current,
                  hint: 'Password saat ini',
                  icon: Icons.lock_outline,
                  obscure: true,
                  errorText: error,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: next,
                  hint: 'Password baru',
                  icon: Icons.lock_reset,
                  obscure: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: confirm,
                  hint: 'Ulangi password baru',
                  icon: Icons.lock_reset,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Minimal ${AuthController.minPasswordLength} karakter, '
                    'gunakan kombinasi huruf dan angka.',
                    style: AppTextStyles.captionMuted,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('Batal', style: AppTextStyles.labelMuted),
            ),
            TextButton(
              onPressed: () {
                final result = auth.changePassword(
                  currentPassword: current.text,
                  newPassword: next.text,
                  confirmPassword: confirm.text,
                );
                if (result.ok) {
                  Navigator.of(dialogContext).pop(true);
                } else {
                  setDialogState(() => error = result.message);
                }
              },
              child: Text('Simpan', style: AppTextStyles.labelPrimary),
            ),
          ],
        ),
      ),
    );

    current.dispose();
    next.dispose();
    confirm.dispose();

    if (saved == true && context.mounted) {
      _snack(context, 'Password berhasil diubah.');
    }
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final settings = context.read<SettingsController>();
    final history = context.read<HistoryController>();
    final progress = context.read<ProgressController>();
    final quiz = context.read<QuizController>();
    final auth = context.read<AuthController>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
        title: Text('Hapus semua data?', style: AppTextStyles.titleLarge),
        content: Text(
          'Akun, riwayat, XP, pengaturan, dan kuis yang tersimpan akan dihapus '
          'dari perangkat ini dan tidak bisa dikembalikan.',
          style: AppTextStyles.bodyRelaxedSoft,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Batal', style: AppTextStyles.labelMuted),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Hapus', style: AppTextStyles.labelPrimary),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    settings.setNotifications(false);
    quiz.discardProgress();
    history.clear();
    progress.reset();
    auth.deleteAllAccounts();
    if (context.mounted) context.go('/login');
  }

  Future<void> _editProfile(BuildContext context, AuthController auth) async {
    final nameController = TextEditingController(text: auth.fullName);
    final emailController = TextEditingController(text: auth.email);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
        title: Text('Edit Profil', style: AppTextStyles.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                hint: 'Nama Lengkap',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: emailController,
                hint: 'Email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Batal', style: AppTextStyles.labelMuted),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Simpan', style: AppTextStyles.labelPrimary),
          ),
        ],
      ),
    );

    if (saved == true && context.mounted) {
      final result = auth.updateProfile(
        name: nameController.text,
        mail: emailController.text,
      );
      if (!context.mounted) return;
      _snack(
        context,
        result.ok
            ? 'Profil berhasil diperbarui.'
            : (result.message ?? 'Gagal.'),
      );
    }

    nameController.dispose();
    emailController.dispose();
  }

  Future<void> _confirmLogout(BuildContext context, AuthController auth) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
        title: Text('Keluar dari akun?', style: AppTextStyles.titleLarge),
        content: Text(
          'Kamu dapat masuk kembali kapan saja untuk melanjutkan latihan.',
          style: AppTextStyles.bodyRelaxedSoft,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Batal', style: AppTextStyles.labelMuted),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Logout', style: AppTextStyles.labelPrimary),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      auth.logout();
      context.go('/login');
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.surface),
    );
  }
}
