import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:kage/data/repositories/progress_repository.dart';
import 'package:kage/data/repositories/quiz_repository.dart';
import 'package:kage/models/models.dart';

typedef QuizCompleted = void Function(QuizResult result);

/// Satu soal pada tinjauan hasil: apa yang dipilih dan mana yang benar.
class QuizReview {
  const QuizReview({required this.question, required this.chosenIndex});

  final Question question;

  /// Indeks opsi yang dipilih, `null` bila soal tidak dijawab.
  final int? chosenIndex;

  bool get correct => chosenIndex == question.correctIndex;

  String? get chosenOption =>
      chosenIndex == null ? null : question.options[chosenIndex!];

  String get correctOption => question.options[question.correctIndex];
}

/// Mengelola satu sesi kuis: soal aktif, jawaban, penguncian, dan progres.
///
/// Controller ini tidak mengetahui riwayat atau XP. Hasil akhir dikirim lewat
/// [onCompleted] agar lapisan komposisi yang menghubungkannya. Kuis yang
/// disimpan dititipkan ke [ProgressRepository] supaya sesi tetap ada setelah
/// aplikasi ditutup.
class QuizController extends ChangeNotifier {
  QuizController({
    this.onCompleted,
    QuizRepository? questions,
    ProgressRepository? progress,
  }) : _questions = questions ?? LocalQuizRepository.empty(),
       _progress = progress ?? InMemoryProgressRepository() {
    resume = _progress.loadResume();
  }

  final QuizCompleted? onCompleted;
  final QuizRepository _questions;
  final ProgressRepository _progress;

  Difficulty selectedDifficulty = Difficulty.pemula;
  CategoryId? activeCategory;
  int questionIndex = 0;
  List<int?> answers = <int?>[];

  /// Soal yang sudah dikirim ke halaman penjelasan dan dikunci untuk diubah.
  List<bool> _submitted = <bool>[];

  /// Urutan soal dan opsi yang diacak untuk sesi kuis berjalan.
  List<Question> _activeQuestions = <Question>[];
  List<int> _questionOrder = <int>[];
  List<List<int>> _optionOrders = <List<int>>[];

  DateTime? quizStartedAt;
  Duration _elapsedBeforeResume = Duration.zero;
  QuizResult? lastResult;
  bool showingCorrect = true;

  /// Tinjauan kuis terakhir, disimpan setelah [finishQuiz] supaya halaman hasil
  /// bisa menampilkan daftar soal beserta pembahasannya (U-04).
  List<QuizReview> _review = <QuizReview>[];

  /// Kuis yang dipakai untuk mengulang soal salah berasal dari daftar soal
  /// sendiri, sehingga tidak bisa dilanjutkan dari Beranda.
  bool _customSession = false;

  List<QuizReview> get review => List<QuizReview>.unmodifiable(_review);

  List<QuizReview> get wrongReview =>
      List<QuizReview>.unmodifiable(_review.where((item) => !item.correct));

  InProgressQuiz? resume;

  Duration get currentElapsed {
    final startedAt = quizStartedAt;
    if (startedAt == null) return _elapsedBeforeResume;
    return _elapsedBeforeResume + DateTime.now().difference(startedAt);
  }

  List<Question> get activeQuestions =>
      List<Question>.unmodifiable(_activeQuestions);

  List<int> get questionOrder => List<int>.unmodifiable(_questionOrder);

  List<List<int>> get optionOrders =>
      List<List<int>>.unmodifiable(_optionOrders.map(List<int>.unmodifiable));

  bool isQuestionLocked(int index) =>
      index >= 0 && index < _submitted.length && _submitted[index];

  bool get currentQuestionLocked => isQuestionLocked(questionIndex);

  void setDifficulty(Difficulty value) {
    selectedDifficulty = value;
    notifyListeners();
  }

  void startQuiz(
    CategoryId id, {
    Difficulty? difficulty,
    int startIndex = 0,
    List<int?>? existing,
    List<bool>? submitted,
    Random? random,
    List<int>? questionOrder,
    List<List<int>>? optionOrders,
    Duration elapsed = Duration.zero,
  }) {
    final requested = difficulty ?? selectedDifficulty;
    selectedDifficulty = _questions.hasQuestionsFor(id, requested)
        ? requested
        : Difficulty.values.firstWhere(
            (value) => _questions.hasQuestionsFor(id, value),
            orElse: () => requested,
          );
    activeCategory = id;
    questionIndex = startIndex;
    _buildActiveQuestions(
      id,
      difficulty: selectedDifficulty,
      random: random ?? Random(),
      savedQuestionOrder: questionOrder,
      savedOptionOrders: optionOrders,
    );
    final total = _activeQuestions.length;
    answers = List<int?>.filled(total, null);
    _submitted = List<bool>.filled(total, false);
    if (existing != null) {
      for (var i = 0; i < existing.length && i < total; i++) {
        answers[i] = existing[i];
      }
    }
    if (submitted != null) {
      for (var i = 0; i < submitted.length && i < total; i++) {
        _submitted[i] = submitted[i];
      }
    }
    _customSession = false;
    _review = <QuizReview>[];
    _elapsedBeforeResume = elapsed;
    quizStartedAt = DateTime.now();
    notifyListeners();
  }

  /// Mengacak urutan soal dan opsi, lalu memetakan ulang indeks jawaban benar.
  ///
  /// [savedQuestionOrder] dan [savedOptionOrders] dipakai saat melanjutkan sesi
  /// agar urutan yang dilihat pengguna tetap sama seperti sebelumnya.
  void _buildActiveQuestions(
    CategoryId id, {
    required Difficulty difficulty,
    required Random random,
    List<int>? savedQuestionOrder,
    List<List<int>>? savedOptionOrders,
  }) {
    final source = _questions.questionsFor(id, difficulty);
    final order = <int>[];
    if (savedQuestionOrder != null &&
        _isPermutation(savedQuestionOrder, source.length)) {
      order.addAll(savedQuestionOrder);
    } else {
      order.addAll(List<int>.generate(source.length, (i) => i));
      order.shuffle(random);
    }

    _questionOrder = order;
    _optionOrders = <List<int>>[];
    _activeQuestions = <Question>[];
    for (var position = 0; position < order.length; position++) {
      final original = source[order[position]];
      final optionsCount = original.options.length;
      final saved =
          savedOptionOrders != null &&
              position < savedOptionOrders.length &&
              _isPermutation(savedOptionOrders[position], optionsCount)
          ? savedOptionOrders[position]
          : null;
      final optionOrder = <int>[];
      if (saved != null) {
        optionOrder.addAll(saved);
      } else {
        optionOrder.addAll(List<int>.generate(optionsCount, (i) => i));
        optionOrder.shuffle(random);
      }
      _optionOrders.add(optionOrder);
      _activeQuestions.add(
        Question(
          prompt: original.prompt,
          options: [for (final index in optionOrder) original.options[index]],
          correctIndex: optionOrder.indexOf(original.correctIndex),
          explanation: original.explanation,
          funFact: original.funFact,
          difficulty: original.difficulty,
        ),
      );
    }
  }

  bool _isPermutation(List<int> values, int length) {
    if (values.length != length) return false;
    final seen = List<bool>.filled(length, false);
    for (final value in values) {
      if (value < 0 || value >= length || seen[value]) return false;
      seen[value] = true;
    }
    return true;
  }

  /// Menyimpan jawaban saat ini agar bisa dilanjutkan dari Beranda.
  void saveProgress() {
    final id = activeCategory;
    if (id == null) return;
    if (_customSession) {
      // Sesi latihan soal salah tidak punya padanan di bank soal, jadi tidak
      // disimpan sebagai kuis yang bisa dilanjutkan.
      discardProgress();
      return;
    }
    resume = InProgressQuiz(
      categoryId: id,
      difficulty: selectedDifficulty,
      index: questionIndex,
      answers: List<int?>.from(answers),
      submitted: List<bool>.from(_submitted),
      questionOrder: List<int>.from(_questionOrder),
      optionOrders: [for (final order in _optionOrders) List<int>.from(order)],
      elapsed: currentElapsed,
    );
    _progress.saveResume(resume);
    notifyListeners();
  }

  void discardProgress() {
    resume = null;
    _progress.saveResume(null);
    notifyListeners();
  }

  void continueAdventure() {
    final saved = resume;
    if (saved == null) return;
    setDifficulty(saved.difficulty);
    startQuiz(
      saved.categoryId,
      difficulty: saved.difficulty,
      startIndex: saved.index,
      existing: List<int?>.from(saved.answers),
      submitted: List<bool>.from(saved.submitted),
      questionOrder: List<int>.from(saved.questionOrder),
      optionOrders: [
        for (final order in saved.optionOrders) List<int>.from(order),
      ],
      elapsed: saved.elapsed,
    );
  }

  void selectAnswer(int option) {
    if (currentQuestionLocked) return;
    answers[questionIndex] = option;
    notifyListeners();
  }

  bool get hasSelected =>
      questionIndex < answers.length && answers[questionIndex] != null;

  Question? get currentQuestion {
    if (questionIndex >= _activeQuestions.length) return null;
    return _activeQuestions[questionIndex];
  }

  int get totalQuestions => _activeQuestions.length;

  void submitCurrent() {
    final q = currentQuestion;
    if (q == null) return;
    if (questionIndex < _submitted.length) {
      _submitted[questionIndex] = true;
    }
    showingCorrect = answers[questionIndex] == q.correctIndex;
    notifyListeners();
  }

  /// Mengunci soal saat waktu habis (U-06). Soal yang belum dijawab tetap
  /// dihitung sebagai tidak terjawab.
  void timeoutCurrent() {
    if (currentQuestionLocked) return;
    if (questionIndex < _submitted.length) {
      _submitted[questionIndex] = true;
    }
    final q = currentQuestion;
    if (q != null) {
      showingCorrect = answers[questionIndex] == q.correctIndex;
    }
    notifyListeners();
  }

  bool get isLastQuestion {
    if (activeCategory == null) return true;
    return questionIndex >= _activeQuestions.length - 1;
  }

  void nextQuestion() {
    if (isLastQuestion) {
      finishQuiz();
    } else {
      questionIndex += 1;
      notifyListeners();
    }
  }

  void finishQuiz() {
    final id = activeCategory;
    final list = _activeQuestions;
    if (id == null || list.isEmpty) return;
    var correct = 0;
    for (var i = 0; i < list.length; i++) {
      if (answers[i] == list[i].correctIndex) correct++;
    }
    final result = QuizResult(
      categoryId: id,
      score: ((correct / list.length) * 100).round(),
      correct: correct,
      total: list.length,
      duration: currentElapsed,
      playedAt: DateTime.now(),
      difficulty: selectedDifficulty,
      // Sesi latihan soal salah memakai soal di luar bank, jadi rinciannya
      // tidak bisa disusun ulang dari bank dan sengaja tidak disimpan (U-11).
      answers: _customSession ? const <int?>[] : List<int?>.from(answers),
      questionOrder: _customSession
          ? const <int>[]
          : List<int>.from(_questionOrder),
      optionOrders: _customSession
          ? const <List<int>>[]
          : [for (final order in _optionOrders) List<int>.from(order)],
    );
    _review = <QuizReview>[
      for (var i = 0; i < list.length; i++)
        QuizReview(
          question: list[i],
          chosenIndex: i < answers.length ? answers[i] : null,
        ),
    ];
    lastResult = result;
    resume = null;
    _progress.saveResume(null);
    onCompleted?.call(result);
    notifyListeners();
  }

  /// Mengulang hanya soal yang dijawab salah pada kuis terakhir.
  ///
  /// Mengembalikan `false` bila tidak ada soal salah untuk diulang.
  bool retryWrongOnly() {
    final wrong = wrongReview;
    if (wrong.isEmpty) return false;

    _customSession = true;
    _activeQuestions = <Question>[for (final item in wrong) item.question];
    _questionOrder = List<int>.generate(_activeQuestions.length, (i) => i);
    _optionOrders = <List<int>>[
      for (final question in _activeQuestions)
        List<int>.generate(question.options.length, (i) => i),
    ];
    answers = List<int?>.filled(_activeQuestions.length, null);
    _submitted = List<bool>.filled(_activeQuestions.length, false);
    questionIndex = 0;
    lastResult = null;
    _review = <QuizReview>[];
    _elapsedBeforeResume = Duration.zero;
    quizStartedAt = DateTime.now();
    discardProgress();
    notifyListeners();
    return true;
  }
}
