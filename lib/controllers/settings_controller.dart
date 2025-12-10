import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_controller.dart';

class SettingsController extends GetxController {
  final RxBool isDeletingAccount = false.obs;
  final RxBool isLoggingOut = false.obs;

  AuthController get _auth => Get.find<AuthController>();
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await _auth.logout();
    } catch (e) {
      Get.snackbar(
        'Logout gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoggingOut.value = false;
    }
  }

  Future<void> deleteAccount() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      Get.snackbar(
        'Butuh login',
        'Silakan login dulu untuk menghapus akun.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.toNamed('/login');
      return;
    }

    if (isDeletingAccount.value) return;
    isDeletingAccount.value = true;

    try {
      // hapus data transaksi user terlebih dahulu
      await _client.from('bookings').delete().eq('user_id', user.id);

      // coba hapus akun auth (butuh service role). Jika gagal, tidak fatal.
      bool accountDeleted = false;
      try {
        await _client.auth.admin.deleteUser(user.id);
        accountDeleted = true;
      } catch (_) {
        accountDeleted = false;
      }

      await _client.auth.signOut();
      Get.offAllNamed('/home');

      Get.snackbar(
        accountDeleted ? 'Akun dihapus' : 'Data dihapus',
        accountDeleted
            ? 'Akun dan transaksi sudah dibersihkan.'
            : 'Transaksi dibersihkan dan sesi diakhiri. Untuk hapus akun di Supabase, aktifkan service-role/Edge Function.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal menghapus akun',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }
}
