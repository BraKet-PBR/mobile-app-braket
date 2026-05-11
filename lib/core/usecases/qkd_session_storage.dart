abstract class QkdSessionStorage {
  void saveSessionId(String sesionId);

  String? getSessionId();

  void clear();
}