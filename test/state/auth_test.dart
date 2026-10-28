import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kage/data/local/password_hash.dart';
import 'package:kage/data/repositories/auth_repository.dart';
import 'package:kage/features/auth/auth_controller.dart';

Future<LocalAuthRepository> _localRepository() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();
  return LocalAuthRepository(preferences);
}

void main() {
  group('D-03 PasswordHash', () {
    test('kata sandi tidak pernah disimpan apa adanya', () {
      final hash = PasswordHash.create('rahasia123');

      expect(hash.hash, isNot(contains('rahasia123')));
      expect(hash.salt, isNotEmpty);
      expect(hash.iterations, PasswordHash.defaultIterations);
      expect(hash.matches('rahasia123'), isTrue);
      expect(hash.matches('rahasia124'), isFalse);
    });

    test('dua akun dengan kata sandi sama menghasilkan hash berbeda', () {
      final first = PasswordHash.create('rahasia123');
      final second = PasswordHash.create('rahasia123');

      expect(first.salt, isNot(second.salt));
      expect(first.hash, isNot(second.hash));
      expect(second.matches('rahasia123'), isTrue);
    });

    test('hanya salt dan kunci turunan yang disimpan', () {
      final hash = PasswordHash.create('rahasia123');
      final json =
          jsonDecode(jsonEncode(hash.toJson())) as Map<String, dynamic>;

      expect(json.keys, containsAll(<String>['salt', 'hash', 'iterations']));
      final restored = PasswordHash.fromJson(json);
      expect(restored, isNotNull);
      expect(restored!.matches('rahasia123'), isTrue);
    });

    test('data rusak ditolak tanpa membuat aplikasi gagal', () {
      expect(PasswordHash.fromJson(null), isNull);
      expect(PasswordHash.fromJson('bukan objek'), isNull);
      expect(PasswordHash.fromJson(<String, Object?>{}), isNull);
      expect(
        PasswordHash.fromJson(<String, Object?>{
          'salt': 'abc',
          'hash': 'def',
          'iterations': 0,
        }),
        isNull,
      );
    });
  });

  group('D-03 registrasi akun', () {
    test('menyimpan akun dengan kata sandi ter-hash dan langsung masuk', () {
      final repository = InMemoryAuthRepository();
      final auth = AuthController(repository: repository);
      addTearDown(auth.dispose);

      final result = auth.register(
        name: 'Budi',
        email: 'Budi@Example.com',
        password: 'rahasia123',
      );

      expect(result.ok, isTrue);
      expect(auth.loggedIn, isTrue);
      expect(auth.fullName, 'Budi');
      expect(auth.email, 'budi@example.com');

      final accounts = repository.loadAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.first.password.hash, isNot(contains('rahasia123')));
      expect(accounts.first.password.matches('rahasia123'), isTrue);
    });

    test('menolak pendaftaran yang tidak sah', () {
      final auth = AuthController(repository: InMemoryAuthRepository());
      addTearDown(auth.dispose);

      final emptyName = auth.register(
        name: '   ',
        email: 'budi@example.com',
        password: 'rahasia123',
      );
      expect(emptyName.ok, isFalse);
      expect(emptyName.field, AuthField.name);

      final badEmail = auth.register(
        name: 'Budi',
        email: 'budi',
        password: 'rahasia123',
      );
      expect(badEmail.ok, isFalse);
      expect(badEmail.field, AuthField.email);

      final shortPassword = auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia',
      );
      expect(shortPassword.ok, isFalse);
      expect(shortPassword.field, AuthField.password);
      expect(shortPassword.message, contains('8'));

      final mismatch = auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
        confirmPassword: 'rahasia124',
      );
      expect(mismatch.field, AuthField.password);

      expect(auth.accountCount, 0);
      expect(auth.loggedIn, isFalse);
    });

    test('menolak email yang sudah terdaftar', () {
      final auth = AuthController(repository: InMemoryAuthRepository());
      addTearDown(auth.dispose);

      expect(
        auth
            .register(
              name: 'Budi',
              email: 'budi@example.com',
              password: 'rahasia123',
            )
            .ok,
        isTrue,
      );

      final duplicate = auth.register(
        name: 'Budi Lain',
        email: 'BUDI@example.com',
        password: 'rahasia456',
      );

      expect(duplicate.ok, isFalse);
      expect(duplicate.field, AuthField.email);
      expect(auth.accountCount, 1);
    });
  });

  group('D-03 masuk dengan kredensial', () {
    test('kata sandi salah ditolak', () {
      final auth = AuthController(repository: InMemoryAuthRepository());
      addTearDown(auth.dispose);
      auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );
      auth.logout();

      final wrong = auth.login(
        identifier: 'budi@example.com',
        password: 'salahsekali',
      );

      expect(wrong.ok, isFalse);
      expect(wrong.field, AuthField.password);
      expect(wrong.message, 'Email atau password salah.');
      expect(
        auth.loggedIn,
        isFalse,
        reason: 'kredensial salah tidak boleh masuk',
      );
    });

    test('akun yang tidak ada ditolak', () {
      final auth = AuthController(repository: InMemoryAuthRepository());
      addTearDown(auth.dispose);

      final result = auth.login(
        identifier: 'belum@example.com',
        password: 'rahasia123',
      );

      expect(result.ok, isFalse);
      expect(auth.loggedIn, isFalse);
    });

    test('masuk dengan email dan kata sandi yang benar', () {
      final repository = InMemoryAuthRepository();
      final first = AuthController(repository: repository);
      addTearDown(first.dispose);
      first.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );
      first.logout();

      final second = AuthController(repository: repository);
      addTearDown(second.dispose);
      final result = second.login(
        identifier: 'budi@example.com',
        password: 'rahasia123',
      );

      expect(result.ok, isTrue);
      expect(second.loggedIn, isTrue);
      expect(second.fullName, 'Budi');
    });

    test('masuk dengan nama lengkap bila hanya satu akun yang cocok', () {
      final repository = InMemoryAuthRepository();
      final auth = AuthController(repository: repository);
      addTearDown(auth.dispose);
      auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );
      auth.logout();

      expect(auth.login(identifier: 'Budi', password: 'rahasia123').ok, isTrue);
    });
  });

  group('D-03 penyimpanan akun lokal', () {
    test('kata sandi tidak muncul apa adanya di penyimpanan', () async {
      final repository = await _localRepository();
      final preferences = await SharedPreferences.getInstance();
      final auth = AuthController(repository: repository);
      addTearDown(auth.dispose);

      auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );

      final stored = preferences.getString('auth.accounts');
      expect(stored, isNotNull);
      expect(stored, isNot(contains('rahasia123')));
      expect(stored, contains('salt'));
      expect(stored, contains('iterations'));
    });

    test('akun tetap bisa dipakai masuk setelah dibuka ulang', () async {
      final repository = await _localRepository();
      final first = AuthController(repository: repository);
      addTearDown(first.dispose);
      first.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );
      first.logout();

      final preferences = await SharedPreferences.getInstance();
      final second = AuthController(
        repository: LocalAuthRepository(preferences),
      );
      addTearDown(second.dispose);

      expect(second.accountCount, 1);
      expect(
        second.login(identifier: 'budi@example.com', password: 'rahasia123').ok,
        isTrue,
      );
      expect(
        second.login(identifier: 'budi@example.com', password: 'rahasia124').ok,
        isFalse,
      );
    });

    test('data akun rusak diabaikan', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'auth.accounts': '[{"fullName":"Budi"}, 12, "bukan akun"]',
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = LocalAuthRepository(preferences);

      expect(repository.loadAccounts(), isEmpty);
    });
  });

  group('D-03 ganti kata sandi dan profil', () {
    test('ganti kata sandi butuh kata sandi saat ini', () {
      final repository = InMemoryAuthRepository();
      final auth = AuthController(repository: repository);
      addTearDown(auth.dispose);
      auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );

      final wrong = auth.changePassword(
        currentPassword: 'salahsekali',
        newPassword: 'rahasia456',
      );
      expect(wrong.ok, isFalse);
      expect(wrong.field, AuthField.password);

      final tooShort = auth.changePassword(
        currentPassword: 'rahasia123',
        newPassword: 'pendek',
      );
      expect(tooShort.ok, isFalse);

      final same = auth.changePassword(
        currentPassword: 'rahasia123',
        newPassword: 'rahasia123',
      );
      expect(same.ok, isFalse);

      final ok = auth.changePassword(
        currentPassword: 'rahasia123',
        newPassword: 'rahasia456',
      );
      expect(ok.ok, isTrue);
      expect(
        repository.loadAccounts().first.password.matches('rahasia456'),
        isTrue,
      );
      expect(
        repository.loadAccounts().first.password.matches('rahasia123'),
        isFalse,
      );
    });

    test('ubah profil memperbarui akun tanpa mengubah kata sandi', () {
      final repository = InMemoryAuthRepository();
      final auth = AuthController(repository: repository);
      addTearDown(auth.dispose);
      auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );

      final result = auth.updateProfile(name: 'Budi Santoso');

      expect(result.ok, isTrue);
      expect(auth.fullName, 'Budi Santoso');
      final account = repository.loadAccounts().single;
      expect(account.fullName, 'Budi Santoso');
      expect(account.password.matches('rahasia123'), isTrue);
    });

    test('hapus semua data menghilangkan akun dan sesi', () {
      final repository = InMemoryAuthRepository();
      final auth = AuthController(repository: repository);
      addTearDown(auth.dispose);
      auth.register(
        name: 'Budi',
        email: 'budi@example.com',
        password: 'rahasia123',
      );

      auth.deleteAllAccounts();

      expect(auth.accountCount, 0);
      expect(auth.loggedIn, isFalse);
      expect(repository.loadProfile(), isNull);
    });

    test('sesi lama tanpa akun tersimpan tetap dipulihkan', () {
      final repository = InMemoryAuthRepository()
        ..saveProfile(
          const AuthProfile(fullName: 'Budi', email: 'budi@example.com'),
        );

      final auth = AuthController(repository: repository);
      addTearDown(auth.dispose);

      expect(auth.loggedIn, isTrue);
      expect(auth.fullName, 'Budi');
    });
  });
}
