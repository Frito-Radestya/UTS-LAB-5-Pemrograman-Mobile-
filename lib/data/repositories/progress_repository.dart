import 'dart:async';
import 'dart:convert';

import 'package:hive/hive.dart';

import 'package:kage/data/local/quiz_codec.dart';
import 'package:kage/models/models.dart';

/// Penyimpanan progres pengguna: total XP dan kuis yang sedang berjalan.
///
/// XP disimpan di sini karena level selalu diturunkan dari XP, sedangkan resume
/// menyimpan urutan soal, jawaban, dan waktu pengerjaan agar sesi kuis dapat
/// dilanjutkan setelah aplikasi ditutup.
abstract interface class ProgressRepository {
  int loadXp();

  void saveXp(int xp);

  InProgressQuiz? loadResume();

  void saveResume(InProgressQuiz? resume);
}

/// Penyimpanan sementara selama aplikasi berjalan.
class InMemoryProgressRepository implements ProgressRepository {
  int _xp = 0;
  InProgressQuiz? _resume;

  @override
  int loadXp() => _xp;

  @override
  void saveXp(int xp) {
    _xp = xp < 0 ? 0 : xp;
  }

  @override
  InProgressQuiz? loadResume() => _resume;

  @override
  void saveResume(InProgressQuiz? resume) {
    _resume = resume;
  }
}

/// Penyimpanan XP dan resume kuis di kotak Hive lokal.
class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._box);

  static const String _xpKey = 'progress.xp';
  static const String _resumeKey = 'progress.resume';

  final Box<dynamic> _box;

  @override
  int loadXp() {
    final raw = _box.get(_xpKey);
    if (raw is! int || raw < 0) return 0;
    return raw;
  }

  @override
  void saveXp(int xp) {
    unawaited(_box.put(_xpKey, xp < 0 ? 0 : xp));
  }

  @override
  InProgressQuiz? loadResume() {
    final raw = _box.get(_resumeKey);
    if (raw is! String) return null;
    try {
      return inProgressQuizFromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  @override
  void saveResume(InProgressQuiz? resume) {
    if (resume == null) {
      unawaited(_box.delete(_resumeKey));
      return;
    }
    unawaited(_box.put(_resumeKey, jsonEncode(inProgressQuizToJson(resume))));
  }
}
