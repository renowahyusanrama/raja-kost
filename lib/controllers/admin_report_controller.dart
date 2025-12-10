import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/report_model.dart';
import 'auth_controller.dart';

class AdminReportController extends GetxController {
  final RxList<ReportModel> reports = <ReportModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString filterStatus = 'all'.obs; // all | open | resolved | closed
  final RxnString error = RxnString();

  SupabaseClient get _client => Supabase.instance.client;
  AuthController get _auth => Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _ensureAdmin();
    fetchReports();
  }

  void _ensureAdmin() {
    if (!_auth.isAdmin) {
      Get.snackbar(
        'Akses ditolak',
        'Hanya admin yang dapat membuka halaman laporan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Future.microtask(() => Get.back());
    }
  }

  Future<void> fetchReports({String? status}) async {
    final stat = status ?? filterStatus.value;
    filterStatus.value = stat;
    isLoading.value = true;
    error.value = null;
    try {
      dynamic query = _client.from('reports').select();
      if (stat != 'all') {
        query = query.eq('status', stat);
      }
      query = query.order('created_at', ascending: false);
      final resp = await query;
      reports.assignAll(
        (resp as List<dynamic>)
            .map((e) => ReportModel.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } catch (e) {
      error.value = 'Gagal memuat laporan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(ReportModel r, String status,
      {String? adminNote}) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      await _client.from('reports').update({
        'status': status,
        if (adminNote != null && adminNote.isNotEmpty) 'admin_note': adminNote,
      }).eq('id', r.id);
      await fetchReports(status: filterStatus.value);
    } catch (e) {
      Get.snackbar(
        'Gagal memperbarui',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
    }
  }
}
