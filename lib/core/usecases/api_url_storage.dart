abstract class ApiUrlStorage {
  Future<void> saveApiUrl(String url);

  Future<String?> getApiUrl();

  Future<void> clear();
}
