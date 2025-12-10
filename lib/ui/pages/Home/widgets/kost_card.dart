import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../data/models/kost_model.dart';

class KostCard extends StatelessWidget {
  final KostModel kost;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback onTap;

  const KostCard({
    super.key,
    required this.kost,
    this.isFavorite = false,
    this.onToggleFavorite,
    required this.onTap,
  });

  Color _getTypeColor() {
    switch (kost.type) {
      case 'single_fan':
        return AppColors.singleFanColor;
      case 'single_ac':
        return AppColors.singleACColor;
      case 'deluxe':
        return AppColors.deluxeColor;
      default:
        return AppColors.primary;
    }
  }

  String _assetForType() {
    switch (kost.type) {
      case 'single_fan':
        return 'assets/images/kamar-single-fan.jpg';
      case 'single_ac':
        return 'assets/images/kamar-ac.jpg';
      case 'deluxe':
        return 'assets/images/kamar-deluxe.jpg';
      default:
        return 'assets/images/kamar-single-fan.jpg';
    }
  }

  /// Widget gambar lokal sesuai tipe kamar
  Widget _buildImage() {
    final String assetPath = _assetForType();
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color typeColor = _getTypeColor();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (value * 0.05),
          child: Opacity(
            opacity: value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06 * value),
                    blurRadius: 10 * value,
                    offset: Offset(0, 3 * value),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Feedback.forTap(context);
                    onTap();
                  },
                  splashColor: typeColor.withValues(alpha: 0.15),
                  highlightColor: typeColor.withValues(alpha: 0.08),
                  child: Row(
                    children: [
                      // --- Image: Hero HANYA di gambar + ukuran fix & konsisten ---
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: Hero(
                          tag: 'kost_img_${kost.id}', // TAG BARU & KONSISTEN
                          child: SizedBox(
                            width: 150,
                            height: 200,
                            child: _buildImage(), // BoxFit.cover di dalam
                          ),
                        ),
                      ),
                      // --- Content ---
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type badge + favorite icon
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: typeColor
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: typeColor
                                              .withValues(alpha: .35),
                                        ),
                                      ),
                                      child: Text(
                                        kost.type
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: typeColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: .4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (onToggleFavorite != null) ...[
                                    const SizedBox(width: 8),
                                    InkResponse(
                                      onTap: () {
                                        Feedback.forTap(context);
                                        onToggleFavorite?.call();
                                      },
                                      radius: 18,
                                      child: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 20,
                                        color: isFavorite
                                            ? Colors.redAccent
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Name
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 100),
                                style: Get.textTheme.titleLarge ??
                                    const TextStyle(),
                                child: Text(
                                  kost.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Location
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      style: Get.textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textSecondary,
                                          ) ??
                                          const TextStyle(),
                                      child: Text(
                                        kost.location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Rating
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 100),
                                    style: Get.textTheme.bodyMedium ??
                                        const TextStyle(),
                                    child: Text(
                                      kost.rating.toStringAsFixed(1),
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // Price + Availability
                              Row(
                                children: [
                                  // Harga dibatasi agar tidak mendorong chip
                                  Expanded(
                                    child: AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      style: Get.textTheme.titleLarge?.copyWith(
                                            color: typeColor,
                                            fontWeight: FontWeight.w800,
                                          ) ??
                                          const TextStyle(),
                                      child: Text(
                                        'Rp${_formatRupiah(kost.price)}/bulan',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // Availability chip
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (kost.available
                                                ? Colors.green
                                                : Colors.red)
                                            .withValues(alpha: .15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: (kost.available
                                                ? Colors.green
                                                : Colors.red)
                                            .withValues(alpha: .35),
                                      ),
                                    ),
                                    child: Text(
                                      kost.available ? 'Tersedia' : 'Penuh',
                                      style: TextStyle(
                                        color: kost.available
                                            ? Colors.green
                                            : Colors.red,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Format: 1200000 -> 1.200.000
  String _formatRupiah(num value) {
    final s = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }
}
