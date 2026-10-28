import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kage/data/quiz_bank.dart';
import 'package:kage/models/models.dart';

Iterable<File> _bankFiles() =>
    Directory('assets/data')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

CategoryId? _categoryFromFileName(String path) {
  final name = path.split(Platform.pathSeparator).last;
  final match = RegExp(r'^questions_(\w+)\.json$').firstMatch(name);
  if (match == null) return null;
  for (final id in CategoryId.values) {
    if (id.name == match.group(1)) return id;
  }
  return null;
}

void main() {
  group('D-02 skema bank soal JSON', () {
    test('setiap kategori punya berkas dengan nama yang dikenal', () {
      final files = _bankFiles().toList();
      expect(files, isNotEmpty);

      for (final file in files) {
        expect(
          _categoryFromFileName(file.path),
          isNotNull,
          reason: '${file.path} tidak memakai pola questions_<kategori>.json',
        );
      }

      final covered = files.map((f) => _categoryFromFileName(f.path)).toSet();
      for (final categoryId in CategoryId.values) {
        expect(
          covered,
          contains(categoryId),
          reason: 'kategori ${categoryId.name} belum punya berkas bank soal',
        );
      }
    });

    test('seluruh berkas lolos validasi dan setiap soal sah', () {
      for (final file in _bankFiles()) {
        final categoryId = _categoryFromFileName(file.path)!;
        final source = file.readAsStringSync();
        final decoded = jsonDecode(source);

        expect(
          validateQuizBank(
            decoded,
            sourceName: file.path,
            expectedCategory: categoryId,
          ),
          isEmpty,
          reason: '${file.path} tidak sesuai skema',
        );

        final bank = parseQuizBank(
          source,
          sourceName: file.path,
          expectedCategory: categoryId,
        );
        expect(bank.schemaVersion, quizBankSchemaVersion);
        expect(bank.categoryId, categoryId);
        expect(bank.questions, isNotEmpty);

        for (final question in bank.questions) {
          expect(question.prompt.trim(), isNotEmpty);
          expect(question.options.length, greaterThanOrEqualTo(2));
          expect(
            question.options.every((option) => option.trim().isNotEmpty),
            isTrue,
            reason: 'ada pilihan kosong pada "${question.prompt}"',
          );
          expect(
            question.options.toSet(),
            hasLength(question.options.length),
            reason: 'ada pilihan duplikat pada "${question.prompt}"',
          );
          expect(
            question.correctIndex,
            inInclusiveRange(0, question.options.length - 1),
          );
          expect(question.explanation.trim(), isNotEmpty);
          expect(question.funFact.trim(), isNotEmpty);
        }
      }
    });

    test('tidak ada soal duplikat di dalam satu kategori', () {
      for (final file in _bankFiles()) {
        final decoded =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final questions = (decoded['questions'] as List).cast<Map>();

        final seen = <String>{};
        for (final question in questions) {
          final key =
              '${decoded['categoryId']}:${question['difficulty']}:'
              '${question['prompt']}';
          expect(
            seen.add(key),
            isTrue,
            reason: 'soal duplikat di ${file.path}: ${question['prompt']}',
          );
        }
      }
    });

    test('validator menolak berkas yang tidak sesuai skema', () {
      const validQuestion = {
        'difficulty': 'pemula',
        'prompt': 'Soal contoh?',
        'options': ['A', 'B', 'C', 'D'],
        'correctIndex': 0,
        'explanation': 'Penjelasan.',
        'funFact': 'Fakta.',
      };
      Object? bankWith(Map<String, Object?> overrides) => {
        'schemaVersion': quizBankSchemaVersion,
        'categoryId': 'sains',
        ...overrides,
      };
      List<String> errorsOf(Object? decoded) => validateQuizBank(
        decoded,
        sourceName: 'uji.json',
        expectedCategory: CategoryId.sains,
      );

      expect(
        errorsOf(
          bankWith({
            'questions': [validQuestion],
          }),
        ),
        isEmpty,
      );

      expect(
        errorsOf(
          bankWith({
            'schemaVersion': quizBankSchemaVersion + 1,
            'questions': [validQuestion],
          }),
        ),
        contains(contains('tidak didukung')),
      );

      expect(
        errorsOf(
          bankWith({
            'categoryId': 'logika',
            'questions': [validQuestion],
          }),
        ),
        contains(contains('"categoryId"')),
      );

      expect(
        errorsOf(bankWith({'questions': <Object>[]})),
        contains(contains('minimal satu soal')),
      );

      expect(
        errorsOf(
          bankWith({
            'questions': [
              {...validQuestion, 'correctIndex': 9},
            ],
          }),
        ),
        contains(contains('di luar rentang')),
      );

      expect(
        errorsOf(
          bankWith({
            'questions': [
              {
                ...validQuestion,
                'options': ['A', '  '],
                'correctIndex': 1,
              },
            ],
          }),
        ),
        contains(contains('kosong')),
      );

      expect(
        errorsOf(
          bankWith({
            'questions': [
              validQuestion,
              {
                ...validQuestion,
                'options': ['X', 'Y', 'Z'],
              },
            ],
          }),
        ),
        contains(contains('duplikat')),
      );

      expect(
        errorsOf(
          bankWith({
            'questions': [
              {...validQuestion, 'difficulty': 'sulit'},
            ],
          }),
        ),
        contains(contains('"difficulty" tidak dikenal')),
      );
    });

    testWidgets('bank soal benar-benar dimuat lewat asset bundle aplikasi', (
      tester,
    ) async {
      final bank = await loadQuizBank();

      expect(bank.keys, containsAll(CategoryId.values));
      expect(bank[CategoryId.sains], hasLength(30));
      expect(bank[CategoryId.logika], hasLength(10));
    });

    test('parseQuizBank melempar pesan yang menyebut berkas', () {
      const broken =
          '{"schemaVersion":1,"categoryId":"sains",'
          '"questions":[{"difficulty":"pemula","prompt":"","options":["A"],'
          '"correctIndex":0,"explanation":"","funFact":""}]}';

      expect(
        () => parseQuizBank(
          broken,
          sourceName: 'assets/data/questions_sains.json',
          expectedCategory: CategoryId.sains,
        ),
        throwsA(
          isA<QuizBankFormatException>()
              .having((e) => e.sourceName, 'sourceName', contains('sains'))
              .having((e) => e.errors, 'errors', isNotEmpty),
        ),
      );
    });
  });
}
