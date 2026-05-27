abstract class TokenProvider {
  Future<bool> isValid(String token);
  Future<String?> getToken();
  Future<String?> getUsername();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
}