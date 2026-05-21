class EncryptionResult {
  final String ciphertext;
  final String messageNonce;
  final String mayoSignature;

  EncryptionResult({
    required this.ciphertext,
    required this.messageNonce,
    required this.mayoSignature,
  });
}
