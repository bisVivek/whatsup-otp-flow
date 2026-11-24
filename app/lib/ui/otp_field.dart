import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';

/// Six boxes over one hidden text field, so paste and
/// iOS "From Messages / Mail" autofill both work.
class OtpField extends StatefulWidget {
  const OtpField({
    super.key,
    required this.onCompleted,
    this.length = 6,
    this.hasError = false,
    this.enabled = true,
    this.clearSignal = 0,
    this.onChanged,
  });

  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;
  final bool enabled;

  /// Change this value to empty the field, e.g. after a wrong code.
  final int clearSignal;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(OtpField old) {
    super.didUpdateWidget(old);
    if (old.clearSignal != widget.clearSignal) {
      _controller.clear();
      // After the frame, so the field is enabled again when focus arrives.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted(value);
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
    final active = _focus.hasFocus ? text.length.clamp(0, widget.length - 1) : -1;

    return Semantics(
      label: 'Verification code, ${widget.length} digits',
      textField: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _focus.requestFocus(),
        child: Stack(
          children: [
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) SizedBox(width: i == widget.length ~/ 2 ? AppSpace.x4 : AppSpace.x2),
                  Expanded(
                    child: _Box(
                      digit: i < text.length ? text[i] : '',
                      active: i == active,
                      hasError: widget.hasError,
                    ),
                  ),
                ],
              ],
            ),
            // The real input. Invisible, laid over the boxes to take taps.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: CupertinoTextField(
                  controller: _controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  maxLength: widget.length,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  decoration: null,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _handleChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.digit,
    required this.active,
    required this.hasError,
  });

  final String digit;
  final bool active;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final border = hasError
        ? context.c(AppColors.negative)
        : active
            ? context.c(AppColors.accent)
            : context.c(AppColors.hairline);

    return AnimatedContainer(
      duration: AppMotion.quick,
      curve: AppMotion.curve,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.c(AppColors.card),
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: border, width: active || hasError ? 1.5 : 1),
      ),
      child: Text(
        digit,
        style: AppText.otpDigit.copyWith(color: context.c(AppColors.textPrimary)),
      ),
    );
  }
}
