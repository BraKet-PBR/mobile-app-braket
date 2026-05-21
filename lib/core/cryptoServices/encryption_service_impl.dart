import 'package:mobile_app_braket/core/cryptoServices/encryption_service.dart';
import 'package:mobile_app_braket/domain/models/encryption_result.dart';

class EncryptionServiceImpl implements EncryptionService {
  @override
  Future<EncryptionResult> encrypt(String plaintext, String key) async {
    // TU PYTHON Z SZYFROWANIEM AES
    // Metoda dostaje plaintext i klucz
    // Musi zwrócić obiekt EncryptionResult zawierający ciphertext i messageNonce


    //mayoSignature PROSZE ZOSTAWIĆ PUSTE, to będzie obliczone w kolejnym kroku
    return EncryptionResult(ciphertext: "ciphertext temp", messageNonce: "nonce temp", mayoSignature: '');
  }

  @override
  Future<String> decrypt(String ciphertext, String key, String messageNonce) async {
    // TU PYTHON Z deSZYFROWANIEM AES
    //Metoda dostaje to co widać i ma zwrócić plaintext

    return '';
  }
}
