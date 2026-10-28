/// Aturan isian akun yang dipakai bersama oleh `AuthController` dan formulir
/// login/registrasi, sehingga pesan validasi tidak ditulis dua kali (U-09).
library;

/// Panjang minimum kata sandi.
const int minPasswordLength = 8;

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

bool hasMinLength(String password) => password.length >= minPasswordLength;

bool hasLetter(String password) => RegExp(r'[A-Za-z]').hasMatch(password);

bool hasDigit(String password) => RegExp(r'[0-9]').hasMatch(password);

/// Perkiraan kekuatan kata sandi untuk ditampilkan sebelum pendaftaran.
enum PasswordStrength { lemah, sedang, kuat }

extension PasswordStrengthX on PasswordStrength {
  String get label => switch (this) {
    PasswordStrength.lemah => 'Lemah',
    PasswordStrength.sedang => 'Sedang',
    PasswordStrength.kuat => 'Kuat',
  };

  /// Nilai 0..1 untuk bilah kekuatan.
  double get value => switch (this) {
    PasswordStrength.lemah => 0.34,
    PasswordStrength.sedang => 0.67,
    PasswordStrength.kuat => 1,
  };
}

PasswordStrength passwordStrength(String password) {
  if (!hasMinLength(password) || password.isEmpty) {
    return PasswordStrength.lemah;
  }
  var points = 0;
  if (hasLetter(password)) points++;
  if (hasDigit(password)) points++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) points++;
  if (password.length >= 12) points++;
  return switch (points) {
    <= 1 => PasswordStrength.lemah,
    2 => PasswordStrength.sedang,
    _ => PasswordStrength.kuat,
  };
}

String? validateName(String name) =>
    name.trim().isEmpty ? 'Nama lengkap wajib diisi.' : null;

String? validateEmail(String email) {
  final value = email.trim();
  if (value.isEmpty) return 'Email wajib diisi.';
  if (!_emailPattern.hasMatch(value.toLowerCase())) {
    return 'Format email belum valid.';
  }
  return null;
}

String? validatePassword(String password) {
  if (password.isEmpty) return 'Password wajib diisi.';
  if (!hasMinLength(password)) {
    return 'Password minimal $minPasswordLength karakter.';
  }
  return null;
}
