import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';

/// A single grouped text field, 52 tall, card surface.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.hasError = false,
    this.enabled = true,
    this.autofocus = false,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String placeholder;
  final IconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool enabled;
  final bool autofocus;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final muted = context.c(AppColors.textMuted);

    return AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.curve,
      height: 52,
      decoration: BoxDecoration(
        color: context.c(AppColors.card),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(
          color: hasError
              ? context.c(AppColors.negative)
              : context.c(AppColors.hairline),
        ),
      ),
      child: CupertinoTextField(
        controller: controller,
        enabled: enabled,
        autofocus: autofocus,
        placeholder: placeholder,
        placeholderStyle: AppText.body.copyWith(color: muted),
        style: AppText.body.copyWith(color: context.c(AppColors.textPrimary)),
        cursorColor: context.c(AppColors.accent),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autofillHints: autofillHints,
        autocorrect: false,
        enableSuggestions: false,
        inputFormatters: inputFormatters,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        decoration: null,
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
        prefix: icon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: AppSpace.x4),
                child: Icon(icon, size: 20, color: muted),
              ),
        clearButtonMode: OverlayVisibilityMode.editing,
      ),
    );
  }
}
