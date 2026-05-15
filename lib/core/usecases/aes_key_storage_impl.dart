import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app_braket/core/usecases/aes_key_storage.dart';

class AESKeyStorageImpl implements AESKeyStorage {
  final FlutterSecureStorage _storage;

  //TODO: to do pobrania jakoś z symulatora qkd
  static const _aesKeyStorageKey = 'aes_encryption_key';

  AESKeyStorageImpl(this._storage);

  @override
  Future<void> clear() async {
    await _storage.delete(key: _aesKeyStorageKey);
  }

  @override
  Future<String?> getKey() async {
    return await _storage.read(key: _aesKeyStorageKey);
  }

  @override
  Future<void> saveKey(String key) async {
    await _storage.write(key: _aesKeyStorageKey, value: key);
  }
}
