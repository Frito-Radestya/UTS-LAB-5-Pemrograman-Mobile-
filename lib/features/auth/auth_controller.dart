import 'package:flutter/foundation.dart';

import 'package:kage/data/local/password_hash.dart';
import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/features/auth/validation.dart' as validation;

/// Kolom formulir yang terkait dengan sebuah kegagalan autentikasi, supaya
/// halaman bisa menaruh pesan di bawah input yang tepat.
enum AuthField { name, email, password, general }

/// Hasil satu percobaan autentikasi.
class AuthResult {
  const AuthResult._({required this.ok, this.field, this.message});

  const AuthResult.success() : this._(ok: true);

  const AuthResult.failure(AuthField field, String message)
    : this._(ok: false, field: field, message: message);

  final bool ok;
  final AuthField? field;
  final String? message;
}

/// Menyimpan status autentikasi, akun terdaftar, dan identitas pengguna.
///
/// Kata sandi hanya disimpan dalam bentuk hash bersalt (lihat [PasswordHash]),
/// dan kredensial yang salah ditolak.
class AuthController extends ChangeNotifier {
  AuthController({AuthRepository? repository})
    : _repository = repository ?? InMemoryAuthRepository() {
    final profile = _repository.loadProfile();
    if (profile != null) {
      _fullName = profile.fullName;
      _email = profile.email;
      _loggedIn = true;
    }
  }

  /// Panjang minimum kata sandi saat mendaftar dan saat menggantinya.
  static const int minPasswordLength = validation.minPasswordLength;

  final AuthRepository _repository;

  bool _loggedIn = false;
  String _fullName = '';
  String _email = '';

  bool get loggedIn => _loggedIn;
  String get fullName => _fullName;
  String get email => _email;

  /// Jumlah akun terdaftar di perangkat ini.
  int get accountCount => _repository.loadAccounts().length;

  String get firstName {
    final parts = _fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Pengguna' : parts.first;
  }

  String get initial {
    final name = _fullName.trim();
    return name.isEmpty ? 'K' : name[0].toUpperCase();
  }

  /// Membuat akun baru dengan kata sandi ter-hash, lalu masuk sebagai akun itu.
  AuthResult register({
    required String name,
    required String email,
    required String password,
    String? confirmPassword,
  }) {
    final trimmedName = name.trim();
    final nameError = validation.validateName(trimmedName);
    if (nameError != null) {
      return AuthResult.failure(AuthField.name, nameError);
    }

    final normalizedEmail = email.trim().toLowerCase();
    final emailError = validation.validateEmail(normalizedEmail);
    if (emailError != null) {
      return AuthResult.failure(AuthField.email, emailError);
    }

    final passwordError = _validatePassword(password, confirmPassword);
    if (passwordError != null) {
      return AuthResult.failure(AuthField.password, passwordError);
    }

    if (_accountFor(normalizedEmail) != null) {
      return const AuthResult.failure(
        AuthField.email,
        'Email sudah terdaftar. Silakan masuk.',
      );
    }

    final account = AuthAccount(
      fullName: trimmedName,
      email: normalizedEmail,
      password: PasswordHash.create(password),
    );
    _repository.saveAccount(account);
    _signIn(account);
    return const AuthResult.success();
  }

  /// Masuk memakai email (atau nama lengkap bila hanya satu akun yang cocok).
  AuthResult login({required String identifier, required String password}) {
    final value = identifier.trim();
    if (value.isEmpty) {
      return const AuthResult.failure(
        AuthField.email,
        'Email atau username wajib diisi.',
      );
    }
    if (password.isEmpty) {
      return const AuthResult.failure(
        AuthField.password,
        'Password wajib diisi.',
      );
    }

    final account = _accountFor(value);
    if (account == null || !account.password.matches(password)) {
      return const AuthResult.failure(
        AuthField.password,
        'Email atau password salah.',
      );
    }

    _signIn(account);
    return const AuthResult.success();
  }

  /// Mengganti kata sandi akun yang sedang masuk.
  AuthResult changePassword({
    required String currentPassword,
    required String newPassword,
    String? confirmPassword,
  }) {
    final account = _accountFor(_email);
    if (account == null) {
      return const AuthResult.failure(
        AuthField.general,
        'Akun untuk sesi ini tidak ditemukan.',
      );
    }
    if (!account.password.matches(currentPassword)) {
      return const AuthResult.failure(
        AuthField.password,
        'Password saat ini salah.',
      );
    }

    final passwordError = _validatePassword(newPassword, confirmPassword);
    if (passwordError != null) {
      return AuthResult.failure(AuthField.password, passwordError);
    }
    if (account.password.matches(newPassword)) {
      return const AuthResult.failure(
        AuthField.password,
        'Password baru harus berbeda dari password lama.',
      );
    }

    _repository.saveAccount(
      account.copyWith(password: PasswordHash.create(newPassword)),
    );
    return const AuthResult.success();
  }

  /// Mengubah nama atau email akun yang sedang masuk.
  ///
  /// Akun tersimpan ikut diperbarui sehingga percobaan masuk berikutnya memakai
  /// data terbaru, sementara kata sandinya tidak berubah.
  AuthResult updateProfile({String? name, String? mail}) {
    final previousEmail = _email;
    final trimmedName = name?.trim();
    final trimmedMail = mail?.trim();

    if (mail != null && trimmedMail != null && trimmedMail.isNotEmpty) {
      final emailError = validation.validateEmail(trimmedMail);
      if (emailError != null) {
        return AuthResult.failure(AuthField.email, emailError);
      }
      final owner = _accountFor(trimmedMail);
      if (owner != null && owner.email.toLowerCase() != _email.toLowerCase()) {
        return const AuthResult.failure(
          AuthField.email,
          'Email sudah dipakai akun lain.',
        );
      }
    }

    if (trimmedName != null && trimmedName.isNotEmpty) _fullName = trimmedName;
    if (trimmedMail != null && trimmedMail.isNotEmpty) {
      _email = trimmedMail.toLowerCase();
    }

    final account = _accountFor(previousEmail) ?? _accountFor(_email);
    if (account != null) {
      _repository.replaceAccounts([
        for (final item in _repository.loadAccounts())
          if (item.email.toLowerCase() == account.email.toLowerCase())
            item.copyWith(fullName: _fullName, email: _email)
          else
            item,
      ]);
    }

    _saveProfile();
    notifyListeners();
    return const AuthResult.success();
  }

  void logout() {
    _loggedIn = false;
    _repository.clearProfile();
    notifyListeners();
  }

  /// Menghapus sesi dan seluruh akun yang tersimpan di perangkat.
  void deleteAllAccounts() {
    _loggedIn = false;
    _fullName = '';
    _email = '';
    _repository.replaceAccounts(const <AuthAccount>[]);
    _repository.clearProfile();
    notifyListeners();
  }

  String? _validatePassword(String password, String? confirmPassword) {
    final error = validation.validatePassword(password);
    if (error != null) return error;
    if (confirmPassword != null && confirmPassword != password) {
      return 'Konfirmasi password tidak cocok.';
    }
    return null;
  }

  AuthAccount? _accountFor(String identifier) {
    final value = identifier.trim().toLowerCase();
    if (value.isEmpty) return null;

    final accounts = _repository.loadAccounts();
    for (final account in accounts) {
      if (account.email.toLowerCase() == value) return account;
    }

    final byName = accounts
        .where((account) => account.fullName.toLowerCase() == value)
        .toList();
    return byName.length == 1 ? byName.first : null;
  }

  void _signIn(AuthAccount account) {
    _fullName = account.fullName;
    _email = account.email;
    _loggedIn = true;
    _saveProfile();
    notifyListeners();
  }

  void _saveProfile() {
    _repository.saveProfile(AuthProfile(fullName: _fullName, email: _email));
  }
}
