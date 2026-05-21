abstract class MayoStorage {
  Future<void> saveMayoPublicSelf(String mayoPublic);
  
  Future<String?> getMayoPublicSelf();

  Future<void> saveMayoPublicPeer(String mayoPublic);

  Future<String?> getMayoPublicPeer();

  Future <void> saveMayoPrivate(String mayoPrivate);

  Future<String?> getMayoPrivate();

  Future<void> clear();
}