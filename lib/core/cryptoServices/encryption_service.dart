import 'package:mobile_app_braket/domain/models/encryption_result.dart';

abstract class EncryptionService {
  Future<EncryptionResult> encrypt(String plaintext, String key);
  Future<String> decrypt(String ciphertext, String key, String messageNonce);
}
