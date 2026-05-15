import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';

class QkdSessionStorageImpl implements QkdSessionStorage{

  final FlutterSecureStorage _storage;

  static const _sessionIdKey = "qkd_session_id";
  static const _sessionStatusKey = "qkd_session_status";
  static const _sessionExpiresAtKey = "qkd_session_expires_at";

  QkdSessionStorageImpl(this._storage);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _sessionIdKey);
    await _storage.delete(key: _sessionStatusKey);
    await _storage.delete(key: _sessionExpiresAtKey);
  }

  @override
  Future<String?> getSessionId() async {
    return await _storage.read(key: _sessionIdKey);
  }

  @override
  Future<void> saveSessionId(String sesionId) async {
    await _storage.write(key: _sessionIdKey, value: sesionId);
  }

  @override
  Future<void> saveSessionStatus(String status) async {
    await _storage.write(key: _sessionStatusKey, value: status);
  }

  @override
  Future<String?> getSessionStatus() async {
    return await _storage.read(key: _sessionStatusKey);
  }

  @override
  Future<void> saveSessionExpiresAt(String expiresAt) async {
    await _storage.write(key: _sessionExpiresAtKey, value: expiresAt);
  }

  @override
  Future<String?> getSessionExpiresAt() async {
    return await _storage.read(key: _sessionExpiresAtKey);
  }
}