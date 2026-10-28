import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kage/theme/app_theme.dart';
import 'package:kage/widgets/kage_tappable.dart';

Future<void> _pumpTappable(
  WidgetTester tester, {
  required VoidCallback? onTap,
  FocusNode? focusNode,
  String? semanticLabel,
  Widget child = const SizedBox(width: 120, height: 40, child: Text('Tekan')),
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Center(
          child: KageTappable(
            onTap: onTap,
            focusNode: focusNode,
            semanticLabel: semanticLabel,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('U-01 KageTappable', () {
    testWidgets('ketukan memanggil onTap', (tester) async {
      var tapped = false;
      await _pumpTappable(tester, onTap: () => tapped = true);

      await tester.tap(find.byType(KageTappable));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('efek tekan terlihat selama jari menekan', (tester) async {
      await _pumpTappable(tester, onTap: () {});

      DecoratedBox? overlayOf() {
        final matches = find.descendant(
          of: find.byType(KageTappable),
          matching: find.byType(DecoratedBox),
        );
        if (matches.evaluate().isEmpty) return null;
        return tester.widget<DecoratedBox>(matches.first);
      }

      expect(overlayOf(), isNull, reason: 'tanpa tekanan tidak ada lapisan');

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(KageTappable)),
      );
      await tester.pump();

      final overlay = overlayOf();
      expect(overlay, isNotNull, reason: 'lapisan sorot muncul saat ditekan');
      expect(
        (overlay!.decoration as BoxDecoration).color,
        isNotNull,
        reason: 'lapisan sorot punya warna, bukan transparan',
      );

      await gesture.up();
      await tester.pumpAndSettle();
      expect(overlayOf(), isNull, reason: 'lapisan hilang setelah dilepas');
    });

    testWidgets('bisa diaktifkan dengan Enter saat fokus', (tester) async {
      var tapped = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await _pumpTappable(
        tester,
        onTap: () => tapped = true,
        focusNode: focusNode,
      );

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('bisa diaktifkan dengan Space saat fokus', (tester) async {
      var tapped = false;
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await _pumpTappable(
        tester,
        onTap: () => tapped = true,
        focusNode: focusNode,
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('tanpa onTap tidak bisa difokus dan bukan tombol', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);

      await _pumpTappable(tester, onTap: null, focusNode: focusNode);

      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isFalse);

      expect(
        tester.getSemantics(find.byType(KageTappable)),
        matchesSemantics(hasTapAction: false, isButton: false),
      );

      semantics.dispose();
    });

    testWidgets('semantik tombol dan label disediakan', (tester) async {
      final semantics = tester.ensureSemantics();

      await _pumpTappable(
        tester,
        onTap: () {},
        semanticLabel: 'Mulai kuis Sains',
        child: const Icon(Icons.play_arrow_rounded),
      );

      expect(
        tester.getSemantics(find.byType(KageTappable)),
        matchesSemantics(
          isButton: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
          label: 'Mulai kuis Sains',
        ),
      );

      semantics.dispose();
    });

    testWidgets('kursor hover tidak menggeser atau mengubah lebar anak', (
      tester,
    ) async {
      // Anak berukuran intrinsik seperti kartu kategori (ikon + label) di
      // dalam sel yang lebih lebar: bila batasan dilonggarkan dan anak
      // ditempatkan di topStart, isinya bergeser ke kiri saat hover.
      final boxKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: KageTappable(
                    onTap: () {},
                    child: Column(
                      key: boxKey,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.science, size: 32),
                        SizedBox(height: 6),
                        Text('Sains'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final before = tester.getRect(find.byKey(boxKey));
      expect(before.width, greaterThan(0));

      final gesture = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byKey(boxKey)));
      await tester.pump();

      // Sorotan hover tetap muncul…
      expect(
        find.descendant(
          of: find.byType(KageTappable),
          matching: find.byType(DecoratedBox),
        ),
        findsOneWidget,
      );
      // …tanpa mengubah geometri anak.
      expect(tester.getRect(find.byKey(boxKey)), before);
    });
  });
}
