import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:kage/models/models.dart';

/// Versi skema berkas bank soal yang dipahami parser ini.
///
/// Tambahkan versi baru dan penanganannya di [validateQuizBank] bila struktur
/// berkas berubah, sehingga berkas lama bisa ditolak dengan pesan yang jelas.
const int quizBankSchemaVersion = 1;

/// Lokasi berkas bank soal tiap kategori.
String quizBankAssetPath(CategoryId id) =>
    'assets/data/questions_${id.name}.json';

/// Berkas bank soal tidak sesuai skema.
class QuizBankFormatException implements Exception {
  const QuizBankFormatException(this.sourceName, this.errors);

  final String sourceName;
  final List<String> errors;

  @override
  String toString() =>
      'QuizBankFormatException($sourceName): ${errors.join('; ')}';
}

/// Isi satu berkas bank soal yang sudah lolos validasi.
class QuizBank {
  const QuizBank({
    required this.schemaVersion,
    required this.categoryId,
    required this.questions,
  });

  final int schemaVersion;
  final CategoryId categoryId;
  final List<Question> questions;
}

/// Memeriksa satu berkas bank soal dan mengembalikan seluruh temuan.
///
/// Daftar kosong berarti berkas sah. Fungsi ini sengaja mengumpulkan semua
/// error sekaligus agar penulis soal bisa memperbaiki beberapa kesalahan dalam
/// satu kali jalan.
List<String> validateQuizBank(
  Object? decoded, {
  required String sourceName,
  required CategoryId expectedCategory,
}) {
  final errors = <String>[];
  if (decoded is! Map) {
    return ['$sourceName: isi berkas harus berupa objek JSON'];
  }

  final version = decoded['schemaVersion'];
  if (version is! int) {
    errors.add('$sourceName: "schemaVersion" wajib berupa angka');
  } else if (version != quizBankSchemaVersion) {
    errors.add(
      '$sourceName: schemaVersion $version tidak didukung '
      '(didukung: $quizBankSchemaVersion)',
    );
  }

  final categoryId = decoded['categoryId'];
  if (categoryId != expectedCategory.name) {
    errors.add(
      '$sourceName: "categoryId" harus "${expectedCategory.name}", '
      'ditemukan "$categoryId"',
    );
  }

  final rawQuestions = decoded['questions'];
  if (rawQuestions is! List || rawQuestions.isEmpty) {
    errors.add('$sourceName: "questions" wajib berisi minimal satu soal');
    return errors;
  }

  final seenPrompts = <String, int>{};
  for (var index = 0; index < rawQuestions.length; index++) {
    final raw = rawQuestions[index];
    final label = '$sourceName soal #${index + 1}';
    if (raw is! Map) {
      errors.add('$label: harus berupa objek');
      continue;
    }

    final difficulty = _parseDifficulty(raw['difficulty']);
    if (difficulty == null) {
      errors.add(
        '$label: "difficulty" tidak dikenal '
        '("${raw['difficulty']}", pilihan: ${Difficulty.values.map((d) => d.name).join(', ')})',
      );
    }

    final prompt = raw['prompt'];
    if (prompt is! String || prompt.trim().isEmpty) {
      errors.add('$label: "prompt" wajib diisi');
    } else {
      final previous = seenPrompts[prompt];
      if (previous != null) {
        errors.add('$label: soal duplikat dengan soal #$previous');
      } else {
        seenPrompts[prompt] = index + 1;
      }
    }

    final options = raw['options'];
    var optionCount = 0;
    if (options is! List || options.length < 2) {
      errors.add('$label: "options" wajib berisi minimal dua pilihan');
    } else {
      optionCount = options.length;
      final seenOptions = <String>{};
      for (var i = 0; i < options.length; i++) {
        final option = options[i];
        if (option is! String || option.trim().isEmpty) {
          errors.add('$label: pilihan #${i + 1} kosong');
          continue;
        }
        if (!seenOptions.add(option)) {
          errors.add('$label: pilihan "$option" muncul lebih dari sekali');
        }
      }
    }

    final correctIndex = raw['correctIndex'];
    if (correctIndex is! int) {
      errors.add('$label: "correctIndex" wajib berupa angka');
    } else if (correctIndex < 0 || correctIndex >= optionCount) {
      errors.add(
        '$label: "correctIndex" $correctIndex di luar rentang '
        '0..${optionCount - 1}',
      );
    }

    final explanation = raw['explanation'];
    if (explanation is! String || explanation.trim().isEmpty) {
      errors.add('$label: "explanation" wajib diisi');
    }

    final funFact = raw['funFact'];
    if (funFact is! String || funFact.trim().isEmpty) {
      errors.add('$label: "funFact" wajib diisi');
    }
  }

  return errors;
}

/// Mengubah isi berkas bank soal menjadi model.
///
/// Melempar [QuizBankFormatException] bila berkas tidak lolos
/// [validateQuizBank], sehingga berkas rusak ketahuan saat pengujian, bukan
/// saat pengguna membuka kuis.
QuizBank parseQuizBank(
  String source, {
  required String sourceName,
  required CategoryId expectedCategory,
}) {
  final Object? decoded = jsonDecode(source);
  final errors = validateQuizBank(
    decoded,
    sourceName: sourceName,
    expectedCategory: expectedCategory,
  );
  if (errors.isNotEmpty) {
    throw QuizBankFormatException(sourceName, errors);
  }

  final map = decoded as Map;
  final rawQuestions = (map['questions'] as List).cast<Map>();
  return QuizBank(
    schemaVersion: map['schemaVersion'] as int,
    categoryId: expectedCategory,
    questions: List<Question>.unmodifiable([
      for (final raw in rawQuestions)
        Question(
          prompt: raw['prompt'] as String,
          options: List<String>.unmodifiable(
            (raw['options'] as List).cast<String>(),
          ),
          correctIndex: raw['correctIndex'] as int,
          explanation: raw['explanation'] as String,
          funFact: raw['funFact'] as String,
          difficulty: _parseDifficulty(raw['difficulty'])!,
        ),
    ]),
  );
}

/// Memuat seluruh berkas bank soal dari asset aplikasi.
Future<Map<CategoryId, List<Question>>> loadQuizBank({
  AssetBundle? bundle,
}) async {
  final assets = bundle ?? rootBundle;
  final result = <CategoryId, List<Question>>{};
  for (final categoryId in CategoryId.values) {
    final path = quizBankAssetPath(categoryId);
    final source = await assets.loadString(path);
    final bank = parseQuizBank(
      source,
      sourceName: path,
      expectedCategory: categoryId,
    );
    result[categoryId] = bank.questions;
  }
  return result;
}

Difficulty? _parseDifficulty(Object? raw) {
  if (raw is! String) return null;
  for (final difficulty in Difficulty.values) {
    if (difficulty.name == raw) return difficulty;
  }
  return null;
}
