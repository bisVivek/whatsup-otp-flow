import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keeps the API token in the Keychain (iOS) or Keystore (Android).
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;
  static const _key = 'auth_token';

  String? _cached;
  bool _loaded = false;

  Future<String?> read() async {
    if (_loaded) return _cached;
    _cached = await _storage.read(key: _key);
    _loaded = true;
    return _cached;
  }

  Future<void> write(String token) async {
    _cached = token;
    _loaded = true;
    await _storage.write(key: _key, value: token);
  }

  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    await _storage.delete(key: _key);
  }
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(const FlutterSecureStorage()),
);
