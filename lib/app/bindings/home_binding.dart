import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/catalog_dio_controller.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/providers/catalog_provider.dart';
import '../../controllers/auth_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // pastikan AuthController sudah tersedia (kalau belum dari main)
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }

    Get.lazyPut(() => CatalogProvider());
    Get.lazyPut(() => CatalogRepository(Get.find<CatalogProvider>()));
    Get.lazyPut(
        () => CatalogDioController(repository: Get.find<CatalogRepository>()));
    Get.lazyPut(() => HomeController());
  }
}
