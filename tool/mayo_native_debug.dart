// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:mobile_app_braket/core/cryptoServices/mayo_native.dart';

void main() {
  print('Loading liboqs MAYO binding...');
  final mayo = MayoNative.instance;

  print('Generating MAYO keypair...');
  final keyPair = mayo.generateKeyPair();
  print('Public key bytes: ${keyPair.publicKey.length}');
  print('Private key bytes: ${keyPair.privateKey.length}');

  final message = Uint8List.fromList(utf8.encode('MAYO local smoke test'));

  print('Signing message...');
  final signature = mayo.sign(message: message, privateKey: keyPair.privateKey);
  print('Signature bytes: ${signature.length}');

  print('Verifying original message...');
  final valid = mayo.verify(
    message: message,
    signature: signature,
    publicKey: keyPair.publicKey,
  );
  print('Original message valid: $valid');

  print('Verifying changed message...');
  final changedMessage = Uint8List.fromList(utf8.encode('changed message'));
  final changedValid = mayo.verify(
    message: changedMessage,
    signature: signature,
    publicKey: keyPair.publicKey,
  );
  print('Changed message valid: $changedValid');
}
