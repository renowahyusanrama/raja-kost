import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/report_model.dart';
import 'auth_controller.dart';

class ReportController extends GetxController {
  final RxList<ReportModel> reports = <ReportModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isUpdating = false.obs;
  final RxnString error = RxnString();

  final subjectTextCtrl = TextEditingController();
  final messageTextCtrl = TextEditingController();
  final categoryTextCtrl = TextEditingController();

  SupabaseClient get _client => Supabase.instance.client;
  AuthController get _auth => Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  @override
  void onClose() {
    subjectTextCtrl.dispose();
    messageTextCtrl.dispose();
    categoryTextCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchReports() async {
    isLoading.value = true;
    error.value = null;
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        reports.clear();
        return;
      }
      final resp = await _client
          .from('reports')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
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

  Future<void> submitReport() async {
    final subject = subjectTextCtrl.text.trim();
    final message = messageTextCtrl.text.trim();
    final category = categoryTextCtrl.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      Get.snackbar(
        'Form belum lengkap',
        'Isi subjek dan pesan laporan.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (isSubmitting.value) return;

    isSubmitting.value = true;
    try {
      final user = _client.auth.currentUser;
      final email = user?.email ?? _auth.user?.email;
      await _client.from('reports').insert({
        'subject': subject,
        'message': message,
        'category': category.isEmpty ? null : category,
        'status': 'open',
        'user_id': user?.id,
        'user_email': email,
      });
      subjectTextCtrl.clear();
      messageTextCtrl.clear();
      categoryTextCtrl.clear();
      await fetchReports();
      Get.snackbar(
        'Terkirim',
        'Laporan Anda sudah dikirim ke admin.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal mengirim',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await _client.from('reports').delete().eq('id', id);
      reports.removeWhere((r) => r.id == id);
    } catch (e) {
      Get.snackbar('Gagal menghapus', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateReport(ReportModel r,
      {required String subject,
      required String message,
      String? category}) async {
    if (isUpdating.value) return;
    isUpdating.value = true;
    try {
      await _client.from('reports').update({
        'subject': subject,
        'message': message,
        'category': category,
      }).eq('id', r.id);
      await fetchReports();
    } catch (e) {
      Get.snackbar('Gagal memperbarui', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isUpdating.value = false;
    }
  }
}
