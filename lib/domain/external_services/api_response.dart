// Klasa generyczna, może przechowywać dane dowolnego typu
// Dzięki temu wystarczy jedna aby obsłużyć różne typy odpowiedzi z API

class APIResponse<T>{
  final int? statusCode;
  final T? body; // Właściwa odpowiedź z api, typ T dowolny, definiowany przy użyciu klasy???
  final Object? error;
  final dynamic errorBody; // dynamic -> typ nie jest sprawdzany w trakcie kompilacji, można wrzucić cokolwiek. Surowa odpowiedź z api w przypadku błędu

  const APIResponse({this.statusCode, this.body, this.error, this.errorBody});
}