import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final Rxn<User> _user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  User? get user => _user.value;
  bool get isLoggedIn => _user.value != null;
  bool get isAdmin =>
      _user.value?.appMetadata['role']?.toString().toLowerCase() == 'admin';

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    _user.value = _client.auth.currentUser;
    _client.auth.onAuthStateChange.listen((data) {
      _user.value = data.session?.user;
    });
  }

  Future<void> register(String email, String password) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user ?? _client.auth.currentUser;

      if (user != null) {
        // Jika project tidak butuh verifikasi email, session akan langsung ada
        if (response.session != null || _client.auth.currentUser != null) {
          Get.offAllNamed('/home');
          Get.snackbar(
            'Registrasi berhasil',
            'Selamat datang, ${user.email ?? ''}',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          // Mode verifikasi email: user dibuat tapi belum login
          Get.snackbar(
            'Registrasi berhasil',
            'Silakan cek email $email untuk verifikasi lalu login.',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.offAllNamed('/login');
        }
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Autentikasi gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      final msg = 'Terjadi kesalahan: $e';
      errorMessage.value = msg;
      Get.snackbar(
        'Autentikasi gagal',
        msg,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    await _authCommon(() => _client.auth.signInWithPassword(
          email: email,
          password: password,
        ));
  }

  Future<void> _authCommon(Future<AuthResponse> Function() action) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await action();
      if (_client.auth.currentUser != null) {
        Get.offAllNamed('/home');
      }
    } on AuthException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Autentikasi gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      final msg = 'Terjadi kesalahan: $e';
      errorMessage.value = msg;
      Get.snackbar(
        'Autentikasi gagal',
        msg,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    Get.offAllNamed('/home');
  }
}
