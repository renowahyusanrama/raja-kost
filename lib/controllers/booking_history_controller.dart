import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/booking_model.dart';

class BookingHistoryController extends GetxController {
  final RxList<BookingModel> bookings = <BookingModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = null;
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        error.value = 'Anda harus login untuk melihat riwayat.';
        return;
      }

      final response = await _client
          .from('bookings')
          .select()
          .order('created_at', ascending: false);

      final list = (response as List<dynamic>)
          .map((e) => BookingModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();

      bookings.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      await _client.from('bookings').delete().eq('id', id);
      bookings.removeWhere((b) => b.id == id);
      Get.snackbar(
        'Pesanan dibatalkan',
        'Pesanan berhasil dihapus.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal membatalkan',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
