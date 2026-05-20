import 'dart:convert';
import 'dart:math';
import 'package:mobile_app_braket/domain/external_services/encryption_service.dart';
import 'package:mobile_app_braket/domain/models/encryption_result.dart';

class EncryptionServiceImpl implements EncryptionService {
  @override
  Future<EncryptionResult> encrypt(String plaintext, String key) async {
    // tu python z aes
    final bytes = utf8.encode(plaintext);
    final ciphertext = base64Encode(bytes);
    final nonceBytes = List<int>.generate(12, (_) => Random.secure().nextInt(256));
    final nonce = base64UrlEncode(nonceBytes);
    return EncryptionResult(ciphertext: ciphertext, messageNonce: nonce);
  }

  @override
  Future<String> decrypt(String ciphertext, String key, String messageNonce) async {
    // Placeholder
    try {
      final bytes = base64Decode(ciphertext);
      final plaintext = utf8.decode(bytes);
      return plaintext;
    } catch (_) {
      return '';
    }
  }
}
