import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../ui/app_button.dart';
import '../../../ui/inline_message.dart';
import '../../../ui/otp_field.dart';
import '../application/otp_flow_controller.dart';
import 'widgets/auth_layout.dart';

class VerifyCodeScreen extends ConsumerStatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  ConsumerState<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends ConsumerState<VerifyCodeScreen> {
  String _code = '';

  Future<void> _verify([String? value]) async {
    final code = value ?? _code;
    if (code.length != 6) return;
    final ok = await ref.read(otpFlowControllerProvider.notifier).verify(code);
    if (!ok) HapticFeedback.mediumImpact();
    // On success the router moves to Home by itself.
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(otpFlowControllerProvider);
    final notifier = ref.read(otpFlowControllerProvider.notifier);

    final error = switch ((flow.error, flow.attemptsLeft)) {
      (final String e, final int left) when left > 0 =>
        '$e. ${left == 1 ? '1 try' : '$left tries'} left',
      (final String e, _) => e,
      _ => null,
    };

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: context.c(AppColors.page),
        border: null,
        previousPageTitle: 'Number',
      ),
      child: AuthLayout(
        showBrand: false,
        title: 'Check WhatsApp',
        subtitle: Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'We sent a 6-digit code on WhatsApp to '),
            TextSpan(
              text: flow.displayPhone,
              style: TextStyle(
                color: context.c(AppColors.textPrimary),
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ),
        footer: const Text('Codes expire after 5 minutes, like most promises'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OtpField(
              hasError: flow.error != null,
              // Stays enabled while verifying so it keeps focus;
              // the controller ignores input until the answer is back.
              clearSignal: flow.failures,
              onChanged: (v) {
                setState(() => _code = v);
                notifier.clearError();
              },
              onCompleted: _verify,
            ),
            InlineMessage(message: error),
            const SizedBox(height: AppSpace.x4),
            AppButton(
              label: 'Verify',
              loading: flow.busy,
              onPressed: _code.length == 6 ? _verify : null,
            ),
            const SizedBox(height: AppSpace.x3),
            Center(
              child: _ResendButton(
                resendAt: flow.resendAt,
                busy: flow.busy,
                onResend: notifier.resend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Resend in 0:24", then a tappable "Resend code".
class _ResendButton extends StatefulWidget {
  const _ResendButton({
    required this.resendAt,
    required this.busy,
    required this.onResend,
  });

  final DateTime? resendAt;
  final bool busy;
  final Future<bool> Function() onResend;

  @override
  State<_ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<_ResendButton> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final at = widget.resendAt;
    final left = at == null ? Duration.zero : at.difference(DateTime.now());

    if (left > Duration.zero) {
      final s = left.inSeconds + 1;
      final label = 'Resend in ${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
      return SizedBox(
        height: 32,
        child: Center(
          child: Text(
            label,
            style: AppText.callout.copyWith(
              color: context.c(AppColors.textMuted),
              fontFeatures: AppText.tabular,
            ),
          ),
        ),
      );
    }

    return AppButton.plain(
      label: 'Resend code',
      onPressed: widget.busy ? null : widget.onResend,
    );
  }
}
