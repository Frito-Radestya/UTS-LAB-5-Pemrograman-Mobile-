import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:kage/data/local/quiz_codec.dart';
import 'package:kage/models/models.dart';

/// Penyimpanan hasil kuis.
///
/// Kontrak ini sengaja tidak bergantung pada UI atau controller. Implementasi
/// in-memory dipakai untuk pengujian; implementasi lokal menyimpan riwayat di
/// kotak Hive agar data bertahan setelah aplikasi ditutup.
abstract interface class HistoryRepository {
  List<QuizResult> load();

  void save(List<QuizResult> results);

  void clear();
}

/// Penyimpanan sementara selama aplikasi berjalan.
class InMemoryHistoryRepository implements HistoryRepository {
  final List<QuizResult> _results = <QuizResult>[];

  @override
  List<QuizResult> load() => List<QuizResult>.unmodifiable(_results);

  @override
  void save(List<QuizResult> results) {
    _results
      ..clear()
      ..addAll(results);
  }

  @override
  void clear() {
    _results.clear();
  }
}

/// Penyimpanan riwayat kuis di kotak Hive lokal.
class LocalHistoryRepository implements HistoryRepository {
  LocalHistoryRepository(this._box);

  static const String _key = 'history';

  final Box<dynamic> _box;

  @override
  List<QuizResult> load() {
    final raw = _box.get(_key);
    if (raw is! String) return const <QuizResult>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <QuizResult>[];
      final results = <QuizResult>[];
      for (final item in decoded) {
        final result = quizResultFromJson(item);
        if (result != null) results.add(result);
      }
      return List<QuizResult>.unmodifiable(results);
    } on FormatException {
      return const <QuizResult>[];
    }
  }

  @override
  void save(List<QuizResult> results) {
    final payload = jsonEncode([
      for (final result in results) quizResultToJson(result),
    ]);
    unawaited(_box.put(_key, payload));
  }

  @override
  void clear() {
    unawaited(_box.delete(_key));
  }
}
