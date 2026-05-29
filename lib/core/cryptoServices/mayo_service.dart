abstract class MayoService {
  Future<bool> validateMessagePayloadSignature({
    required String sessionId,
    required String ciphertext,
    required String messageNonce,
    required String algorithm,
    required String signature,
  });

  Future<void> generateMayoKeyPairAndStore();

  Future<String> signMessagePayload({
    required String sessionId,
    required String ciphertext,
    required String messageNonce,
    required String algorithm,
  });
}
