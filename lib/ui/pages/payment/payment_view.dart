import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/payment_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/app_overflow_menu.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  IconData _getServiceIcon() {
    switch (controller.service.icon) {
      case 'laundry':
        return Icons.local_laundry_service;
      case 'trash':
        return Icons.delete;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'room':
        return Icons.home_work;
      default:
        return Icons.miscellaneous_services;
    }
  }

  Color _getServiceColor() {
    switch (controller.service.icon) {
      case 'laundry':
        return AppColors.laundryColor;
      case 'trash':
        return AppColors.trashColor;
      case 'cleaning':
        return AppColors.cleaningColor;
      case 'room':
        return AppColors.primary;
      default:
        return AppColors.serviceColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getServiceColor();
    final auth = Get.find<AuthController>();
    final isRoom = controller.service.category == 'room';
    final cardColor = AppColors.cardBackground;
    final shadowColor =
        (Get.isDarkMode ? Colors.black : Colors.black).withValues(
      alpha: Get.isDarkMode ? 0.18 : 0.05,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: isRoom ? 'Pembayaran Kamar' : 'Pembayaran Layanan',
              showBackButton: true,
              leading: const AppOverflowMenu(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header service
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.15),
                            color.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(_getServiceIcon(), color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.service.name,
                                  style: Get.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  controller.service.description,
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (controller.roomType != null && controller.roomCode != null)
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: .08),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: AppColors.primary.withValues(alpha: .25)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _labelType(controller.roomType!),
                                              style: Get.textTheme.bodySmall?.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Kamar ${controller.roomCode}',
                                              style: Get.textTheme.bodySmall?.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info akun + metode pembayaran
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Akun',
                            style: Get.textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.user?.email ?? '-',
                            style: Get.textTheme.titleMedium
                                ?.copyWith(color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Metode Pembayaran',
                            style: Get.textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => Row(
                              children: [
                                _PaymentMethodChip(
                                  label: 'QRIS',
                                  isSelected: controller.paymentMethod.value ==
                                      'qris',
                                  onTap: () =>
                                      controller.selectPaymentMethod('qris'),
                                ),
                                const SizedBox(width: 12),
                                _PaymentMethodChip(
                                  label: 'BNI',
                                  isSelected: controller.paymentMethod.value ==
                                      'bni',
                                  onTap: () =>
                                      controller.selectPaymentMethod('bni'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Selector jumlah/durasi
                    Text(
                      controller.isLaundry ? 'Pilih Jumlah Cucian' : 'Pilih Durasi Pembayaran',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Jumlah ${controller.unitLabel}',
                                style: Get.textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: controller.decrementMonths,
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.remove, color: AppColors.primary, size: 20),
                                    ),
                                  ),
                                  Obx(() => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                        ),
                                        child: Text(
                                          '${controller.months.value}',
                                          style: Get.textTheme.titleMedium?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )),
                                  IconButton(
                                    onPressed: controller.incrementMonths,
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add, color: AppColors.primary, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Obx(() => Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: controller.months.value / controller.maxUnits,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [color, color.withValues(alpha: 0.8)],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 8),
                          Text(
                            '1 - ${controller.maxUnits} ${controller.isLaundry ? 'kg' : 'bulan'}',
                            style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Rincian
                    Text(
                      'Rincian Pembayaran',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Harga ${controller.priceUnitLabel}',
                                  style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                              Text('Rp${controller.formattedMonthlyPrice}',
                                  style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Jumlah ${controller.unitLabel}',
                                  style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
                              Obx(() => Text('${controller.months.value}x',
                                  style: Get.textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary))),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppColors.divider),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal',
                                  style: Get.textTheme.titleMedium?.copyWith(
                                      color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                              Obx(() => Text('Rp${controller.formattedTotalPrice}',
                                  style: Get.textTheme.titleMedium?.copyWith(
                                      color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
                            ],
                          ),
                          Obx(() {
                            // paksa akses months agar reactive meskipun laundry
                            final _ = controller.months.value;
                            final pct = controller.discountPercentage;
                            if (pct > 0) {
                              final disc = controller.discountAmount;
                              final s = _fmt(disc);
                              final p = (pct * 100).toInt();
                              return Column(children: [
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Diskon ($p%)',
                                        style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.success)),
                                    Text('-Rp$s',
                                        style: Get.textTheme.bodyMedium?.copyWith(color: AppColors.success)),
                                  ],
                                ),
                              ]);
                            }
                            return const SizedBox.shrink();
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                                color: AppColors.divider, thickness: 2),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total Pembayaran',
                                  style: Get.textTheme.headlineSmall?.copyWith(
                                      color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                              Obx(() => Text('Rp${controller.formattedFinalPrice}',
                                  style: Get.textTheme.headlineSmall?.copyWith(
                                      color: color, fontWeight: FontWeight.w700))),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: controller.isProcessing.value ? null : controller.processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: color.withValues(alpha: 0.3),
                            ),
                            child: controller.isProcessing.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.payment, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Bayar Sekarang',
                                          style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                          ),
                        )),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Dengan melanjutkan pembayaran, Anda menyetujui\nsyarat dan ketentuan yang berlaku',
                        style: Get.textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(num v) {
    final s = v.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }

  String _labelType(String type) {
    switch (type) {
      case 'single_fan':
        return 'Single Fan';
      case 'single_ac':
        return 'Single AC';
      case 'deluxe':
        return 'Deluxe';
      default:
        return type;
    }
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'QRIS' ? Icons.qr_code_2 : Icons.account_balance,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Get.textTheme.bodyMedium?.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
