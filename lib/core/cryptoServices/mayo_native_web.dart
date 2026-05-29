import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

class MayoKeyPair {
  final Uint8List publicKey;
  final Uint8List privateKey;

  MayoKeyPair({required this.publicKey, required this.privateKey});
}

@JS('braketMayo.generateKeyPair')
external JSPromise<JSObject> _generateKeyPair();

@JS('braketMayo.sign')
external JSPromise<JSString> _sign(JSString message, JSString privateKey);

@JS('braketMayo.verify')
external JSPromise<JSBoolean> _verify(
  JSString message,
  JSString signature,
  JSString publicKey,
);

extension type _MayoWebKeyPair(JSObject _) implements JSObject {
  external JSString get publicKey;
  external JSString get privateKey;
}

class MayoNative {
  static final MayoNative instance = MayoNative._();

  MayoNative._();

  FutureOr<MayoKeyPair> generateKeyPair() async {
    final keyPair = _MayoWebKeyPair(await _generateKeyPair().toDart);
    return MayoKeyPair(
      publicKey: _decodeBytes(keyPair.publicKey.toDart),
      privateKey: _decodeBytes(keyPair.privateKey.toDart),
    );
  }

  FutureOr<Uint8List> sign({
    required Uint8List message,
    required Uint8List privateKey,
  }) async {
    final signature = await _sign(
      _encodeBytes(message).toJS,
      _encodeBytes(privateKey).toJS,
    ).toDart;
    return _decodeBytes(signature.toDart);
  }

  FutureOr<bool> verify({
    required Uint8List message,
    required Uint8List signature,
    required Uint8List publicKey,
  }) async {
    final isValid = await _verify(
      _encodeBytes(message).toJS,
      _encodeBytes(signature).toJS,
      _encodeBytes(publicKey).toJS,
    ).toDart;
    return isValid.toDart;
  }

  String _encodeBytes(Uint8List bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  Uint8List _decodeBytes(String encoded) {
    return Uint8List.fromList(base64Url.decode(base64Url.normalize(encoded)));
  }
}
