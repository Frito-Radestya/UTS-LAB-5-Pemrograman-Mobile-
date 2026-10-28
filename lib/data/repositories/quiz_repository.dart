import 'package:kage/data/quiz_data.dart' as meta;
import 'package:kage/models/models.dart';

/// Sumber data bank soal dan metadata kategori.
///
/// Controller bergantung pada kontrak ini sehingga sumber soal bisa diganti
/// (JSON asset, API, atau data lain) tanpa mengubah logika kuis.
abstract interface class QuizRepository {
  List<QuizCategory> get categories;

  QuizCategory categoryById(CategoryId id);

  List<Question> questionsFor(CategoryId id, Difficulty difficulty);

  int questionCountFor(CategoryId id);

  bool hasQuestionsFor(CategoryId id, Difficulty difficulty);

  List<Difficulty> availableDifficulties(CategoryId id);
}

/// Implementasi yang menyajikan bank soal yang sudah dimuat dari
/// `assets/data/questions_<kategori>.json`.
///
/// Pemuatannya dilakukan sekali di awal aplikasi (`AppServices.create`) supaya
/// seluruh halaman tetap bisa membaca soal secara sinkron.
class LocalQuizRepository implements QuizRepository {
  LocalQuizRepository(Map<CategoryId, List<Question>> bank)
    : _bank = <CategoryId, List<Question>>{
        for (final entry in bank.entries)
          entry.key: List<Question>.unmodifiable(entry.value),
      };

  /// Bank kosong, dipakai sebelum asset selesai dimuat.
  LocalQuizRepository.empty() : _bank = const <CategoryId, List<Question>>{};

  final Map<CategoryId, List<Question>> _bank;

  @override
  List<QuizCategory> get categories => meta.categories;

  @override
  QuizCategory categoryById(CategoryId id) => meta.categoryById(id);

  @override
  List<Question> questionsFor(CategoryId id, Difficulty difficulty) =>
      List<Question>.unmodifiable(
        (_bank[id] ?? const <Question>[]).where(
          (question) => question.difficulty == difficulty,
        ),
      );

  @override
  int questionCountFor(CategoryId id) =>
      (_bank[id] ?? const <Question>[]).length;

  @override
  bool hasQuestionsFor(CategoryId id, Difficulty difficulty) =>
      questionsFor(id, difficulty).isNotEmpty;

  @override
  List<Difficulty> availableDifficulties(CategoryId id) => [
    for (final difficulty in Difficulty.values)
      if (hasQuestionsFor(id, difficulty)) difficulty,
  ];
}
