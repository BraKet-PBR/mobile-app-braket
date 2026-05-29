import 'dart:async';
import 'dart:typed_data';

class MayoKeyPair {
  final Uint8List publicKey;
  final Uint8List privateKey;

  MayoKeyPair({required this.publicKey, required this.privateKey});
}

class MayoNative {
  static final MayoNative instance = MayoNative();

  FutureOr<MayoKeyPair> generateKeyPair() {
    throw UnsupportedError(
      'Prawdziwe MAYO wymaga natywnej biblioteki liboqs. '
      'Ten target nie obsluguje dart:ffi, wiec nie zadziala w Flutter Web.',
    );
  }

  FutureOr<Uint8List> sign({
    required Uint8List message,
    required Uint8List privateKey,
  }) {
    throw UnsupportedError('Prawdziwe MAYO wymaga natywnej biblioteki liboqs.');
  }

  FutureOr<bool> verify({
    required Uint8List message,
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    throw UnsupportedError('Prawdziwe MAYO wymaga natywnej biblioteki liboqs.');
  }
}
