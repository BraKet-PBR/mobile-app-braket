import 'package:mobile_app_braket/core/cryptoServices/mayo_service.dart';
import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';

class MayoServiceImpl implements MayoService {
  final MayoStorage _mayoStorage;

  MayoServiceImpl(this._mayoStorage);

  @override
  Future<bool> validateSignature(String ciphertext, String signature) async {
    final String? publicKeyPeer = await _mayoStorage.getMayoPublicPeer();
    if (publicKeyPeer == null || publicKeyPeer.isEmpty) {
      throw StateError('Klucz publiczny mayo peera nie znaleziony w local storage');
    }


    // TODO: tu implementacja walidacji podpisu mayo.
    // Metoda dostaje to co dostaje + zmienna publicKeyPeer 

    return false;
  }

  @override
  Future<void> generateMayoKeyPairAndStore() async {

    // tu generowanie pary kluczy i na koniec prosze wywołać wskazane metodu które zapiszą w secure local storage.

    await _mayoStorage.saveMayoPublicSelf("publicKey");
    await _mayoStorage.saveMayoPrivate("privateKey");
  }

  @override
  Future<String> signCiphertext(String ciphertext) async {
    final String? privateKey = await _mayoStorage.getMayoPrivate();
    if (privateKey == null || privateKey.isEmpty) {
      throw StateError('Klucz prywatny mayo nie znaleziony w local storage.');
    }

    // tu podpisywanie mayo


    return "signedCiphertext";
  }

}
