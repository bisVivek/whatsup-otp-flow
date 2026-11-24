import 'package:app_login/core/network/api_exception.dart';
import 'package:app_login/core/storage/token_storage.dart';
import 'package:app_login/features/auth/data/auth_repository.dart';
import 'package:app_login/features/auth/domain/user.dart';

const testUser = User(
  id: 1,
  name: 'Deepak Kumar',
  email: 'deepak.kumar@gmail.com',
  phone: '919999999999',
);

class MemoryTokenStorage implements TokenStorage {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;

  @override
  Future<void> clear() async => token = null;
}

/// Accepts [validCode] for [testUser.phone], rejects everything else
/// the same way the Laravel API does.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.validCode = '123456'});

  final String validCode;
  int attemptsLeft = 5;
  int requests = 0;

  @override
  Future<OtpTicket> requestCode(String phone) async {
    requests++;
    return const OtpTicket(
      expiresIn: Duration(minutes: 5),
      resendIn: Duration(seconds: 30),
    );
  }

  @override
  Future<AuthSession> verifyCode({required String phone, required String code}) async {
    if (phone == testUser.phone && code == validCode) {
      return const AuthSession(token: '1|token', user: testUser);
    }
    attemptsLeft--;
    throw ApiException(
      "That code isn't right",
      statusCode: 422,
      fieldErrors: const {'code': ["That code isn't right"]},
      data: {'attempts_left': attemptsLeft},
    );
  }

  @override
  Future<User> me() async => testUser;

  @override
  Future<void> logout() async {}
}
