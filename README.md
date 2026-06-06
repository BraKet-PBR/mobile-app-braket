# Jak uruchomić aplikację Android
- Aplikacje mobilną na platformę Android można zainstalować z pliku `.apk`. Plik znajduje się w repozytorium Documentation/APK. Należy pobrać go na urządzenie / emulator i zainstalować zgodnie z instrukcjami wyświetlanymi na ekranie. Może być konieczne włączenie opcji instalacji aplikacji z nieznanych źródeł. 
    - https://github.com/BraKet-PBR/Documentation/tree/main/APK
    - Minimalna wymagana wersja systemu to `Android 5`

>Należy pamiętać o tym, że serwer API jest uruchamiany lokalnie. Zaleca się zatem potraktować aplikację android jako tzw "proof of concept", a całą procedurę testową przeprowadzić za pomocą plikacji webowej.


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

W razie problemów wskazanych przez ```flutter doctor``` skonsultuj się z dokumentacją Flutter SDK, a by potwierdzić, że twoja instalacja jest prawidłowa.

## Klonowanie repozytorium + instalacja zależności

```bash
git clone https://github.com/BraKet-PBR/mobile-app-braket.git

flutter pub get
```

## Uruchomienie projektu na serwerze Flutter - zalecana opcja testowa

> Pamiętaj, że do działania aplikacja potrzebuje aktywnego serwera API.

1. Po sklonowaniu repozytorium oraz instalacji zależności, wpisz w terminalu następującą komendę:

```
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080
```
Uruchomi ona aplikację jako web server.

2. Otwórz pierwsze okno przeglądarki, wpisz adres ```http://127.0.0.1:8080``` - uruchomi się wtedy pierwsza instancja aplikacji.
3. Otwórz drugie okno przeglądarki w trybie **incognito** i wpisz taki sam adres jak w kroku 2 - uruchomi się wtedy druga instancja aplikacji.

Tak uruchomione dwie instancje symulują docelowy use-case, czyli dwóch użytkowników kontaktujących się ze sobą. 

## Uruchomienie projektu na urządzeniu innym niż zalecane

Uruchom emulator Android lub podłącz urządzenie.

Sprawdź dostępne urządzenia:

```bash
flutter devices
```

Uruchom aplikację:

```bash
flutter run
```

W przypadku platform innych niż android, upewnij się, że uruchamiasz aplikację z odpowiednią flagą ```-d```. Obecnie jednak aplikacja wspiera tylko system android oraz środowisko WEB.

## MAYO na platformach

Aplikacja używa MAYO do podpisywania szyfrogramów i weryfikacji podpisów po odebraniu wiadomości.

- Android korzysta z bibliotek `liboqs.so` dodanych w `android/app/src/main/jniLibs`.
- Windows korzysta z `native/liboqs/bin/oqs.dll`.
- Web korzysta z lokalnego mostka `web/mayo_oqs_web.js` i plików `web/liboqs-js`.




# Test działania aplikacji - prosty scenariusz testowy
Sekcja opisuje co dokładnie dzieje się podczas uruchomienia akcji przyciskami dostępnymi w aplikacji.

## Logowanie
Logowanie odbywa się poświadczeniami dostarczonymi poprzez Teams. Po poprawnej autentykacji endpoint zwraca JWT Token. Aplikacja zapisuje go w flutter_secure_storage. Token wykorzystywany jest do autentykacji przy zapytaniach na dalsze endpointy.

API URL - przy lokalnym uruchomieniu API ze standardową dostarczoną przez nas konfiguracją adres to ```http://127.0.0.1:6767```. 

## "Dołącz do sesji"
1. Pobranie klucza symetrzycznego AES-GCM-256 z symulatora urządzenia QKD. Klucz zapisywany jest lokalnie na urządzeniu za pomocą flutter_secure_storage.
2. Uruchomienie generatora kluczy Mayo (do podpisu cyfrowego). Lokalnie na urządzeniu generowana jest para kluczy - publiczny, prywatny. Klucze zapisywane są na urządzeniu poprzez flutter_secure_storage. 
3. Na endpoint `POST /api/qkdsessions/join` wysyłane jest `{keyHash, mayoPublicSelfKey}`. Backend dopasowywuje użytkowników do sesji na podstawie keyHash - skrótu klucza AES który dwie strony uzyskały z QKD (z symulatora). Klucz publiczny Mayo jest wysyłany aby dostarczyć go drugiej stronie, by ta mogła weryfikować przesyłane w nasępnych krokach szyforgramy. Endpoint zwraca `{sessionId, status, expiresAt}`. Informacje zapisywane są poprzez flutter_secure_storage. Status sesji == `waiting_peer` jeśli drugi użytkownik jeszcze do niej nie dołączył, lub `established` jeśli w momencie zapytania drugi użytkownik oczekiwał już w sesji.
4. Wysłane zostaje zapytanie `GET /api/qkdsessions/other_user` w celu poznania danych drugiego użytkownika w sesji. Endpoint zwraca `{userId, username, mayoKey}`. Dane wyświetlane są na ekranie. Otrzymany klucz publiczny Mayo zostaje zapisany lokalnie poprzez flutter_secure_storage.
5. Jeśli w punkcie 3 zwrócony został status sesji `waiting_peer`, to aplikacja cyklicznie wykonuje działania z punktu 4 aby uzyskać informacje po dołączeniu drugiego użytkownika do sesji.


## "Wyślij wiadomość"
1. Następuje przekierowanie na ekran wysyłania wiadomości.
2. Przed wysłaniem wiadomości aplikacja sprawdza, czy spełnione są wymagane warunki. W przypadku niespełnienia któregoś z nich, informuje o tym stosownym komunikatem. Warunki:
    - Istnienie aktywna sesja
    - Tekst wiadomości został wpisany
    - Klucz AES-GCM zapisany w flutter_secure_storage
    - Klucz prywatny Mayo zapisany w flutter_secure_storage
3. Tekst jawny wiadomości zostaje przekazany do lokalnego serwisu który szyfruje go kluczem AES-GCM z flutter_secure_storage
4. Szyfrogram zostaje przekazany do lokalnego serwisu który podpisuje go kluczem prywatnym Mayo z flutter_secure_storage
5. Szyfrogram zostaje wysłany na endpoint `POST /api/messages` z następującymi danymi: {sessionId, ciphertext, messageNonce, mayoSignature, algorithm}. Algorytm jest ustawiony jako AES-GCM. Obecnie jest to jedyny wspierany przez system BraKet algorytm. Pole to zostało dodane w przypadku chęci rozbudowy systemu o dodatkowe algorytmy szyfrowania. Endpoint zwraca {messageId, status, expiresAt}


## "Pobierz wiadomość"
1. Następuje przekierowanie na ekran pobierania wiadomości.
2. Przed pobraniem wiadomości aplikacja sprawdza, czy spełnione są wymagane warunki. W przypadku niespełnienia któregoś z nich, informuje o tym stosownym komunikatem. Warunki:
    - Istnienie aktywna sesja
3. Zapytanie na endpoint `POST /api/messages/pull`. Serwer sprawdza, czy pytający użytkownik należy do sesji i sesja jest aktywna. Następnie sprawdza, czy dla pytającego użytkownika istnieją jakieś wiaodmości i zwraca następujące dane: {messageId, cipherText, messageNonce, algorithm, createdAt, mayoSignature}
    - Po zwróceniu szyfrogramu serwer usuwa go z bazy danych.

4. Szyfrogram i mayoSignature przekazywane są do lokalnego serwisu który weryfikuje podpis. Klucz prywatny pobierany jest z flutter_secure_storage.
5. W przypadku poprawnej weryfikacji podpisu, szyfrogram wraz z nonce zostaje przekazany do lokalnego serwisu który go deszyfruje i zwraca tekst jawny. 
6. Na ekranie wyświetlane jest messageId, plaintext, algorithm, createdAt.
7. Po wyjściu z ekranu wsystkie dane dotyczące wiadomości zostają bezpowrotnie usunięte. 

## Opis zawartości górnego paska aplikacji (od lewej do prawej)

### Toggle switch "mock/sim"
Pozwala on ustalić, z jakiego trybu generowania klucza AES będzie korzystał użytkownik przed dołączeniem/stworzeniem sesji - domyślnie można wybierać między stałym kluczem testowym, a kluczem wygenerowanym przez opcję "Sim", czyli wbudowany w API symulator kwantowej dystrybucji klucza.

### Ikona tarczy
Po kliknięciu wyświetla się informacja diagnostyczna na temat działania algorytmu MAYO.

### Ikona wylogowania
Kończy sesję.

# Dodatkowe informacje
1. Po wylogowaniu z aplikacji wszystkie dane z flutter_secure_storage zostają bezwporotnie usunięte. 

`dart run build_runner build`
