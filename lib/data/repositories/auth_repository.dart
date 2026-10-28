import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kage/data/local/password_hash.dart';

/// Identitas pengguna yang sedang masuk.
class AuthProfile {
  const AuthProfile({required this.fullName, required this.email});

  final String fullName;
  final String email;
}

/// Akun terdaftar beserta kata sandi yang sudah di-hash.
class AuthAccount {
  const AuthAccount({
    required this.fullName,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String email;
  final PasswordHash password;

  AuthAccount copyWith({
    String? fullName,
    String? email,
    PasswordHash? password,
  }) {
    return AuthAccount(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'fullName': fullName,
    'email': email,
    'password': password.toJson(),
  };

  /// Mengembalikan `null` untuk data rusak agar entri tersebut diabaikan.
  static AuthAccount? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final fullName = raw['fullName'];
    final email = raw['email'];
    final password = PasswordHash.fromJson(raw['password']);
    if (fullName is! String || fullName.trim().isEmpty) return null;
    if (email is! String || email.trim().isEmpty) return null;
    if (password == null) return null;
    return AuthAccount(fullName: fullName, email: email, password: password);
  }
}

/// Sumber data sesi dan akun autentikasi.
///
/// Kontrak ini memisahkan penyimpanan identitas dan kata sandi dari
/// `AuthController`. Implementasi in-memory dipakai untuk pengujian;
/// implementasi lokal menyimpan sesi dan akun agar pengguna tetap masuk setelah
/// aplikasi ditutup.
abstract interface class AuthRepository {
  AuthProfile? loadProfile();

  void saveProfile(AuthProfile profile);

  void clearProfile();

  List<AuthAccount> loadAccounts();

  /// Menambah akun baru, atau mengganti akun dengan email yang sama.
  void saveAccount(AuthAccount account);

  /// Menimpa seluruh daftar akun. Dipakai saat kata sandi berubah atau data
  /// pengguna dihapus.
  void replaceAccounts(List<AuthAccount> accounts);
}

/// Penyimpanan sesi dan akun sementara selama aplikasi berjalan.
class InMemoryAuthRepository implements AuthRepository {
  AuthProfile? _profile;
  final List<AuthAccount> _accounts = <AuthAccount>[];

  @override
  AuthProfile? loadProfile() => _profile;

  @override
  void saveProfile(AuthProfile profile) {
    _profile = profile;
  }

  @override
  void clearProfile() {
    _profile = null;
  }

  @override
  List<AuthAccount> loadAccounts() => List<AuthAccount>.unmodifiable(_accounts);

  @override
  void saveAccount(AuthAccount account) {
    final index = _indexOf(account.email);
    if (index == -1) {
      _accounts.add(account);
    } else {
      _accounts[index] = account;
    }
  }

  @override
  void replaceAccounts(List<AuthAccount> accounts) {
    _accounts
      ..clear()
      ..addAll(accounts);
  }

  int _indexOf(String email) {
    final key = email.trim().toLowerCase();
    return _accounts.indexWhere(
      (account) => account.email.toLowerCase() == key,
    );
  }
}

/// Penyimpanan sesi dan akun di `shared_preferences`.
class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._preferences);

  static const String _nameKey = 'auth.full_name';
  static const String _emailKey = 'auth.email';
  static const String _sessionKey = 'auth.has_session';
  static const String _accountsKey = 'auth.accounts';

  final SharedPreferences _preferences;

  @override
  AuthProfile? loadProfile() {
    if (_preferences.getBool(_sessionKey) != true) return null;
    final name = _preferences.getString(_nameKey);
    if (name == null || name.trim().isEmpty) return null;
    return AuthProfile(
      fullName: name,
      email: _preferences.getString(_emailKey) ?? '',
    );
  }

  @override
  void saveProfile(AuthProfile profile) {
    unawaited(_preferences.setString(_nameKey, profile.fullName));
    unawaited(_preferences.setString(_emailKey, profile.email));
    unawaited(_preferences.setBool(_sessionKey, true));
  }

  @override
  void clearProfile() {
    unawaited(_preferences.remove(_nameKey));
    unawaited(_preferences.remove(_emailKey));
    unawaited(_preferences.setBool(_sessionKey, false));
  }

  @override
  List<AuthAccount> loadAccounts() {
    final raw = _preferences.getString(_accountsKey);
    if (raw == null || raw.isEmpty) return const <AuthAccount>[];

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const <AuthAccount>[];
    }
    if (decoded is! List) return const <AuthAccount>[];

    return List<AuthAccount>.unmodifiable(
      decoded.map(AuthAccount.fromJson).whereType<AuthAccount>(),
    );
  }

  @override
  void saveAccount(AuthAccount account) {
    final accounts = loadAccounts().toList();
    final index = accounts.indexWhere(
      (item) => item.email.toLowerCase() == account.email.toLowerCase(),
    );
    if (index == -1) {
      accounts.add(account);
    } else {
      accounts[index] = account;
    }
    replaceAccounts(accounts);
  }

  @override
  void replaceAccounts(List<AuthAccount> accounts) {
    unawaited(
      _preferences.setString(
        _accountsKey,
        jsonEncode(accounts.map((account) => account.toJson()).toList()),
      ),
    );
  }
}
