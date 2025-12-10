import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/service_model.dart';

class PaymentController extends GetxController {
  // service yg dibayar (wajib)
  late final ServiceModel service;

  // pilihan kamar (opsional)
  String? roomType; // 'single_fan' | 'single_ac' | 'deluxe'
  String? roomCode; // contoh: '1C'

  // state durasi & proses
  final RxInt months = 1.obs; // dipakai juga sbg "jumlah" utk laundry
  final RxBool isProcessing = false.obs;
  final RxString paymentMethod = 'qris'.obs;

  SupabaseClient get _client => Supabase.instance.client;

  // tipe layanan khusus: laundry (satuan kg)
  bool get isLaundry {
    final u = service.unit.toLowerCase();
    return service.icon == 'laundry' ||
        u == 'kg' ||
        service.category == 'laundry';
  }

  // batas maksimal
  int get maxUnits => isLaundry ? 50 : 12;

  // diskon contoh: hanya berlaku untuk langganan bulanan
  // selalu akses months.value agar Obx mendeteksi dependency meski isLaundry true
  double get discountPercentage {
    final m = months.value; // dependensi reaktif
    if (isLaundry) return 0.0;
    return m >= 12 ? 0.10 : 0.0;
  }

  // harga
  num get monthlyPrice => service.price; // utk laundry: harga per KG
  num get totalPrice => monthlyPrice * months.value;
  num get discountAmount => totalPrice * discountPercentage;
  num get finalPrice => totalPrice - discountAmount;

  String get formattedMonthlyPrice => _fmt(monthlyPrice);
  String get formattedTotalPrice => _fmt(totalPrice);
  String get formattedFinalPrice => _fmt(finalPrice);

  // label bantu utk UI
  String get unitLabel => isLaundry ? 'KG' : 'Bulan';
  String get priceUnitLabel => isLaundry ? 'per KG' : 'per Bulan';

  @override
  void onInit() {
    super.onInit();
    _readArgumentsSafely();
  }

  void _readArgumentsSafely() {
    final args = Get.arguments;

    if (args is ServiceModel) {
      // pola lama: kirim ServiceModel langsung
      service = args;
      return;
    }

    if (args is Map) {
      // pola baru: { service, roomType, roomCode }
      final raw = args['service'];
      if (raw is ServiceModel) {
        service = raw;
      } else if (raw is Map) {
        service = ServiceModel.fromJson(Map<String, dynamic>.from(raw));
      } else {
        throw 'Argumen "service" tidak valid';
      }
      roomType = args['roomType'] as String?;
      roomCode = args['roomCode'] as String?;
      return;
    }

    throw 'Get.arguments tidak valid untuk PaymentView';
  }

  void incrementMonths() {
    if (months.value < maxUnits) months.value++;
  }

  void decrementMonths() {
    if (months.value > 1) months.value--;
  }

  void selectPaymentMethod(String method) {
    paymentMethod.value = method;
  }

  Future<void> processPayment() async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Login diperlukan',
          'Silakan login terlebih dahulu sebelum memesan.',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.toNamed('/login');
        return;
      }

      // simulasi proses pembayaran
      await Future.delayed(const Duration(seconds: 1));

      await _client.from('bookings').insert({
        'user_id': user.id,
        'service_id': service.id,
        'service_name': service.name,
        'room_type': roomType,
        'room_code': roomCode,
        'quantity': months.value,
        'price_per_unit': monthlyPrice,
        'total_price': totalPrice,
        'discount': discountAmount,
        'final_price': finalPrice,
      });

      Get.snackbar(
        'Pembayaran',
        'Booking ${service.name} berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      final rawMessage = e.toString();
      final isOfflineError = rawMessage.contains('SocketException') ||
          rawMessage.contains('Failed host lookup') ||
          rawMessage.contains('No address associated with hostname');

      Get.snackbar(
        'Pembayaran gagal',
        isOfflineError ? 'Anda sedang offline' : rawMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  String _fmt(num v) {
    final s = v.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }
}
