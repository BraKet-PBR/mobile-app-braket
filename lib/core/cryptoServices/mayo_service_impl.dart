import 'dart:convert';
import 'dart:typed_data';

import 'package:mobile_app_braket/core/cryptoServices/mayo_native.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';

class MayoServiceImpl implements MayoService {
  final MayoStorage _mayoStorage;
  final MayoNative _mayoNative;

  MayoServiceImpl(this._mayoStorage, {MayoNative? mayoNative})
    : _mayoNative = mayoNative ?? MayoNative.instance;

  @override
  Future<bool> validateSignature(String ciphertext, String signature) async {
    final String? publicKeyPeer = await _mayoStorage.getMayoPublicPeer();
    if (publicKeyPeer == null || publicKeyPeer.isEmpty) {
      throw StateError(
        'Klucz publiczny Mayo peera nie znaleziony w local storage.',
      );
    }

    return _verify(
      publicKey: publicKeyPeer,
      message: _canonicalBytes({'ciphertext': ciphertext}),
      signature: signature,
    );
  }

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
      throw StateError(
        'Klucz publiczny Mayo peera nie znaleziony w local storage.',
      );
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
      return;
    }

    final keyPair = _mayoNative.generateKeyPair();
    await _mayoStorage.saveMayoPublicSelf(_encodeBytes(keyPair.publicKey));
    await _mayoStorage.saveMayoPrivate(_encodeBytes(keyPair.privateKey));
  }

  @override
  Future<String> signCiphertext(String ciphertext) async {
    final String? privateKey = await _mayoStorage.getMayoPrivate();
    if (privateKey == null || privateKey.isEmpty) {
      throw StateError('Klucz prywatny Mayo nie znaleziony w local storage.');
    }

    return _sign(
      privateKey: privateKey,
      message: _canonicalBytes({'ciphertext': ciphertext}),
    );
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
      throw StateError('Klucz prywatny Mayo nie znaleziony w local storage.');
    }

    return _sign(
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

  String _sign({required String privateKey, required Uint8List message}) {
    final privateKeyBytes = _decodeBytes(privateKey);
    final signature = _mayoNative.sign(
      message: message,
      privateKey: privateKeyBytes,
    );
    return _encodeBytes(signature);
  }

  bool _verify({
    required String publicKey,
    required Uint8List message,
    required String signature,
  }) {
    try {
      return _mayoNative.verify(
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
