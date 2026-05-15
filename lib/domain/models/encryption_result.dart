class EncryptionResult {
  final String ciphertext;
  final String messageNonce;

  EncryptionResult({
    required this.ciphertext,
    required this.messageNonce,
  });
}
