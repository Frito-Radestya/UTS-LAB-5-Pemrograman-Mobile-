import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:kage/features/auth/auth_controller.dart';
import 'package:kage/features/auth/validation.dart';
import 'package:kage/theme/app_colors.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool hide = true;
  String? nameError;
  String? emailError;
  String? passwordError;

  /// Salinan isi kolom kata sandi agar aturan bisa ditampilkan langsung saat
  /// pengguna mengetik, bukan setelah menekan Daftar (U-09).
  String _password = '';

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _clearError(String? error, VoidCallback clear) {
    if (error == null) return;
    setState(clear);
  }

  /// Aturan kata sandi dan kekuatannya, ditampilkan sebelum pengguna menekan
  /// tombol Daftar.
  Widget _passwordRules(String value) {
    final strength = passwordStrength(value);
    final rules = <(String, bool)>[
      ('Minimal $minPasswordLength karakter', hasMinLength(value)),
      ('Mengandung huruf', hasLetter(value)),
      ('Mengandung angka', hasDigit(value)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (value.isNotEmpty) ...[
          Row(
            children: [
              Text('Kekuatan: ', style: AppTextStyles.captionMuted),
              Text(
                strength.label,
                style: AppTextStyles.captionMuted.copyWith(
                  color: switch (strength) {
                    PasswordStrength.lemah => AppColors.primaryText,
                    PasswordStrength.sedang => AppColors.gold,
                    PasswordStrength.kuat => AppColors.success,
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          KageProgressBar(
            value: strength.value,
            height: 4,
            color: switch (strength) {
              PasswordStrength.lemah => AppColors.primary,
              PasswordStrength.sedang => AppColors.gold,
              PasswordStrength.kuat => AppColors.success,
            },
            semanticLabel: 'Kekuatan password: ${strength.label}',
          ),
          const SizedBox(height: 8),
        ],
        for (final (label, met) in rules)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  met ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 14,
                  color: met ? AppColors.success : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  '$label${met ? ' ✓' : ''}',
                  style: AppTextStyles.captionMuted,
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _register() {
    FocusScope.of(context).unfocus();

    final result = context.read<AuthController>().register(
      name: name.text,
      email: email.text,
      password: password.text,
    );

    setState(() {
      nameError = result.field == AuthField.name
          ? result.message
          : validateName(name.text);
      emailError = result.field == AuthField.email
          ? result.message
          : validateEmail(email.text);
      passwordError = result.field == AuthField.password
          ? result.message
          : validatePassword(password.text);
    });
    if (nameError != null || emailError != null || passwordError != null) {
      return;
    }
    if (!result.ok) return;

    context.go('/beranda');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Top gradient
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF120F2A),
                    Color(0xFF1D1A3F),
                    AppColors.background,
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
          ),
          // Bottom glow
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: h * 0.36,
            child: const Opacity(
              opacity: 0.7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xFF2A1230), AppColors.background],
                  ),
                ),
              ),
            ),
          ),
          // Torii watermark at bottom
          Positioned(
            left: w * 0.25,
            bottom: h * 0.04,
            child: ToriiArt(width: w * 0.60, height: w * 0.50, opacity: 0.28),
          ),
          // Animated lantern
          Positioned(
            right: w * 0.055,
            bottom: h * 0.15,
            child: const AnimatedLantern(
              opacity: 0.7,
              duration: Duration(milliseconds: 2100),
              delayFraction: 0.2,
            ),
          ),
          // Animated sakura petals
          AnimatedSakuraPetal(
            left: w * 0.76,
            top: h * 0.04,
            width: 12,
            height: 8,
            angle: 50,
            opacity: 0.8,
            duration: const Duration(seconds: 5),
            delayFraction: 0.0,
          ),
          AnimatedSakuraPetal(
            left: w * 0.86,
            top: h * 0.06,
            width: 9,
            height: 6,
            angle: 10,
            opacity: 0.75,
            color: const Color(0xFFF09AB0),
            duration: const Duration(seconds: 6),
            delayFraction: 0.4,
          ),
          AnimatedSakuraPetal(
            left: w * 0.65,
            top: h * 0.08,
            width: 10,
            height: 7,
            angle: -30,
            opacity: 0.7,
            duration: const Duration(seconds: 4),
            delayFraction: 0.7,
          ),
          AnimatedSakuraPetal(
            left: w * 0.10,
            top: h * 0.05,
            width: 10,
            height: 7,
            angle: -30,
            opacity: 0.6,
            duration: const Duration(seconds: 7),
            delayFraction: 0.55,
          ),
          AnimatedSakuraPetal(
            left: w * 0.30,
            top: h * 0.03,
            width: 9,
            height: 6,
            angle: 25,
            opacity: 0.6,
            color: const Color(0xFFF09AB0),
            duration: const Duration(seconds: 5),
            delayFraction: 0.8,
          ),
          // Form
          SafeArea(
            // Latar halaman untuk menutup papan ketik, bukan elemen interaktif,
            // jadi tetap GestureDetector agar tidak masuk urutan fokus Tab.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BackIconButton(label: 'Kembali ke halaman masuk'),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(left: 12, top: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('KAGE', style: AppTextStyles.brandSmall),
                            const SizedBox(height: 14),
                            Text(
                              'Buat Akun',
                              style: AppTextStyles.displayLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Mulai perjalanan pengetahuanmu bersama KAGE.',
                              style: AppTextStyles.bodyMuted,
                            ),
                            const SizedBox(height: 28),
                            // Satu grup agar pengelola kata sandi dapat mengisi
                            // nama, email, dan kata sandi sekaligus (U-09).
                            AutofillGroup(
                              child: Column(
                                children: [
                                  AppTextField(
                                    controller: name,
                                    hint: 'Nama Lengkap',
                                    icon: Icons.person_outline,
                                    errorText: nameError,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.name],
                                    onChanged: (_) => _clearError(
                                      nameError,
                                      () => nameError = null,
                                    ),
                                    onFocusChange: (focused) {
                                      if (!focused) {
                                        setState(() {
                                          nameError = validateName(name.text);
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  AppTextField(
                                    controller: email,
                                    hint: 'Email',
                                    icon: Icons.mail_outline,
                                    errorText: emailError,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [AutofillHints.email],
                                    onChanged: (_) => _clearError(
                                      emailError,
                                      () => emailError = null,
                                    ),
                                    onFocusChange: (focused) {
                                      if (!focused) {
                                        setState(() {
                                          emailError = validateEmail(
                                            email.text,
                                          );
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  AppTextField(
                                    controller: password,
                                    hint: 'Password',
                                    icon: Icons.lock_outline,
                                    obscure: hide,
                                    errorText: passwordError,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.newPassword,
                                    ],
                                    onSubmitted: (_) => _register(),
                                    onChanged: (value) => setState(() {
                                      _password = value;
                                      passwordError = null;
                                    }),
                                    onFocusChange: (focused) {
                                      if (!focused) {
                                        setState(() {
                                          passwordError = validatePassword(
                                            password.text,
                                          );
                                        });
                                      }
                                    },
                                    onToggleObscure: () =>
                                        setState(() => hide = !hide),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _passwordRules(_password),
                            const SizedBox(height: 24),
                            PrimaryButton(label: 'Daftar', onTap: _register),
                            const SizedBox(height: 22),
                            Center(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Sudah punya akun? ',
                                  style: AppTextStyles.bodyMuted,
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: KageTappable(
                                        semanticLabel: 'Masuk ke akun',
                                        excludeChildSemantics: true,
                                        onTap: () => context.go('/login'),
                                        // Area sentuh 48 dp walau teksnya
                                        // sebaris (U-02).
                                        child: SizedBox(
                                          height: 48,
                                          child: Center(
                                            child: Text(
                                              'Masuk',
                                              style: AppTextStyles.labelPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
