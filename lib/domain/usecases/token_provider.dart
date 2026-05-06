abstract class TokenProvider {
  bool isValid(String token);
  String? getToken();
  String? getUsername();
}