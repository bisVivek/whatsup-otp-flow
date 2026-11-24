import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/network/api_client.dart';
import '../domain/user.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  Future<OtpTicket> requestCode(String phone) async {
    final json = await _api.post('/auth/otp/request', {'phone': phone});
    return OtpTicket.fromJson(json);
  }

  Future<AuthSession> verifyCode({
    required String phone,
    required String code,
  }) async {
    final json = await _api.post('/auth/otp/verify', {
      'phone': phone,
      'code': code,
      'device_name': Env.deviceName,
    });
    return AuthSession.fromJson(json);
  }

  Future<User> me() async {
    final json = await _api.get('/me');
    return User.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<void> logout() => _api.post('/auth/logout');
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);
