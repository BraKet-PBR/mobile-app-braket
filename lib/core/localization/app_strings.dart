class AppStrings {
  AppStrings._();

  // home_screen.dart
  static const String joinSession = "Dołącz do sesji";
  static const String sendMessage = "Wyślij wiadomość";
  static const String pullMessage = "Pobierz wiadomość";
  static const String awaitingOtherPeer = "Oczekiwanie na drugiego użytkownika...";
  static String otherUser(String username) => 'Drugi uczestnik: $username';
  static String otherUserId(String userId) => 'ID: $userId';

  // login_screen.dart
  static const String moreInfo = "Więcej informacji";
  static const String appName = "<BRAKET>";
  static const String loginHint = "Login";
  static const String apiUrlHint = "API URL";
  static const String passwordHint = "Password";
  static const String loginButton = "Login";

  // message_screen.dart
  static const String sendMessageTitle = "Wyślij wiadomość";
  static const String sendEncryptedMessage = "Wyślij zaszyfrowaną wiadomość";
  static const String enterMessageHint = "Wpisz wiadomość do zaszyfrowania";
  static const String sendMessageButton = "Wyślij wiadomość";
  static const String plaintextLabel = "Plaintext";
  static String messageStatus(String status) => 'Status: $status';
  static String messageId(String id) => 'ID wiadomości: $id';
  static String messageExpiresAt(String date) => 'Wygasa: $date';

  // pull_message_screen.dart
  static const String pullMessageTitle = "Pobierz wiadomość";
  static const String pullEncryptedMessage = "Pobierz zaszyfrowaną wiadomość";
  static const String pullMessageButton = "Pobierz wiadomość";
  static const String receivedMessage = "Otrzymana wiadomość";
  static const String messageDeletionWarning = "Wiadomość zostanie usunięta po wyjściu z ekranu.";
  static String messagePlaintext(String plaintext) => 'Plaintext: $plaintext';
  static String messageAlgorithm(String algorithm) => 'Algorytm: $algorithm';
  static String messageCreatedAt(String date) => 'Utworzono: $date';

  // controller_base.dart
  static const String ok = "Ok";
  static const String error = "Błąd";
  static const String noInternet = "Brak połączenia z internetem";
  static const String requestFailed = "Nie udało się wysłać żądania, spróbuj ponownie później.";
  static const String somethingWentWrong = "Coś poszło nie tak.";

  // login_controller.dart
  static const String loginErrorTitle = "Błąd logowania";
  static const String serverNotResponding = "Serwer nie odpowiada.";
  static const String invalidCredentials = "Nieprawidłowy login lub hasło";
  static const String usernameEmpty = "Nazwa użytkownika nie może być pusta";
  static const String usernameTooLong = "Nazwa użytkownika za długa";
  static const String passwordEmpty = "Hasło nie może być puste";
  static const String passwordTooLong = "Hasło za długie.";
  static const String apiUrlEmpty = "API URL nie może być pusty";
  static const String apiUrlInvalidFormat = "Nieprawidłowy format adresu";
  static String loginServerError(int statusCode) =>
      'Logowanie nie powiodło się. Kod odpowiedzi serwera: $statusCode';

  // message_controller.dart
  static const String messageNoSessionTitle = "Brak sesji";
  static const String messageNoSessionMessage = "Najpierw utwórz lub dołącz do sesji.";
  static const String messageNoDataTitle = "Brak danych";
  static const String messageNoDataMessage = "Uzupełnij tekst wiadomości.";
  static const String messageNoAesKeyTitle = "Brak klucza AES";
  static const String messageNoAesKeyMessage = "Nie znaleziono klucza AES w secure local storage.";
  static const String messageUnexpectedErrorTitle = "Nieoczekiwany Błąd";
  static const String sendMessageFailed = "Nie udało się wysłać wiadomości.";
  static const String messageSentTitle = "Wysłano";
  static const String messagePendingSaved = "Wiadomość została zapisana jako pending.";

  // pull_message_controller.dart
  static const String pullNoSessionTitle = "Brak sesji";
  static const String pullNoSessionMessage = "Najpierw dołącz do sesji.";
  static const String pullNoMessagesTitle = "Brak wiadomości";
  static const String pullNoMessagesMessage = "Nie masz nowych wiadomości.";
  static const String pullUnexpectedErrorTitle = "Nieoczekiwany Błąd";
  static const String pullMessageFailed = "Nie udało się pobrać wiadomości.";
  static const String pullDecryptFailed = "Nie udało się odszyfrować wiadomości.";

  // qkd_session_controller.dart
  static const String qkdUnexpectedErrorTitle = "Nieoczekiwany Błąd";
  static const String qkdCreateSessionFailed = "Nie udało się utworzyć sesji.";
  static const String qkdJoinSessionFailed = "Nie udało się dołączyć do sesji.";
  static const String qkdJoinOrCreateSessionFailed = "Nie udało się dołączyć/utworzyć sesji.";





}
