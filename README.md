# Jak uruchomić projekt jako developer


## Wymagania wstępne

Zainstalowane:
- Flutter SDK
- Enulator Android / Google Chrome
- Git

Sprawdź konfigurację środowiska:

```bash
flutter doctor
```

## Klonowanie repozytorium + instalacja zależności

```bash
git clone https://github.com/BraKet-PBR/mobile-app-braket.git

flutter pub get
```

# Uruchomienie aplikacji

## Android

Uruchom emulator Android lub podłącz urządzenie.

Sprawdź dostępne urządzenia:

```bash
flutter devices
```

Uruchom aplikację:

```bash
flutter run
```


## Web

Uruchom aplikację w przeglądarce Chrome:

```bash
flutter run -d chrome
```




# Jak działa aplikacja - skrócony poradnik użytkownika
Sekcja opisuje co dokładnie dzieje się podczas uruchomienia akcji przyciskami dostępnymi w aplikacji.

## Logowanie
Logowanie odbywa się poświadczeniami dostarczonymi poprzez Teams. Po poprawnej autentykacji endpoint zwraca JWT Token. Aplikacja zapisuje go w flutter_secure_storage. Token wykorzystywany jest do autentykacji przy zapytaniach na dalsze endpointy.

API URL - przy lokalnym uruchomieniu API ze standardową dostarczoną przez nas konfiguracją adres to xyz (TODO). Istnieje możliwość zmiany adresu API, więcej informacji na ten temat znajduje się w repozytorium link (TODO).

## "Dołącz do sesji"
1. Pobranie klucza symetrzycznego AES-GCM-256 z symulatora urządzenia QKD. Klucz zapisywany jest lokalnie na urządzeniu za pomocą flutter_secure_storage.
2. Uruchomienie generatora kluczy Mayo (do podpisu cyfrowego). Lokalnie na urządzeniu generowana jest para kluczy - publiczny, prywatny. Klucze zapisywane są na urządzeniu poprzez flutter_secure_storage. 
3. Na endpoint `POST /api/qkdsessions/join` wysyłane jest `{keyHash, mayoPublicSelfKey}`. Backend dopasowywuje użytkowników do sesji na podstawie keyHash - skrótu klucza AES który dwie strony uzyskały z QKD (z symulatora). Klucz publiczny Mayo jest wysyłany aby dostarczyć go drugiej stronie, by ta mogła weryfikować przesyłane w nasępnych krokach szyforgramy. Endpoint zwraca `{sessionId, status, expiresAt}`. Informacje zapisywane są poprzez flutter_secure_storage. Status sesji == `waiting_peer` jeśli drugi użytkownik jeszcze do niej nie dołączył, lub `established` jeśli w momencie zapytania drugi użytkownik oczekiwał już w sesji.
4. Wysłane zostaje zapytanie `GET /api/qkdsessions/other_user` w celu poznania danych drugiego użytkownika w sesji. Endpoint zwraca `{userId, username, mayoKey}`. Dane wyświetlane są na ekranie. Otrzymany klucz publiczny Mayo zostaje zapisany lokalnie poprzez flutter_secure_storage.
5. Jeśli w punkcie 3 zwrócony został status sesji `waiting_peer`, to aplikacja cyklicznie wykonuje działania z punktu 4 aby uzyskać informacje po dołączeniu drugiego użytkownika do sesji.


# "Wyślij wiadomość"
1. Następuje przekierowanie na ekran wysyłania wiadomości.
2. Przed wysłaniem wiadomości aplikacja sprawdza, czy spełnione są wymagane warunki. W przypadku niespełnienia któregoś z nich, informuje o tym stosownym komunikatem. Warunki:
    - Istnienie aktywna sesja
    - Tekst wiadomości został wpisany
    - Klucz AES-GCM zapisany w flutter_secure_storage
    - Klucz prywatny Mayo zapisany w flutter_secure_storage
3. Tekst jawny wiadomości zostaje przekazany do lokalnego serwisu który szyfruje go kluczem AES-GCM z flutter_secure_storage
4. Szyfrogram zostaje przekazany do lokalnego serwisu który podpisuje go kluczem prywatnym Mayo z flutter_secure_storage
5. Szyfrogram zostaje wysłany na endpoint `POST /api/messages` z następującymi danymi: {sessionId, ciphertext, messageNonce, mayoSignature, algorithm}. Algorytm jest ustawiony jako AES-GCM. Obecnie jest to jedyny wspierany przez system BraKet algorytm. Pole to zostało dodane w przypadku chęci rozbudowy systemu o dodatkowe algorytmy szyfrowania. Endpoint zwraca {messageId, status, expiresAt}


# "Pobierz wiadomość"
1. Następuje przekierowanie na ekran pobierania wiadomości.
2. Przed pobraniem wiadomości aplikacja sprawdza, czy spełnione są wymagane warunki. W przypadku niespełnienia któregoś z nich, informuje o tym stosownym komunikatem. Warunki:
    - Istnienie aktywna sesja
3. Zapytanie na endpoint `POST /api/messages/pull`. Serwer sprawdza, czy pytający użytkownik należy do sesji i sesja jest aktywna. Następnie sprawdza, czy dla pytającego użytkownika istnieją jakieś wiaodmości i zwraca następujące dane: {messageId, cipherText, messageNonce, algorithm, createdAt, mayoSignature}
    - Po zwróceniu szyfrogramu serwer usuwa go z bazy danych.

4. Szyfrogram i mayoSignature przekazywane są do lokalnego serwisu który weryfikuje podpis. Klucz prywatny pobierany jest z flutter_secure_storage.
5. W przypadku poprawnej weryfikacji podpisu, szyfrogram wraz z nonce zostaje przekazany do lokalnego serwisu który go deszyfruje i zwraca tekst jawny. 
6. Na ekranie wyświetlane jest messageId, plaintext, algorithm, createdAt.
7. Po wyjściu z ekranu wsystkie dane dotyczące wiadomości zostają bezpowrotnie usunięte. 

# Dodatkowe informacje
1. Po wylogowaniu z aplikacji wszystkie dane z flutter_secure_storage zostają bezwporotnie usunięte. 












`dart run build_runner build`
