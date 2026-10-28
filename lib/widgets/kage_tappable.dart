import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';

/// Pembungkus elemen yang bisa ditekan.
///
/// `GestureDetector` tidak memberi efek tekan, tidak bisa dijangkau dengan Tab
/// di web, dan tidak punya semantik tombol. Widget ini memakai [InkWell] untuk
/// menangani ketukan, fokus keyboard, Enter/Space, kursor, dan semantiknya,
/// lalu menggambar lapisan sorot **di atas** isi sehingga efek tekan tetap
/// terlihat meski anaknya berupa kontainer berlatar pekat.
class KageTappable extends StatefulWidget {
  const KageTappable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.semanticLabel,
    this.selected,
    this.focusNode,
    this.autofocus = false,
    this.excludeChildSemantics = false,
  });

  final Widget child;

  /// `null` membuat elemen tidak bisa ditekan sekaligus menonaktifkan semantik
  /// tombol dan kursor tangan.
  final VoidCallback? onTap;

  /// Sudut sorot. Bila kosong, dipakai 12 seperti kartu lain.
  final BorderRadius? borderRadius;

  /// Label pembaca layar untuk elemen yang isinya tidak berbicara sendiri,
  /// misalnya tombol berisi ikon saja. Bila kosong, teks di dalam anak yang
  /// dibacakan sehingga label tidak tertulis dua kali.
  final String? semanticLabel;

  /// Menandai keadaan terpilih, misalnya tab atau opsi jawaban aktif.
  final bool? selected;

  final FocusNode? focusNode;
  final bool autofocus;

  /// Mengganti isi anak sebagai bahan bacaan pembaca layar dengan
  /// [semanticLabel] saja. Dipakai pada kartu yang isinya banyak supaya
  /// TalkBack tidak membacakan potongan-potongan teks terpisah.
  final bool excludeChildSemantics;

  @override
  State<KageTappable> createState() => _KageTappableState();
}

class _KageTappableState extends State<KageTappable> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;

  bool get _enabled => widget.onTap != null;

  /// Sorotan keyboard hanya muncul untuk pengguna keyboard, bukan setelah
  /// sentuhan, supaya opsi yang dipilih tidak terlihat "menyala" terus.
  bool get _keyboardFocus =>
      _focused &&
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  Color? get _overlay {
    if (!_enabled) return null;
    if (_pressed) return AppColors.primary.withValues(alpha: 0.20);
    if (_keyboardFocus) return AppColors.primary.withValues(alpha: 0.28);
    if (_hovered) return AppColors.primary.withValues(alpha: 0.08);
    return null;
  }

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_onHighlightModeChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_onHighlightModeChanged);
    super.dispose();
  }

  void _onHighlightModeChanged(FocusHighlightMode mode) {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);
    final overlay = _overlay;

    // `Listener` dipakai untuk mengikuti jari secara pasti; sorotan bawaan
    // InkWell baru selesai setelah animasi splash, dan tertimbun latar anak
    // yang pekat.
    Widget content = Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: radius,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        canRequestFocus: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        onHover: (value) {
          if (value == _hovered) return;
          setState(() => _hovered = value);
        },
        onFocusChange: (value) {
          if (value == _focused) return;
          setState(() => _focused = value);
        },
        child: widget.child,
      ),
    );

    // Stack dibangun sejak awal, bukan hanya saat hover/tekan, supaya bentuk
    // pohon widget tidak berubah saat kursor masuk. `StackFit.passthrough`
    // meneruskan batasan orang tua apa adanya sehingga ukuran dan posisi anak
    // tetap persis sama sebelum dan sesudah sorotan muncul.
    content = Stack(
      fit: StackFit.passthrough,
      children: [
        content,
        if (overlay != null)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: overlay,
                  borderRadius: radius,
                ),
              ),
            ),
          ),
      ],
    );

    final excludeChildren = widget.excludeChildSemantics;
    return Semantics(
      button: _enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      excludeSemantics: excludeChildren,
      // Aksi ketuk dipasang ulang karena semantik anak ikut dibuang.
      onTap: excludeChildren ? widget.onTap : null,
      child: content,
    );
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }
}
