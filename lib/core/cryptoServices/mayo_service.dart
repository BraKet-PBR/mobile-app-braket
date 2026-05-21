abstract class MayoService {

  Future<bool> validateSignature(String message, String signature);

  Future<void> generateMayoKeyPairAndStore();

  Future<String> signCiphertext(String ciphertext);
}