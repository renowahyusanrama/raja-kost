import 'package:get/get.dart';
import '../data/models/kost_model.dart';
import '../data/models/service_model.dart';
import '../data/repositories/catalog_repository.dart';

class CatalogDioController extends GetxController {
  final CatalogRepository repository;

  CatalogDioController({required this.repository});

  final _isLoading = false.obs;
  final _kostList = <KostModel>[].obs;
  final _serviceList = <ServiceModel>[].obs;
  final _error = Rxn<String>();

  bool get isLoading => _isLoading.value;
  List<KostModel> get kostList => _kostList;
  List<ServiceModel> get serviceList => _serviceList;
  String? get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    _isLoading.value = true;
    _error.value = null;
    update();

    try {
      final result = await repository.fetchAllData();
      _kostList.value = result['kosts'] as List<KostModel>;
      _serviceList.value = result['services'] as List<ServiceModel>;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  Future<void> refreshData() async {
    await fetchAll();
  }
}
