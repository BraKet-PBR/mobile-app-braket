import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:mobile_app_braket/core/cryptoServices/encryption_service.dart';
import 'package:mobile_app_braket/domain/models/encryption_result.dart';

class EncryptionServiceImpl implements EncryptionService {
  static const int _nonceLength = 12;

  final AesGcm _aesGcm = AesGcm.with256bits(nonceLength: _nonceLength);

  @override
  Future<EncryptionResult> encrypt(String plaintext, String key) async {
    final secretBox = await _aesGcm.encrypt(
      utf8.encode(plaintext),
      secretKey: SecretKey(_decodeKey(key)),
    );

    final ciphertextWithMac = [
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ];

    return EncryptionResult(
      ciphertext: base64Encode(ciphertextWithMac),
      messageNonce: base64Encode(secretBox.nonce),
      mayoSignature: '',
    );
  }

  @override
  Future<String> decrypt(
    String ciphertext,
    String key,
    String messageNonce,
  ) async {
    final ciphertextWithMac = base64Decode(ciphertext);
    if (ciphertextWithMac.length < 16) {
      throw ArgumentError('AES-GCM ciphertext is missing the authentication tag.');
    }

    final macStart = ciphertextWithMac.length - 16;
    final encryptedBytes = ciphertextWithMac.sublist(0, macStart);
    final macBytes = ciphertextWithMac.sublist(macStart);

    final clearText = await _aesGcm.decrypt(
      SecretBox(
        encryptedBytes,
        nonce: base64Decode(messageNonce),
        mac: Mac(macBytes),
      ),
      secretKey: SecretKey(_decodeKey(key)),
    );

    return utf8.decode(clearText);
  }

  List<int> _decodeKey(String key) {
    final trimmed = key.trim();

    try {
      final decoded = base64Decode(trimmed);
      if (decoded.length == 32) return decoded;
    } on FormatException {
      // Try hex and raw UTF-8 below.
    }

    if (RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(trimmed)) {
      return [
        for (var i = 0; i < trimmed.length; i += 2)
          int.parse(trimmed.substring(i, i + 2), radix: 16),
      ];
    }

    final utf8Bytes = utf8.encode(trimmed);
    if (utf8Bytes.length == 32) return utf8Bytes;

    throw ArgumentError(
      'AES-GCM key must be 32 bytes as base64, hex, or UTF-8 text.',
    );
  }
}
