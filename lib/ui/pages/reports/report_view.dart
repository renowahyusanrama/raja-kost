import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../controllers/report_controller.dart';
import '../../../data/models/report_model.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/app_overflow_menu.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Laporan',
              showBackButton: true,
              leading: AppOverflowMenu(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReportForm(controller: controller),
                    const SizedBox(height: 16),
                    Text(
                      'Riwayat Laporan Saya',
                      style: Get.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      if (controller.reports.isEmpty) {
                        return const Text('Belum ada laporan.');
                      }
                      return Column(
                        children: controller.reports
                            .map((r) => _ReportTile(report: r))
                            .toList(),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportForm extends StatelessWidget {
  const _ReportForm({required this.controller});
  final ReportController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kirim Laporan',
            style: Get.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller.subjectTextCtrl,
            decoration: const InputDecoration(
              labelText: 'Subjek',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.categoryTextCtrl,
            decoration: const InputDecoration(
              labelText: 'Kategori (opsional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller.messageTextCtrl,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Pesan',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => ElevatedButton.icon(
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.submitReport,
              icon: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: const Text('Kirim Laporan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  const _ReportTile({required this.report});
  final ReportModel report;

  Color _statusColor(String s) {
    switch (s) {
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();
    final statusColor = _statusColor(report.status);
    final dateLabel =
        '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.subject,
                  style: Get.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (report.category != null && report.category!.isNotEmpty)
            Text('Kategori: ${report.category}',
                style: Get.textTheme.bodySmall),
          Text(
            report.message,
            style: Get.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Dibuat: $dateLabel',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (report.adminNote != null && report.adminNote!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Catatan admin: ${report.adminNote}',
                style: Get.textTheme.bodySmall?.copyWith(
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  _showEditDialog(context, controller, report);
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Hapus laporan?',
                    middleText: 'Laporan akan dihapus permanen.',
                    textConfirm: 'Hapus',
                    textCancel: 'Batal',
                    confirmTextColor: Colors.white,
                    buttonColor: AppColors.error,
                    onConfirm: () {
                      Get.back();
                      controller.deleteReport(report.id);
                    },
                  );
                },
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Hapus'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    ReportController controller,
    ReportModel report,
  ) {
    final subCtrl = TextEditingController(text: report.subject);
    final msgCtrl = TextEditingController(text: report.message);
    final catCtrl = TextEditingController(text: report.category ?? '');

    Get.defaultDialog(
      title: 'Edit laporan',
      content: Column(
        children: [
          TextField(
            controller: subCtrl,
            decoration: const InputDecoration(labelText: 'Subjek'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: catCtrl,
            decoration:
                const InputDecoration(labelText: 'Kategori (opsional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: msgCtrl,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Pesan'),
          ),
        ],
      ),
      textConfirm: 'Simpan',
      textCancel: 'Batal',
      onConfirm: () {
        controller.updateReport(
          report,
          subject: subCtrl.text.trim(),
          message: msgCtrl.text.trim(),
          category: catCtrl.text.trim().isEmpty ? null : catCtrl.text.trim(),
        );
        Get.back();
      },
    );
  }
}
