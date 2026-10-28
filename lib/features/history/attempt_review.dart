import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/features/quiz/quiz_controller.dart';
import 'package:kage/models/models.dart';

/// Menyusun kembali tinjauan jawaban sebuah percobaan dari data tersimpan.
///
/// Bank soal tidak menyimpan jawaban pengguna, jadi riwayat menyimpan urutan
/// soal, urutan opsi, dan pilihan yang diambil. Bila salah satu bagian tidak
/// lengkap atau tidak konsisten dengan bank soal saat ini, fungsi ini
/// mengembalikan `null` supaya halaman bersangkutan menampilkan pesan yang
/// jelas alih-alih pembahasan yang salah.
List<QuizReview>? reviewFromResult(QuizResult result, QuizRepository bank) {
  if (!result.hasDetail || result.answers.length != result.total) return null;

  final source = bank.questionsFor(result.categoryId, result.difficulty);
  final reviews = <QuizReview>[];
  for (var position = 0; position < result.total; position++) {
    final questionIndex = result.questionOrder[position];
    if (questionIndex < 0 || questionIndex >= source.length) return null;
    final question = source[questionIndex];

    final order = result.optionOrders[position];
    if (!_isPermutation(order, question.options.length)) return null;

    final correctIndex = order.indexOf(question.correctIndex);
    if (correctIndex < 0) return null;
    final chosen = result.answers[position];
    if (chosen != null && (chosen < 0 || chosen >= order.length)) return null;

    reviews.add(
      QuizReview(
        // Soal ditulis ulang memakai urutan opsi yang benar-benar dilihat
        // pengguna saat itu, sehingga huruf A-D tetap sesuai ingatannya.
        question: Question(
          prompt: question.prompt,
          options: List<String>.unmodifiable([
            for (final original in order) question.options[original],
          ]),
          correctIndex: correctIndex,
          explanation: question.explanation,
          funFact: question.funFact,
          difficulty: question.difficulty,
        ),
        chosenIndex: chosen,
      ),
    );
  }
  return reviews;
}

bool _isPermutation(List<int> order, int length) {
  if (order.length != length) return false;
  final seen = <int>{};
  for (final value in order) {
    if (value < 0 || value >= length) return false;
    if (!seen.add(value)) return false;
  }
  return true;
}
