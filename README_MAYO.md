# MAYO - opis czesci mobilnej

Ten plik opisuje zmiany wykonane w aplikacji mobilnej w zakresie MAYO.
Punktem odniesienia jest paczka bazowa:

```text
%USERPROFILE%\Downloads\mobile-app-braket-main(1).zip
```

W tej paczce MAYO bylo jeszcze szkieletem: generowanie kluczy zapisywalo teksty
`publicKey` i `privateKey`, podpis zwracal `signedCiphertext`, a walidacja
podpisu zawsze zwracala `false`. Po zmianach aplikacja korzysta z paczki
`oqs`, czyli wrappera Dart FFI do natywnej biblioteki `liboqs`.

## Co zostalo zrobione

1. Zastapiono placeholder MAYO prawdziwym podpisem cyfrowym.

   W wersji bazowej plik `lib/core/cryptoServices/mayo_service_impl.dart`
   zawieral komentarze TODO i sztuczne wartosci. Teraz:

   - generuje realna pare kluczy MAYO,
   - zapisuje klucz publiczny i prywatny w `flutter_secure_storage`,
   - podpisuje dane kluczem prywatnym,
   - weryfikuje podpis kluczem publicznym drugiego uzytkownika,
   - koduje klucze i podpisy jako `base64Url`, zeby mozna je bylo przechowywac
     i wysylac jako tekst.

2. Dodano integracje przez `package:oqs`.

   Dodane pliki:

   ```text
   lib/core/cryptoServices/mayo_native.dart
   lib/core/cryptoServices/mayo_native_oqs.dart
   lib/core/cryptoServices/mayo_native_stub.dart
   native/liboqs/
   android/app/src/main/jniLibs/
   ```

   `oqs` korzysta z `liboqs`, a `liboqs` zawiera implementacje MAYO oparte na
   upstreamowym repo:

   ```text
   https://github.com/PQCMayo/MAYO-C
   ```

   Aplikacja uzywa wariantu `MAYO-1`.

3. Uproszczono most Dart -> C.

   Wczesniej projekt mial wlasny `mayo_bridge.c`. Teraz robi to paczka `oqs`:
   laduje natywne `liboqs` i wystawia w Dartcie klase `Signature`.

   Plik `mayo_native_oqs.dart` wybiera algorytm `MAYO-1` i uzywa:

   ```text
   Signature.generateKeyPair()
   Signature.sign()
   Signature.verify()
   ```

4. Dodano natywne `liboqs` dla Windows i Androida.

   W `native/liboqs/bin/oqs.dll` jest prebuilt `liboqs 0.15.0` dla Windows x64.
   `windows/CMakeLists.txt` kopiuje `oqs.dll` obok aplikacji podczas builda.

   Dla Androida dodano prebuilt `liboqs.so` do:

   ```text
   android/app/src/main/jniLibs/arm64-v8a/liboqs.so
   android/app/src/main/jniLibs/armeabi-v7a/liboqs.so
   android/app/src/main/jniLibs/x86/liboqs.so
   android/app/src/main/jniLibs/x86_64/liboqs.so
   ```

   Dla iOS/Linux/macOS trzeba jeszcze dolozyc odpowiednie binarki `liboqs`
   z release `liboqs-binaries` albo zbudowac je ze zrodel.

5. Dodano zaleznosci `oqs` i `ffi`.

   W `pubspec.yaml` dodano:

   ```yaml
   oqs: ^3.1.0
   ffi: ^2.2.0
   ```

   `oqs` daje Dartowe API, a `ffi` jest nadal potrzebne do pracy z natywna
   biblioteka.

6. Zmieniono podpisywanie wysylanej wiadomosci.

   W wersji bazowej podpisywany byl tylko `ciphertext`:

   ```text
   signCiphertext(ciphertext)
   ```

   Teraz podpisywany jest caly payload wiadomosci:

   ```text
   sessionId
   ciphertext
   messageNonce
   algorithm
   ```

   Dzieki temu podpis chroni nie tylko szyfrogram, ale tez kontekst wiadomosci.
   Gdy ktos zmieni `sessionId`, `messageNonce`, `algorithm` albo `ciphertext`,
   weryfikacja podpisu powinna sie nie udac.

8. Zmieniono weryfikacje odbieranej wiadomosci.

   W `pull_message_controller.dart` aplikacja weryfikuje ten sam payload,
   ktory zostal podpisany przy wysylaniu:

   ```text
   sessionId
   ciphertext
   messageNonce
   algorithm
   mayoSignature
   ```

   Jesli podpis jest niepoprawny, wiadomosc nie jest deszyfrowana.

9. Dodano test MAYO w aplikacji.

   Na ekranie glownym, w gornym pasku, dodano przycisk z ikona `security`
   i tooltipem `Test MAYO`.

   Po kliknieciu aplikacja:

   - generuje pare kluczy MAYO,
   - podpisuje lokalna testowa wiadomosc,
   - sprawdza podpis dla oryginalnej wiadomosci,
   - zmienia wiadomosc,
   - sprawdza, ze podpis dla zmienionej wiadomosci zostaje odrzucony.

10. Dodano testy i skrypt diagnostyczny.

   Dodane pliki:

   ```text
   test/mayo_service_impl_test.dart
   tool/mayo_native_debug.dart
   ```

   Test jednostkowy sprawdza logike Dartowa na fake natywnej warstwie.
   Skrypt diagnostyczny uruchamia prawdziwe MAYO przez `oqs` i `liboqs`.

## Jak dziala flow MAYO

### Generowanie kluczy

Podczas dolaczania do sesji aplikacja wywoluje:

```text
generateMayoKeyPairAndStore()
```

Jesli klucze juz istnieja w storage, nie sa generowane ponownie.
Jesli ich nie ma, aplikacja wywoluje `oqs`, a pod spodem natywne `liboqs`,
i zapisuje:

```text
mayo_public_self
mayo_private
```

Klucz publiczny jest potem wysylany do backendu przy:

```http
POST /api/qkdsessions/join
```

Backend ma przekazac ten klucz publiczny drugiej stronie sesji.

### Odbior klucza publicznego drugiej strony

Po dolaczeniu do sesji aplikacja odpytuje:

```http
GET /api/qkdsessions/other_user
```

Oczekiwana odpowiedz zawiera:

```json
{
  "userId": "...",
  "username": "...",
  "mayoKey": "..."
}
```

Pole `mayoKey` jest zapisywane lokalnie jako:

```text
mayo_public_peer
```

Ten klucz sluzy do weryfikowania podpisow wiadomosci przychodzacych.

### Podpisywanie wiadomosci

Przy wysylaniu wiadomosci aplikacja:

1. pobiera `sessionId`,
2. pobiera klucz AES,
3. szyfruje plaintext,
4. buduje payload do podpisu,
5. podpisuje payload kluczem prywatnym MAYO,
6. wysyla dane na backend.

Wysylany DTO zawiera:

```text
sessionId
ciphertext
messageNonce
mayoSignature
algorithm
```

### Weryfikacja wiadomosci

Przy odbieraniu wiadomosci aplikacja:

1. pobiera wiadomosc z backendu,
2. buduje payload z danych odpowiedzi,
3. sprawdza podpis przez MAYO,
4. jesli podpis jest poprawny, odszyfrowuje wiadomosc AES,
5. jesli podpis jest niepoprawny, przerywa obsluge wiadomosci.

## Format podpisywanych danych

Payload jest zamieniany na stabilny JSON. Klucze sa sortowane alfabetycznie,
zeby przy podpisywaniu i weryfikacji powstaly dokladnie te same bajty.

Przyklad logicznego payloadu:

```json
{
  "algorithm": "AES",
  "ciphertext": "...",
  "messageNonce": "...",
  "sessionId": "..."
}
```

To zabezpiecza przed sytuacja, w ktorej te same dane sa zapisane w innej
kolejnosci i podpis przestaje sie zgadzac.

## Rozmiary dla MAYO-1

Dla aktualnie podpietego wariantu `MAYO-1` lokalny test pokazuje:

```text
Klucz publiczny: 1420 B
Klucz prywatny: 24 B
Podpis: 454 B
```

Te wartosci pochodza z `liboqs` dla wariantu `MAYO-1`:

```text
publicKeyLength
secretKeyLength
maxSignatureLength
```

## Jak sprawdzic w aplikacji

Uruchom aplikacje na Windows:

```cmd
cd "%USERPROFILE%\Documents\MAYO apka\mobile-app-braket-main"
flutter build windows --debug
flutter run -d windows
```

Na ekranie glownym kliknij ikone `security` w prawym gornym rogu.

Poprawny wynik powinien wygladac podobnie:

```text
Wynik: PASSED
Klucz publiczny: 1420 B
Klucz prywatny: 24 B
Podpis: 454 B
Oryginalna wiadomosc poprawna: TAK
Zmieniona wiadomosc odrzucona: TAK
```

Najwazniejsze sa dwie ostatnie linie:

```text
Oryginalna wiadomosc poprawna: TAK
Zmieniona wiadomosc odrzucona: TAK
```

To oznacza, ze podpis dziala i ze modyfikacja danych uniewaznia podpis.

## Jak sprawdzic z konsoli

Mozna tez uruchomic test diagnostyczny bez UI:

```cmd
cd "%USERPROFILE%\Documents\MAYO apka\mobile-app-braket-main"
flutter build windows --debug
"%USERPROFILE%\develop\flutter\bin\cache\dart-sdk\bin\dart.exe" run tool\mayo_native_debug.dart
```

Oczekiwany wynik:

```text
Original message valid: true
Changed message valid: false
```

## Testy automatyczne

Test logiki serwisu:

```cmd
flutter test test\mayo_service_impl_test.dart
```

Ten test nie uruchamia prawdziwego `liboqs`. Uzywa fake warstwy natywnej, zeby
szybko sprawdzic logike aplikacji:

```text
generowanie i zapis kluczy
podpisywanie payloadu
weryfikacja poprawnego payloadu
odrzucenie zmienionego payloadu
brak nadpisywania istniejacej pary kluczy
```

## Kompatybilnosc z QKD i backendem

Mobilka nie komunikuje sie bezposrednio z serwerem `QKD-main.zip`.

Mobilka oczekuje od glownego backendu:

```http
POST /api/qkdsessions/join
GET  /api/qkdsessions/other_user
POST /api/messages
POST /api/messages/pull
```

Serwer `QKD-main.zip` ma inne endpointy:

```http
POST /api/qkdsessions/{session_id}/start
POST /api/qkdkeys/{session_id}/reserve
POST /api/qkdkeys/{key_id}/claim
POST /api/qkdsessions/{session_id}/end
```

Dlatego pelne spiecie systemu powinno wygladac tak:

```text
Flutter mobile app -> glowny backend -> QKD server
```

MAYO jest lokalne po stronie aplikacji mobilnej. Klucz prywatny MAYO nie jest
wysylany do backendu. Do backendu trafia tylko klucz publiczny MAYO i podpisy
wiadomosci.

## Ograniczenia

1. Flutter Web / Chrome nie obsluguje tej wersji MAYO.

   MAYO jest podpiete przez `dart:ffi`, a Flutter Web nie obsluguje FFI w tej
   formie. Dla weba potrzebna bylaby osobna wersja WASM.

2. W repo sa dolaczone binarki `liboqs` dla Windows x64 i Androida.

   Windows uzywa `native/liboqs/bin/oqs.dll`. Android dostaje `liboqs.so`
   z katalogow `android/app/src/main/jniLibs/<abi>/`. Linux, iOS i macOS maja
   przygotowany kod ladowania przez `oqs`, ale trzeba jeszcze dolozyc ich
   natywne binarki `liboqs`.

3. QKD key retrieval nie zostal dopiety bezposrednio w mobilce.

   Obecna logika zaklada, ze klucz AES jest juz zapisany w storage przed
   dolaczaniem do sesji. Pobieranie AES z QKD powinno zostac ustalone z
   backendem albo dodane jako osobny etap integracji.

## Lista najwazniejszych zmienionych plikow

```text
lib/core/cryptoServices/mayo_service.dart
lib/core/cryptoServices/mayo_service_impl.dart
lib/core/cryptoServices/mayo_native.dart
lib/core/cryptoServices/mayo_native_oqs.dart
lib/core/cryptoServices/mayo_native_stub.dart
lib/presentation/controllers/message_controller.dart
lib/presentation/controllers/pull_message_controller.dart
lib/presentation/controllers/qkd_session_controller.dart
lib/presentation/screens/home_screen.dart
native/liboqs/bin/oqs.dll
android/app/src/main/jniLibs/arm64-v8a/liboqs.so
android/app/src/main/jniLibs/armeabi-v7a/liboqs.so
android/app/src/main/jniLibs/x86/liboqs.so
android/app/src/main/jniLibs/x86_64/liboqs.so
android/app/build.gradle.kts
ios/Runner.xcodeproj/project.pbxproj
macos/Runner.xcodeproj/project.pbxproj
linux/CMakeLists.txt
windows/CMakeLists.txt
pubspec.yaml
test/mayo_service_impl_test.dart
tool/mayo_native_debug.dart
```
