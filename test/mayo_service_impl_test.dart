import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_native.dart';
import 'package:mobile_app_braket/core/cryptoServices/mayo_service_impl.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';

class FakeMayoStorage implements MayoStorage {
  String? publicSelf;
  String? publicPeer;
  String? privateKey;

  @override
  Future<void> clear() async {
    publicSelf = null;
    publicPeer = null;
    privateKey = null;
  }

  @override
  Future<String?> getMayoPrivate() async => privateKey;

  @override
  Future<String?> getMayoPublicPeer() async => publicPeer;

  @override
  Future<String?> getMayoPublicSelf() async => publicSelf;

  @override
  Future<void> saveMayoPrivate(String mayoPrivate) async {
    privateKey = mayoPrivate;
  }

  @override
  Future<void> saveMayoPublicPeer(String mayoPublic) async {
    publicPeer = mayoPublic;
  }

  @override
  Future<void> saveMayoPublicSelf(String mayoPublic) async {
    publicSelf = mayoPublic;
  }
}

void main() {
  final fakeNative = FakeMayoNative();

  test('Mayo signs and verifies a message payload', () async {
    final senderStorage = FakeMayoStorage();
    final receiverStorage = FakeMayoStorage();

    final senderMayo = MayoServiceImpl(senderStorage, mayoNative: fakeNative);
    final receiverMayo = MayoServiceImpl(
      receiverStorage,
      mayoNative: fakeNative,
    );

    await senderMayo.generateMayoKeyPairAndStore();
    await receiverStorage.saveMayoPublicPeer(senderStorage.publicSelf!);

    final signature = await senderMayo.signMessagePayload(
      sessionId: 'session-1',
      ciphertext: 'ciphertext',
      messageNonce: 'nonce',
      algorithm: 'AES',
    );

    final isValid = await receiverMayo.validateMessagePayloadSignature(
      sessionId: 'session-1',
      ciphertext: 'ciphertext',
      messageNonce: 'nonce',
      algorithm: 'AES',
      signature: signature,
    );

    expect(isValid, isTrue);
  });

  test('Mayo rejects a changed payload', () async {
    final senderStorage = FakeMayoStorage();
    final receiverStorage = FakeMayoStorage();

    final senderMayo = MayoServiceImpl(senderStorage, mayoNative: fakeNative);
    final receiverMayo = MayoServiceImpl(
      receiverStorage,
      mayoNative: fakeNative,
    );

    await senderMayo.generateMayoKeyPairAndStore();
    await receiverStorage.saveMayoPublicPeer(senderStorage.publicSelf!);

    final signature = await senderMayo.signMessagePayload(
      sessionId: 'session-1',
      ciphertext: 'ciphertext',
      messageNonce: 'nonce',
      algorithm: 'AES',
    );

    final isValid = await receiverMayo.validateMessagePayloadSignature(
      sessionId: 'session-1',
      ciphertext: 'changed-ciphertext',
      messageNonce: 'nonce',
      algorithm: 'AES',
      signature: signature,
    );

    expect(isValid, isFalse);
  });

  test('Mayo key generation clears existing keys before regenerating', () async {
    final storage = FakeMayoStorage();
    final mayo = MayoServiceImpl(storage, mayoNative: fakeNative);

    await mayo.generateMayoKeyPairAndStore();
    final firstPublic = storage.publicSelf;
    final firstPrivate = storage.privateKey;

    await storage.saveMayoPublicPeer('peer-key');

    await mayo.generateMayoKeyPairAndStore();

    expect(storage.publicSelf, isNot(firstPublic));
    expect(storage.privateKey, isNot(firstPrivate));
    expect(storage.publicPeer, isNull);
  });
}

class FakeMayoNative implements MayoNative {
  int _keyCounter = 0;

  @override
  MayoKeyPair generateKeyPair() {
    _keyCounter++;
    return MayoKeyPair(
      publicKey: Uint8List.fromList([_keyCounter, 2, 3, 4]),
      privateKey: Uint8List.fromList([_keyCounter, 2, 3, 4]),
    );
  }

  @override
  Uint8List sign({required Uint8List message, required Uint8List privateKey}) {
    return Uint8List.fromList([...privateKey, ...message]);
  }

  @override
  bool verify({
    required Uint8List message,
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    final expected = Uint8List.fromList([...publicKey, ...message]);
    if (signature.length != expected.length) {
      return false;
    }

    for (var i = 0; i < signature.length; i++) {
      if (signature[i] != expected[i]) {
        return false;
      }
    }

    return true;
  }
}
