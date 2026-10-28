import 'package:flutter/material.dart';

import 'package:kage/theme/app_colors.dart';
import 'package:kage/widgets/kage_tappable.dart';
import 'package:kage/theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.onChanged,
    this.onFocusChange,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;

  /// Dipakai untuk memeriksa isian saat pengguna masih mengetik.
  final ValueChanged<String>? onChanged;

  /// Dipakai halaman untuk memvalidasi kolom saat fokus berpindah (U-09).
  final ValueChanged<bool>? onFocusChange;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    super.dispose();
  }

  void _handleFocus() {
    setState(() {});
    widget.onFocusChange?.call(_focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final focused = _focusNode.hasFocus;
    final borderColor = hasError
        ? AppColors.primaryText
        : focused
        ? AppColors.gold
        : AppColors.borderStrong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: focused && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.10),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: hasError
                    ? AppColors.primaryText
                    : focused
                    ? AppColors.gold
                    : AppColors.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscure && widget.onToggleObscure != null,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  autofillHints: widget.autofillHints,
                  enableSuggestions: !widget.obscure,
                  autocorrect: !widget.obscure,
                  style: AppTextStyles.body,
                  cursorColor: AppColors.gold,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.bodyMuted,
                  ),
                ),
              ),
              if (widget.onToggleObscure != null)
                KageTappable(
                  onTap: widget.onToggleObscure,
                  borderRadius: BorderRadius.circular(24),
                  semanticLabel: widget.obscure
                      ? 'Tampilkan password'
                      : 'Sembunyikan password',
                  excludeChildSemantics: true,
                  child: SizedBox(
                    // Area sentuh minimal 48x48 dp (U-02).
                    width: 48,
                    height: 48,
                    child: Icon(
                      widget.obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 0, 0),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 13,
                  color: AppColors.primaryText,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: AppTextStyles.captionPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
