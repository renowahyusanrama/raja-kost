import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/kost_model.dart';

class RoomAvailability {
  RoomAvailability({
    required this.code,
    required this.isAvailable,
  });

  final String code;
  final bool isAvailable;

  factory RoomAvailability.fromMap(Map<String, dynamic> map) {
    return RoomAvailability(
      code: map['code'] as String,
      isAvailable: map['is_available'] as bool? ?? true,
    );
  }
}

class DetailController extends GetxController {
  final Rxn<KostModel> _kost = Rxn<KostModel>();

  KostModel? get kost => _kost.value;

  final selectedImageIndex = 0.obs;
  final isFavorite = false.obs;
  final roomStatuses = <RoomAvailability>[].obs;
  final isLoadingRooms = false.obs;
  final RxnString roomError = RxnString();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is KostModel) {
      _kost.value = Get.arguments as KostModel;
      _fetchRoomAvailability();
    } else {
      Get.back();
      Get.snackbar('Error', 'Data kost tidak ditemukan');
    }
  }

  void selectImage(int index) {
    selectedImageIndex.value = index;
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  Future<void> _fetchRoomAvailability() async {
    final type = kost?.type;
    if (type == null) return;
    isLoadingRooms.value = true;
    roomError.value = null;
    try {
      final resp =
          await _client.from('rooms').select().eq('type', type).order('code');
      roomStatuses.assignAll(
        (resp as List<dynamic>)
            .map((e) => RoomAvailability.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } catch (e) {
      roomError.value = 'Gagal memuat status kamar: $e';
    } finally {
      isLoadingRooms.value = false;
    }
  }
}
