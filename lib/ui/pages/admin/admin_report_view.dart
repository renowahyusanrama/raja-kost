import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../controllers/admin_report_controller.dart';
import '../../../data/models/report_model.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/app_overflow_menu.dart';
import '../../shared/widgets/loading_widget.dart';

class AdminReportView extends GetView<AdminReportController> {
  const AdminReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Laporan Pengguna',
              showBackButton: true,
              leading: AppOverflowMenu(),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const LoadingWidget();
                }
                if (controller.error.value != null) {
                  return Center(child: Text(controller.error.value!));
                }

                final list = controller.reports;
                return RefreshIndicator(
                  onRefresh: controller.fetchReports,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _FilterChips(controller: controller),
                      const SizedBox(height: 12),
                      if (list.isEmpty)
                        const Text('Belum ada laporan untuk filter ini.'),
                      ...list.map(
                        (r) => _AdminReportTile(
                          report: r,
                          onChangeStatus: (status) =>
                              controller.updateStatus(r, status, adminNote: ''),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller});
  final AdminReportController controller;

  @override
  Widget build(BuildContext context) {
    const filters = [
      {'value': 'all', 'label': 'Semua'},
      {'value': 'open', 'label': 'Open'},
      {'value': 'resolved', 'label': 'Resolved'},
      {'value': 'closed', 'label': 'Closed'},
    ];

    return Wrap(
      spacing: 8,
      children: [
        ...filters.map(
          (f) => Obx(
            () => ChoiceChip(
              label: Text(f['label']!),
              selected: controller.filterStatus.value == f['value'],
              onSelected: (_) => controller.fetchReports(status: f['value']!),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminReportTile extends StatelessWidget {
  const _AdminReportTile({
    required this.report,
    required this.onChangeStatus,
  });

  final ReportModel report;
  final ValueChanged<String> onChangeStatus;

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
    final statusColor = _statusColor(report.status);
    final dateLabel =
        '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          Text(
            report.message,
            style: Get.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Email: ${report.userEmail ?? '-'}',
            style: Get.textTheme.bodySmall,
          ),
          Text(
            'Dibuat: $dateLabel',
            style: Get.textTheme.bodySmall
                ?.copyWith(color: Get.theme.colorScheme.onSurfaceVariant),
          ),
          if (report.category != null && report.category!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Kategori: ${report.category}',
                style: Get.textTheme.bodySmall,
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
          Wrap(
            spacing: 8,
            children: [
              _StatusButton(
                label: 'Open',
                onTap: () => onChangeStatus('open'),
                active: report.status == 'open',
              ),
              _StatusButton(
                label: 'Resolved',
                onTap: () => onChangeStatus('resolved'),
                active: report.status == 'resolved',
              ),
              _StatusButton(
                label: 'Closed',
                onTap: () => onChangeStatus('closed'),
                active: report.status == 'closed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.label,
    required this.onTap,
    required this.active,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: active
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
