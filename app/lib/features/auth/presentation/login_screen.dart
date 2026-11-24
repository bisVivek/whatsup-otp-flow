import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../ui/app_button.dart';
import '../../../ui/app_text_field.dart';
import '../../../ui/inline_message.dart';
import '../application/otp_flow_controller.dart';
import 'widgets/auth_layout.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: ref.read(otpFlowControllerProvider).displayPhone);
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final sent = await ref.read(otpFlowControllerProvider.notifier).requestCode(_phone.text);
    if (sent && mounted) context.push(Routes.verify);
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(otpFlowControllerProvider);

    return CupertinoPageScaffold(
      child: AuthLayout(
        title: 'Sign in',
        subtitle: const Text("Enter your WhatsApp number and we'll send you a 6-digit code on WhatsApp"),
        footer: const Text(
          "Invite only. If nobody invited you, the app isn't ready for you either",
        ),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _phone,
                placeholder: 'WhatsApp number',
                icon: CupertinoIcons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.go,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\s-]')),
                  LengthLimitingTextInputFormatter(20),
                ],
                hasError: flow.error != null,
                enabled: !flow.busy,
                onChanged: (_) => ref.read(otpFlowControllerProvider.notifier).clearError(),
                onSubmitted: (_) => _submit(),
              ),
              InlineMessage(message: flow.error),
              const SizedBox(height: 16),
              AppButton(
                label: 'Send code',
                loading: flow.busy,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
