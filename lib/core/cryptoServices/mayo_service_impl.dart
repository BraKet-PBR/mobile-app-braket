import 'dart:convert';
import 'dart:typed_data';

import 'package:mobile_app_braket/core/cryptoServices/mayo_native.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service.dart';
import 'package:mobile_app_braket/core/localization/app_strings.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';

class MayoServiceImpl implements MayoService {
  final MayoStorage _mayoStorage;
  final MayoNative _mayoNative;

  MayoServiceImpl(this._mayoStorage, {MayoNative? mayoNative})
    : _mayoNative = mayoNative ?? MayoNative.instance;

  @override
  Future<bool> validateMessagePayloadSignature({
    required String sessionId,
    required String ciphertext,
    required String messageNonce,
    required String algorithm,
    required String signature,
  }) async {
    final String? publicKeyPeer = await _mayoStorage.getMayoPublicPeer();
    if (publicKeyPeer == null || publicKeyPeer.isEmpty) {
      throw StateError(AppStrings.mayoPeerPublicKeyMissing);
    }

    return _verify(
      publicKey: publicKeyPeer,
      message: _buildMessagePayload(
        sessionId: sessionId,
        ciphertext: ciphertext,
        messageNonce: messageNonce,
        algorithm: algorithm,
      ),
      signature: signature,
    );
  }

  @override
  Future<void> generateMayoKeyPairAndStore() async {
    final existingPublicKey = await _mayoStorage.getMayoPublicSelf();
    final existingPrivateKey = await _mayoStorage.getMayoPrivate();
    if (existingPublicKey != null &&
        existingPublicKey.isNotEmpty &&
        existingPrivateKey != null &&
        existingPrivateKey.isNotEmpty) {
      await _mayoStorage.clear();
    }

    final keyPair = await _mayoNative.generateKeyPair();
    await _mayoStorage.saveMayoPublicSelf(_encodeBytes(keyPair.publicKey));
    await _mayoStorage.saveMayoPrivate(_encodeBytes(keyPair.privateKey));
  }

  @override
  Future<String> signMessagePayload({
    required String sessionId,
    required String ciphertext,
    required String messageNonce,
    required String algorithm,
  }) async {
    final String? privateKey = await _mayoStorage.getMayoPrivate();
    if (privateKey == null || privateKey.isEmpty) {
      throw StateError(AppStrings.mayoPrivateKeyMissing);
    }

    return await _sign(
      privateKey: privateKey,
      message: _buildMessagePayload(
        sessionId: sessionId,
        ciphertext: ciphertext,
        messageNonce: messageNonce,
        algorithm: algorithm,
      ),
    );
  }

  Uint8List _buildMessagePayload({
    required String sessionId,
    required String ciphertext,
    required String messageNonce,
    required String algorithm,
  }) {
    return _canonicalBytes({
      'algorithm': algorithm,
      'ciphertext': ciphertext,
      'messageNonce': messageNonce,
      'sessionId': sessionId,
    });
  }

  Future<String> _sign({
    required String privateKey,
    required Uint8List message,
  }) async {
    final privateKeyBytes = _decodeBytes(privateKey);
    final signature = await _mayoNative.sign(
      message: message,
      privateKey: privateKeyBytes,
    );
    return _encodeBytes(signature);
  }

  Future<bool> _verify({
    required String publicKey,
    required Uint8List message,
    required String signature,
  }) async {
    try {
      return await _mayoNative.verify(
        message: message,
        signature: _decodeBytes(signature),
        publicKey: _decodeBytes(publicKey),
      );
    } on FormatException {
      return false;
    } on StateError {
      return false;
    } on Exception {
      return false;
    }
  }

  Uint8List _canonicalBytes(Map<String, String> payload) {
    final sortedKeys = payload.keys.toList()..sort();
    final sortedPayload = <String, String>{
      for (final key in sortedKeys) key: payload[key]!,
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(sortedPayload)));
  }

  String _encodeBytes(Uint8List bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  Uint8List _decodeBytes(String encoded) {
    return Uint8List.fromList(base64Url.decode(base64Url.normalize(encoded)));
  }
}
