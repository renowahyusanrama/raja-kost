import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/booking_history_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/app_overflow_menu.dart';

class BookingHistoryView extends GetView<BookingHistoryController> {
  const BookingHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Riwayat Pesanan',
              showBackButton: true,
              leading: const AppOverflowMenu(),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.value != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.error.value!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: controller.fetchBookings,
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.bookings.isEmpty) {
                  return const Center(
                    child: Text('Belum ada pesanan.'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchBookings,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final b = controller.bookings[index];
                      final created =
                          '${b.createdAt.day}/${b.createdAt.month}/${b.createdAt.year} '
                          '${b.createdAt.hour.toString().padLeft(2, '0')}:${b.createdAt.minute.toString().padLeft(2, '0')}';

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (Get.isDarkMode ? Colors.black : Colors.black)
                                      .withValues(
                                          alpha: Get.isDarkMode ? 0.18 : 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    b.serviceName,
                                    style: Get.textTheme.titleMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Rp${_fmt(b.finalPrice)}',
                                  style: Get.textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dibuat: $created',
                              style: Get.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (b.roomType != null || b.roomCode != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  [
                                    if (b.roomType != null)
                                      'Tipe: ${b.roomType}',
                                    if (b.roomCode != null)
                                      'Kamar: ${b.roomCode}',
                                  ].join(' • '),
                                  style: Get.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              'Jumlah: ${b.quantity}',
                              style: Get.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  Get.defaultDialog(
                                    title: 'Batalkan Pesanan?',
                                    middleText:
                                        'Pesanan akan dihapus dari riwayat.',
                                    textConfirm: 'Ya, Batalkan',
                                    textCancel: 'Batal',
                                    confirmTextColor: Colors.white,
                                    buttonColor: AppColors.error,
                                    onConfirm: () {
                                      Get.back();
                                      controller.cancelBooking(b.id);
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.cancel,
                                  color: AppColors.error,
                                ),
                                label: const Text(
                                  'Batalkan',
                                  style: TextStyle(color: AppColors.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: controller.bookings.length,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(num v) {
    final s = v.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }
}
