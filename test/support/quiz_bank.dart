import 'dart:io';

import 'package:kage/data/quiz_bank.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/models/models.dart';

/// Bank soal untuk pengujian.
///
/// Membaca berkas JSON yang sama dengan yang dipakai aplikasi, sehingga test
/// ikut gagal bila sebuah berkas bank soal rusak. Pembacaan dilakukan sinkron
/// dari disk supaya `setUpAll` tidak perlu async.
LocalQuizRepository testQuizBank() => LocalQuizRepository(testQuizBankData());

Map<CategoryId, List<Question>> testQuizBankData() {
  final cached = _cache;
  if (cached != null) return cached;

  final loaded = <CategoryId, List<Question>>{};
  for (final categoryId in CategoryId.values) {
    final path = quizBankAssetPath(categoryId);
    final source = File(path).readAsStringSync();
    loaded[categoryId] = parseQuizBank(
      source,
      sourceName: path,
      expectedCategory: categoryId,
    ).questions;
  }
  return _cache = loaded;
}

Map<CategoryId, List<Question>>? _cache;
