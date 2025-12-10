import '../providers/catalog_provider.dart';

class CatalogRepository {
  final CatalogProvider _provider;

  CatalogRepository(this._provider);

  Future<Map<String, dynamic>> fetchAllData() async {
    return await _provider.fetchAllData();
  }
}
