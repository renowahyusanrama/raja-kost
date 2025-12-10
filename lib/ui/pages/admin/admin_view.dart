import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../controllers/admin_controller.dart';
import '../../shared/widgets/app_overflow_menu.dart';
import '../../shared/widgets/custom_app_bar.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Admin',
              showBackButton: true,
              leading: AppOverflowMenu(),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchAll,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (controller.error.value != null)
                          _ErrorBanner(message: controller.error.value!),
                        _SectionCard(
                          title: 'Kamar',
                          subtitle: 'Tambah dan ubah ketersediaan kamar.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _RoomForm(controller: controller),
                              const SizedBox(height: 12),
                              Obx(() {
                                final grouped = <String, List<AdminRoom>>{};
                                for (final r in controller.rooms) {
                                  final key = r.type ?? 'lainnya';
                                  grouped.putIfAbsent(key, () => []).add(r);
                                }
                                if (grouped.isEmpty) {
                                  return const Text('Belum ada kamar.');
                                }
                                return Column(
                                  children: grouped.entries.map((entry) {
                                    final type = entry.key;
                                    final list = entry.value;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Text(
                                            type == 'lainnya'
                                                ? 'Tipe lain'
                                                : 'Tipe: $type',
                                            style: Get.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        ...list.map(
                                          (r) => _RoomTile(
                                            room: r,
                                            onToggle: (v) => controller
                                                .toggleAvailability(r, v),
                                            onDelete: () =>
                                                controller.deleteRoom(r),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Penugasan Email → Kamar',
                          subtitle:
                              'Catat email penghuni dan kamar yang ditempati.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _AssignmentForm(controller: controller),
                              const SizedBox(height: 12),
                              Obx(() {
                                final assigns = controller.assignments;
                                if (assigns.isEmpty) {
                                  return const Text('Belum ada penugasan.');
                                }
                                return Column(
                                  children: assigns
                                      .map((a) => _AssignmentTile(
                                            assignment: a,
                                            onDelete: () =>
                                                controller.deleteAssignment(a),
                                          ))
                                      .toList(),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Riwayat per Kamar',
                          subtitle:
                              'Lihat transaksi berdasarkan kamar dan layanan.',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _HistoryFilter(controller: controller),
                              const SizedBox(height: 12),
                              Obx(() {
                                if (controller.isLoadingHistory.value) {
                                  return const Center(
                                      child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ));
                                }
                                if (controller.history.isEmpty) {
                                  return const Text(
                                      'Belum ada riwayat untuk filter ini.');
                                }
                                return Column(
                                  children: controller.history
                                      .map((h) => _HistoryTile(history: h))
                                      .toList(),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
            title,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: Get.textTheme.bodyMedium?.copyWith(
                color: Get.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _RoomForm extends StatelessWidget {
  const _RoomForm({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      const typeItems = [
        DropdownMenuItem(value: 'single_fan', child: Text('Single Fan')),
        DropdownMenuItem(value: 'single_ac', child: Text('Single AC')),
        DropdownMenuItem(value: 'deluxe', child: Text('Deluxe')),
      ];

      final selectedType = controller.roomTypeCtrl.text;
      final isNew = controller.isAddingNewRoom.value;
      final codes = controller.rooms
          .where((r) => r.type == selectedType)
          .map((r) => r.code)
          .toList();

      final codeItems = [
        if (codes.isNotEmpty)
          ...codes.map((c) => DropdownMenuItem(value: c, child: Text(c))),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedType.isEmpty ? null : selectedType,
            items: typeItems,
            onChanged: (v) {
              controller.roomTypeCtrl.text = v ?? '';
              controller.roomCodeCtrl.clear();
              controller.isAddingNewRoom.value = false;
            },
            decoration: const InputDecoration(
              labelText: 'Pilih tipe kamar',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: isNew
                ? null
                : (controller.roomCodeCtrl.text.isEmpty
                    ? null
                    : controller.roomCodeCtrl.text),
            items: codeItems.isEmpty ? null : codeItems,
            onChanged: isNew
                ? null
                : (v) {
                    controller.roomCodeCtrl.text = v ?? '';
                  },
            decoration: const InputDecoration(
              labelText: 'Pilih kode kamar',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 6),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Kamar baru (kode belum ada)'),
            value: isNew,
            onChanged: (v) {
              controller.isAddingNewRoom.value = v ?? false;
              if (v == true) {
                controller.roomCodeCtrl.clear();
              }
            },
          ),
          if (isNew) ...[
            TextField(
              controller: controller.roomCodeCtrl,
              decoration: const InputDecoration(
                labelText: 'Kode baru (mis. 5C)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tersedia'),
            value: controller.roomAvailable.value,
            onChanged: (v) => controller.roomAvailable.value = v,
          ),
          const SizedBox(height: 6),
          ElevatedButton.icon(
            onPressed:
                controller.isSavingRoom.value ? null : controller.addRoom,
            icon: controller.isSavingRoom.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Simpan status'),
          ),
        ],
      );
    });
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({
    required this.room,
    required this.onToggle,
    required this.onDelete,
  });

  final AdminRoom room;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: room.isAvailable
              ? AppColors.primary.withValues(alpha: 0.25)
              : Get.theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.code,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (room.type != null && room.type!.isNotEmpty)
                  Text(
                    room.type!,
                    style: Get.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Switch(
            value: room.isAvailable,
            onChanged: onToggle,
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}

class _AssignmentForm extends StatelessWidget {
  const _AssignmentForm({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller.assignEmailCtrl,
          decoration: const InputDecoration(
            labelText: 'Email pengguna',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.assignRoomCtrl,
          decoration: const InputDecoration(
            labelText: 'Kode kamar (mis. 5C)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.assignNoteCtrl,
          decoration: const InputDecoration(
            labelText: 'Catatan (opsional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 6),
        Obx(
          () => ElevatedButton.icon(
            onPressed: controller.isSavingAssignment.value
                ? null
                : controller.saveAssignment,
            icon: controller.isSavingAssignment.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Simpan penugasan'),
          ),
        ),
      ],
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({
    required this.assignment,
    required this.onDelete,
  });

  final AdminAssignment assignment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Get.theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.userEmail,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Kamar: ${assignment.roomCode}',
                  style: Get.textTheme.bodySmall,
                ),
                if (assignment.note != null && assignment.note!.isNotEmpty)
                  Text(
                    'Catatan: ${assignment.note}',
                    style: Get.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          )
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _HistoryFilter extends StatelessWidget {
  const _HistoryFilter({required this.controller});
  final AdminController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih kamar',
          style: Get.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Obx(() {
          final options = [
            const DropdownMenuItem<String>(
              value: 'all',
              child: Text('Semua kamar'),
            ),
            ...controller.rooms.map(
              (r) => DropdownMenuItem<String>(
                value: r.code,
                child: Text(r.code),
              ),
            ),
          ];

          return DropdownButtonFormField<String>(
            initialValue: controller.selectedRoomCode.value,
            items: options,
            onChanged: (v) => controller.fetchHistory(roomCode: v ?? 'all'),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          );
        }),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.history});
  final AdminBookingHistory history;

  String _fmt(num v) {
    final s = v.toStringAsFixed(0);
    final reg = RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final email = history.assignedEmail ?? history.userEmail ?? 'Belum dicatat';
    final dateLabel =
        '${history.createdAt.day}/${history.createdAt.month}/${history.createdAt.year} '
        '${history.createdAt.hour.toString().padLeft(2, '0')}:${history.createdAt.minute.toString().padLeft(2, '0')}';
    final kind = history.isRoomBooking ? 'Booking kamar' : 'Layanan';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                  'Kamar: ${history.roomCode}',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Rp${_fmt(history.finalPrice)}',
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Chip(
            label: Text(
              kind,
              style: Get.textTheme.bodySmall?.copyWith(
                color: history.isRoomBooking
                    ? Colors.blue.shade900
                    : Colors.deepPurple,
              ),
            ),
            backgroundColor: history.isRoomBooking
                ? Colors.blue.withValues(alpha: 0.15)
                : Colors.deepPurple.withValues(alpha: 0.15),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const SizedBox(height: 4),
          Text(
            history.serviceName,
            style: Get.textTheme.bodyMedium,
          ),
          if (history.roomType != null && history.roomType!.isNotEmpty)
            Text(
              'Tipe: ${history.roomType}',
              style: Get.textTheme.bodySmall,
            ),
          const SizedBox(height: 4),
          Text(
            'Email: $email',
            style: Get.textTheme.bodySmall,
          ),
          Text(
            'Dibuat: $dateLabel',
            style: Get.textTheme.bodySmall?.copyWith(
              color: Get.theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
