import 'package:mobile_app_braket/core/usecases/mayo_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class MayoStorageImpl implements MayoStorage {

  final FlutterSecureStorage _storage;

  static const _mayoPublicSelfKey = "mayo_public_self";
  static const _mayoPublicPeerKey = "mayo_public_peer";
  static const _mayoPrivateKey = "mayo_private";

  MayoStorageImpl(this._storage);
  
  @override
  Future<void> clear() async {
    await _storage.delete(key: _mayoPublicSelfKey);
    await _storage.delete(key: _mayoPublicPeerKey);
    await _storage.delete(key: _mayoPrivateKey);
  }

  @override
  Future<void> saveMayoPublicSelf(String mayoPublic) async{
    await _storage.write(key: _mayoPublicSelfKey, value: mayoPublic);
  }

  @override
  Future<String?> getMayoPublicSelf() async{
    return await _storage.read(key: _mayoPublicSelfKey);
  }

  @override
  Future<void> saveMayoPublicPeer(String mayoPublic) async{
    await _storage.write(key: _mayoPublicPeerKey, value: mayoPublic);
  }

  @override
  Future<String?> getMayoPublicPeer() async {
    return await _storage.read(key: _mayoPublicPeerKey);
  }

  @override
  Future<void> saveMayoPrivate(String mayoPrivate) async{
    await _storage.write(key: _mayoPrivateKey, value: mayoPrivate);
  }
  
  @override
  Future<String?> getMayoPrivate() async {
    return await _storage.read(key: _mayoPrivateKey);
  }
  

}