abstract class QkdSessionStorage {
  Future<void> saveSessionId(String sesionId);

  Future<String?> getSessionId();

  Future<void> saveSessionStatus(String status);

  Future<String?> getSessionStatus();

  Future<void> saveSessionExpiresAt(String expiresAt);

  Future<String?> getSessionExpiresAt();

  Future<void> clear();
}