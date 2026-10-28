import 'package:kage/models/models.dart';

/// Pengubah model kuis ke bentuk JSON dan sebaliknya.
///
/// Fungsi dekode bersifat defensif: data yang rusak, tidak lengkap, atau memakai
/// nama enum lama dikembalikan sebagai `null` agar pemanggil dapat
/// mengabaikannya alih-alih membuat aplikasi gagal dibuka.
Map<String, Object?> quizResultToJson(QuizResult result) {
  return <String, Object?>{
    'categoryId': result.categoryId.name,
    'score': result.score,
    'correct': result.correct,
    'total': result.total,
    'durationMs': result.duration.inMilliseconds,
    'playedAt': result.playedAt.toIso8601String(),
    'difficulty': result.difficulty.name,
    // Rincian percobaan disimpan agar tinjauan jawaban lama masih bisa dibuka
    // dari halaman Riwayat (U-11).
    'answers': List<int?>.from(result.answers),
    'questionOrder': List<int>.from(result.questionOrder),
    'optionOrders': [
      for (final order in result.optionOrders) List<int>.from(order),
    ],
  };
}

QuizResult? quizResultFromJson(Object? json) {
  final map = _asStringMap(json);
  if (map == null) return null;

  final category = _enumByName(CategoryId.values, map['categoryId']);
  final difficulty = _enumByName(Difficulty.values, map['difficulty']);
  final playedAt = _asDateTime(map['playedAt']);
  final score = _asInt(map['score']);
  final correct = _asInt(map['correct']);
  final total = _asInt(map['total']);
  final durationMs = _asInt(map['durationMs']);

  if (category == null ||
      difficulty == null ||
      playedAt == null ||
      score == null ||
      correct == null ||
      total == null ||
      total <= 0 ||
      durationMs == null ||
      durationMs < 0) {
    return null;
  }

  // Riwayat lama belum menyimpan rincian jawaban; kolom yang tidak ada dibaca
  // sebagai daftar kosong dan halaman detail menampilkan pesannya sendiri.
  final answers = _asAnswers(map['answers']) ?? const <int?>[];
  final questionOrder = _asInts(map['questionOrder']) ?? const <int>[];
  final optionOrders =
      _asNestedIntList(map['optionOrders']) ?? const <List<int>>[];

  return QuizResult(
    categoryId: category,
    score: score.clamp(0, 100),
    correct: correct.clamp(0, total),
    total: total,
    duration: Duration(milliseconds: durationMs),
    playedAt: playedAt,
    difficulty: difficulty,
    answers: answers,
    questionOrder: questionOrder,
    optionOrders: optionOrders,
  );
}

Map<String, Object?> inProgressQuizToJson(InProgressQuiz quiz) {
  return <String, Object?>{
    'categoryId': quiz.categoryId.name,
    'difficulty': quiz.difficulty.name,
    'index': quiz.index,
    'answers': List<int?>.from(quiz.answers),
    'submitted': List<bool>.from(quiz.submitted),
    'questionOrder': List<int>.from(quiz.questionOrder),
    'optionOrders': [
      for (final order in quiz.optionOrders) List<int>.from(order),
    ],
    'elapsedMs': quiz.elapsed.inMilliseconds,
  };
}

InProgressQuiz? inProgressQuizFromJson(Object? json) {
  final map = _asStringMap(json);
  if (map == null) return null;

  final category = _enumByName(CategoryId.values, map['categoryId']);
  final difficulty = _enumByName(Difficulty.values, map['difficulty']);
  final index = _asInt(map['index']);
  final answers = _asAnswers(map['answers']);
  final submitted = _asBoolList(map['submitted']);
  final questionOrder = _asInts(map['questionOrder']);
  final optionOrders = _asNestedIntList(map['optionOrders']);
  final elapsedMs = _asInt(map['elapsedMs']);

  if (category == null ||
      difficulty == null ||
      index == null ||
      index < 0 ||
      answers == null ||
      submitted == null ||
      questionOrder == null ||
      optionOrders == null ||
      elapsedMs == null ||
      elapsedMs < 0 ||
      index >= questionOrder.length ||
      submitted.length != questionOrder.length ||
      optionOrders.length != questionOrder.length) {
    return null;
  }

  return InProgressQuiz(
    categoryId: category,
    difficulty: difficulty,
    index: index,
    answers: answers,
    submitted: submitted,
    questionOrder: questionOrder,
    optionOrders: optionOrders,
    elapsed: Duration(milliseconds: elapsedMs),
  );
}

Map<String, Object?>? _asStringMap(Object? json) {
  if (json is! Map) return null;
  final map = <String, Object?>{};
  for (final entry in json.entries) {
    final key = entry.key;
    if (key is! String) return null;
    map[key] = entry.value;
  }
  return map;
}

T? _enumByName<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  final byName = <String, T>{for (final value in values) value.name: value};
  return byName[name];
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

DateTime? _asDateTime(Object? value) {
  if (value is! String) return null;
  return DateTime.tryParse(value);
}

List<int?>? _asAnswers(Object? value) {
  if (value is! List) return null;
  final items = <int?>[];
  for (final item in value) {
    if (item == null) {
      items.add(null);
      continue;
    }
    final parsed = _asInt(item);
    if (parsed == null) return null;
    items.add(parsed);
  }
  return items;
}

List<int>? _asInts(Object? value) {
  if (value is! List) return null;
  final items = <int>[];
  for (final item in value) {
    final parsed = _asInt(item);
    if (parsed == null) return null;
    items.add(parsed);
  }
  return items;
}

List<bool>? _asBoolList(Object? value) {
  if (value is! List) return null;
  final items = <bool>[];
  for (final item in value) {
    if (item is! bool) return null;
    items.add(item);
  }
  return items;
}

List<List<int>>? _asNestedIntList(Object? value) {
  if (value is! List) return null;
  final items = <List<int>>[];
  for (final item in value) {
    final parsed = _asInts(item);
    if (parsed == null) return null;
    items.add(parsed);
  }
  return items;
}
