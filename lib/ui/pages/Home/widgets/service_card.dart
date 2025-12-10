import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/service_model.dart';
import '../../../../app/theme/app_colors.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;

  /// Callback opsional untuk handle pemesanan.
  /// Jika diset, widget akan memanggil `onOrder(service)` (mis. buka selector kamar).
  /// Jika null, fallback ke perilaku lama: langsung ke '/payment'.
  final void Function(ServiceModel service)? onOrder;

  const ServiceCard({
    super.key,
    required this.service,
    this.onOrder,
  });

  IconData _getIcon() {
    switch (service.icon) {
      case 'laundry':
        return Icons.local_laundry_service;
      case 'trash':
        return Icons.delete;
      case 'cleaning':
        return Icons.cleaning_services;
      default:
        return Icons.miscellaneous_services;
    }
  }

  Color _getIconColor() {
    switch (service.icon) {
      case 'laundry':
        return AppColors.laundryColor;
      case 'trash':
        return AppColors.trashColor;
      case 'cleaning':
        return AppColors.cleaningColor;
      default:
        return AppColors.serviceColor;
    }
  }

  void _handleOrderTap(BuildContext context) {
    Feedback.forTap(context);
    if (onOrder != null) {
      onOrder!(service);
    } else {
      // fallback: perilaku lama
      Get.toNamed('/payment', arguments: service);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.96 + (value * 0.04),
          child: Opacity(
            opacity: value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05 * value),
                    blurRadius: 10 * value,
                    offset: Offset(0, 2 * value),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _handleOrderTap(context),
                  splashColor: iconColor.withValues(alpha: 0.15),
                  highlightColor: iconColor.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                iconColor.withValues(alpha: 0.20),
                                iconColor.withValues(alpha: 0.10),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_getIcon(), color: iconColor, size: 24),
                        ),

                        const SizedBox(width: 16),

                        // Title & description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 150),
                                style: Get.textTheme.titleMedium ??
                                    const TextStyle(),
                                child: Text(
                                  service.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 150),
                                style: Get.textTheme.bodyMedium ??
                                    const TextStyle(),
                                child: Text(
                                  service.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price + unit + button
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 150),
                              style: (Get.textTheme.titleMedium ??
                                      const TextStyle())
                                  .copyWith(color: AppColors.serviceColor),
                              child: Text(
                                'Rp${service.price.toString().replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (m) => '${m[1]}.',
                                    )}',
                              ),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 150),
                              style:
                                  Get.textTheme.bodyMedium ?? const TextStyle(),
                              child: Text('/${service.unit}'),
                            ),
                            const SizedBox(height: 4),

                            // Tombol "Pesan" — trigger callback/fallback
                            InkWell(
                              onTap: () => _handleOrderTap(context),
                              borderRadius: BorderRadius.circular(8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Pesan',
                                  style: (Get.textTheme.bodySmall ??
                                          const TextStyle())
                                      .copyWith(
                                    color: iconColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
