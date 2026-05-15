abstract class AESKeyStorage {
  Future<void> saveKey(String key);

  Future<String?> getKey();

  Future<void> clear();
}
