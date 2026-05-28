import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app_braket/core/usecases/api_url_storage.dart';

class ApiUrlStorageImpl implements ApiUrlStorage {
  final FlutterSecureStorage _storage;
  static const _key = 'apiUrl';

  ApiUrlStorageImpl(this._storage);

  @override
  Future<String?> getApiUrl() async {
    return await _storage.read(key: _key);
  }

  @override
  Future<void> saveApiUrl(String url) async {
    await _storage.write(key: _key, value: url);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
