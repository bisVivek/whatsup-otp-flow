import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../domain/phone_number.dart';
import 'auth_controller.dart';

class OtpFlowState {
  const OtpFlowState({
    this.phone = '',
    this.busy = false,
    this.error,
    this.resendAt,
    this.attemptsLeft,
    this.failures = 0,
  });

  /// Normalized WhatsApp number, digits only (919876543210).
  final String phone;
  final bool busy;
  final String? error;
  final DateTime? resendAt;
  final int? attemptsLeft;

  /// Goes up on every rejected code, so the code field knows to clear.
  final int failures;

  bool get codeSent => resendAt != null;

  /// "+91 98765 43210", for showing back to the person.
  String get displayPhone => phone.isEmpty ? '' : PhoneNumber.format(phone);

  OtpFlowState copyWith({
    String? phone,
    bool? busy,
    String? Function()? error,
    DateTime? resendAt,
    int? Function()? attemptsLeft,
    int? failures,
  }) {
    return OtpFlowState(
      phone: phone ?? this.phone,
      busy: busy ?? this.busy,
      error: error != null ? error() : this.error,
      resendAt: resendAt ?? this.resendAt,
      attemptsLeft: attemptsLeft != null ? attemptsLeft() : this.attemptsLeft,
      failures: failures ?? this.failures,
    );
  }
}

/// Drives the two step sign in: WhatsApp number, then the 6-digit code.
class OtpFlowController extends Notifier<OtpFlowState> {
  @override
  OtpFlowState build() => const OtpFlowState();

  /// Returns true when a code is on its way.
  Future<bool> requestCode(String rawPhone) async {
    final phone = PhoneNumber.normalize(rawPhone);
    if (phone == null) {
      state = state.copyWith(error: () => 'Enter a valid WhatsApp number');
      return false;
    }
    return _send(phone);
  }

  Future<bool> resend() => _send(state.phone);

  Future<bool> verify(String code) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, error: () => null);

    try {
      final session = await ref
          .read(authRepositoryProvider)
          .verifyCode(phone: state.phone, code: code);
      await ref.read(authControllerProvider.notifier).signIn(session);
      state = const OtpFlowState();
      return true;
    } on ApiException catch (e) {
      final left = e.data['attempts_left'];
      state = state.copyWith(
        busy: false,
        error: () => e.firstErrorFor('code') ?? e.message,
        attemptsLeft: () => left is int ? left : null,
        failures: state.failures + 1,
      );
      return false;
    }
  }

  void clearError() {
    if (state.error != null) state = state.copyWith(error: () => null);
  }

  Future<bool> _send(String phone) async {
    if (state.busy) return false;
    state = state.copyWith(phone: phone, busy: true, error: () => null);

    try {
      final ticket = await ref.read(authRepositoryProvider).requestCode(phone);
      state = OtpFlowState(
        phone: phone,
        resendAt: DateTime.now().add(ticket.resendIn),
      );
      return true;
    } on ApiException catch (e) {
      final retry = e.data['retry_after'];
      state = state.copyWith(
        busy: false,
        error: () => e.firstErrorFor('phone') ?? e.message,
        resendAt: retry is int
            ? DateTime.now().add(Duration(seconds: retry))
            : null,
      );
      return false;
    }
  }
}

final otpFlowControllerProvider =
    NotifierProvider<OtpFlowController, OtpFlowState>(OtpFlowController.new);
