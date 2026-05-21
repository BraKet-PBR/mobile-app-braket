import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile_app_braket/core/usecases/token_provider.dart';


class TokenProviderImpl implements TokenProvider {
  final FlutterSecureStorage _storage;

  TokenProviderImpl(this._storage);

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: 'apiToken');
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'apiToken', value: token);
  }

  @override
  Future<String?> getUsername() async {
    final token = await getToken();

    if (token == null){
      return null;
    }

    final decoded = JwtDecoder.decode(token);
    return decoded['sub'];

  }

  @override
  Future<bool> isValid(String token) async {
    try{
      return !JwtDecoder.isExpired(token);
    } on FormatException{
      return false;
    }
  }
}