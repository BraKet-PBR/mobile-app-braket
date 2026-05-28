abstract class MayoService {
  Future<bool> validateSignature(String message, String signature);

  Future<bool> validateMessagePayloadSignature({
    required String sessionId,
    required String ciphertext,
    required String messageNonce,
    required String algorithm,
    required String signature,
  });

  Future<void> generateMayoKeyPairAndStore();

  Future<String> signCiphertext(String ciphertext);

  Future<String> signMessagePayload({
    required String sessionId,
    required String ciphertext,
    required String messageNonce,
    required String algorithm,
  });
}
