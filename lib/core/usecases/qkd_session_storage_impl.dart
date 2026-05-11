import 'package:get_storage/get_storage.dart';
import 'package:mobile_app_braket/core/usecases/qkd_session_storage.dart';

class QkdSessionStorageImpl implements QkdSessionStorage{

  final GetStorage storage;

  static const _sessionIdKey = "qkd_session_id";

  QkdSessionStorageImpl(this.storage);

  @override
  void clear() {
    storage.remove(_sessionIdKey);
  }

  @override
  String? getSessionId() {
    return storage.read<String>(_sessionIdKey);
  }

  @override
  void saveSessionId(String sesionId) {
    storage.write(_sessionIdKey, sesionId);
  }
}