abstract class IStoreDataSource {
  Future<String> getStoreVersion();
  Future<bool> needUpdate({String? storeVersion});
  Future<void> update();
}
