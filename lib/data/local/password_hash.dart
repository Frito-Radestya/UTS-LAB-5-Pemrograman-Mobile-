import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Kata sandi yang sudah diamankan untuk disimpan di perangkat.
///
/// Kata sandi tidak pernah ditulis apa adanya: setiap akun punya salt acak
/// sendiri dan verifikasi memakai PBKDF2-HMAC-SHA256, sehingga menebak kata
/// sandi dari berkas tersimpan membutuhkan biaya komputasi.
class PasswordHash {
  const PasswordHash({
    required this.salt,
    required this.hash,
    this.iterations = defaultIterations,
  });

  /// Jumlah iterasi PBKDF2. Dinaikkan bila perangkat kelas bawah sudah nyaman.
  static const int defaultIterations = 10000;
  static const int saltBytes = 16;
  static const int keyBytes = 32;

  /// Salt acak, dikodekan base64.
  final String salt;

  /// Kunci turunan, dikodekan base64.
  final String hash;

  final int iterations;

  /// Membuat hash baru dengan salt acak.
  factory PasswordHash.create(String password, {Random? random}) {
    final salt = generateSalt(random);
    return PasswordHash(
      salt: salt,
      hash: derive(password, salt: salt, iterations: defaultIterations),
    );
  }

  static String generateSalt(Random? random) {
    final source = random ?? Random.secure();
    return base64Encode(
      List<int>.generate(saltBytes, (_) => source.nextInt(256)),
    );
  }

  /// Menurunkan kunci dari [password] dan [salt].
  static String derive(
    String password, {
    required String salt,
    required int iterations,
  }) {
    final key = _pbkdf2(
      utf8.encode(password),
      base64Decode(salt),
      iterations,
      keyBytes,
    );
    return base64Encode(key);
  }

  /// Apakah [password] menghasilkan kunci yang sama dengan yang tersimpan.
  bool matches(String password) => _constantTimeEquals(
    derive(password, salt: salt, iterations: iterations),
    hash,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'salt': salt,
    'hash': hash,
    'iterations': iterations,
  };

  /// Mengembalikan `null` bila data tersimpan rusak, supaya akun rusak
  /// diabaikan alih-alih membuat aplikasi gagal dijalankan.
  static PasswordHash? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final salt = raw['salt'];
    final hash = raw['hash'];
    final iterations = raw['iterations'];
    if (salt is! String || salt.isEmpty || hash is! String || hash.isEmpty) {
      return null;
    }
    if (iterations is! int || iterations <= 0) return null;
    return PasswordHash(salt: salt, hash: hash, iterations: iterations);
  }

  /// Perbandingan yang tidak berhenti di karakter pertama yang berbeda.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var difference = 0;
    for (var i = 0; i < a.length; i++) {
      difference |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return difference == 0;
  }
}

/// PBKDF2-HMAC-SHA256.
Uint8List _pbkdf2(
  List<int> password,
  List<int> salt,
  int iterations,
  int length,
) {
  final hmac = Hmac(sha256, password);
  final blockCount = (length / 32).ceil();
  final output = BytesBuilder();

  for (var block = 1; block <= blockCount; block++) {
    var current = Uint8List.fromList(
      hmac.convert(<int>[...salt, ..._blockIndex(block)]).bytes,
    );
    final accumulated = Uint8List.fromList(current);
    for (var iteration = 1; iteration < iterations; iteration++) {
      current = Uint8List.fromList(hmac.convert(current).bytes);
      for (var i = 0; i < accumulated.length; i++) {
        accumulated[i] ^= current[i];
      }
    }
    output.add(accumulated);
  }

  return Uint8List.fromList(output.toBytes().sublist(0, length));
}

List<int> _blockIndex(int block) => <int>[
  (block >> 24) & 0xff,
  (block >> 16) & 0xff,
  (block >> 8) & 0xff,
  block & 0xff,
];
