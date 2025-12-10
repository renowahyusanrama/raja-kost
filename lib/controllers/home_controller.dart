import 'package:get/get.dart';
import '../data/models/kost_model.dart';
import '../data/models/service_model.dart';
import 'catalog_dio_controller.dart';

class HomeController extends GetxController {
  late final CatalogDioController _catalogController;

  final searchQuery = ''.obs;
  final selectedCategory = 'all'.obs;
  final favoriteIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _catalogController = Get.find<CatalogDioController>();
  }

  void searchKost(String query) {
    searchQuery.value = query;
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  bool isFavorite(KostModel kost) {
    return favoriteIds.contains(kost.id);
  }

  void toggleFavorite(KostModel kost) {
    if (favoriteIds.contains(kost.id)) {
      favoriteIds.remove(kost.id);
    } else {
      favoriteIds.add(kost.id);
    }
  }

  List<KostModel> get filteredKostList {
    // Sentuh favoriteIds agar perubahan wishlist juga memicu rebuild list
    final favoriteSnapshot = favoriteIds.toSet();

    var list = _catalogController.kostList;

    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    if (selectedCategory.value == 'favorites') {
      list = list.where((item) => favoriteSnapshot.contains(item.id)).toList();
    } else if (selectedCategory.value != 'all') {
      list = list.where((item) => item.type == selectedCategory.value).toList();
    }

    return list;
  }

  List<ServiceModel> get filteredServiceList {
    var list = _catalogController.serviceList;

    if (searchQuery.value.isNotEmpty) {
      list = list
          .where((item) =>
              item.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }

    return list;
  }
}
