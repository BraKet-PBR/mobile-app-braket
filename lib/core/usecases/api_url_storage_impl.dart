import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_app_braket/core/usecases/api_url_storage.dart';

class ApiUrlStorageImpl implements ApiUrlStorage {
  final FlutterSecureStorage _storage;
  static const _key = 'apiUrl';

  ApiUrlStorageImpl(this._storage);

  @override
  Future<String?> getApiUrl() async {
    final url = await _storage.read(key: _key);
    print('ApiUrlStorageImpl: odczytano apiUrl = $url'); //TODO: delete
    return url;
  }

  @override
  Future<void> saveApiUrl(String url) async {
    await _storage.write(key: _key, value: url);
    print('ApiUrlStorageImpl: zapisano apiUrl = $url'); //TODO: delete
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
