import 'dart:io';

bool isSocketException(Object? error) {
  return error is SocketException;
}
