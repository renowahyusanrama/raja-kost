import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../controllers/detail_controller.dart';
import '../../../data/models/kost_model.dart'; // tombol back pakai ini utk gaya, tapi ditempatkan manual
import '../../../data/models/service_model.dart';
import 'widgets/image_gallery.dart';
import '../../shared/widgets/app_overflow_menu.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        // state aman
        final kost = controller.kost;
        if (kost == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ======= HEADER GAMBAR FULL (HERO) =======
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Gambar full, sudut bawah rounded
                  Hero(
                    tag: 'kost_img_${kost.id}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                      child: ImageGallery.headerHero(
                        images: const [], // pakai asset sesuai tipe agar sama dengan katalog
                        kostType: kost.type,
                      ),
                    ),
                  ),

                  // Tombol back & title overlay
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                      child: Row(
                        children: [
                          const AppOverflowMenu(),
                          const SizedBox(width: 8),
                          // back pojok kiri
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_back),
                            ),
                          ),
                          const Spacer(),
                          // dot page indicator kecil (opsional, biar rapih)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ======= KONTEN =======
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: _DetailBody(kost: kost),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.kost});
  final KostModel kost;

  Color _typeColor(String t) {
    switch (t) {
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

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(kost.type);
    final ctrl = Get.find<DetailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // judul + badge tipe
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                kost.name,
                style: Get.textTheme.headlineMedium,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                kost.type.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(
                  color: typeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .3,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // harga
        Text(
          'Rp${_rupiah(kost.price)}/bulan',
          style: Get.textTheme.headlineMedium?.copyWith(
            color: typeColor,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        // lokasi
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                kost.location,
                style: Get.textTheme.bodyLarge,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // rating
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              kost.rating.toStringAsFixed(1),
              style: Get.textTheme.bodyLarge,
            ),
            const SizedBox(width: 8),
            Text(
              '(120 ulasan)',
              style: Get.textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text('Deskripsi', style: Get.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(kost.description, style: Get.textTheme.bodyLarge),

        const SizedBox(height: 24),

        Text('Fasilitas', style: Get.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kost.facilities.map((f) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                f,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // status
        Obx(() {
          if (ctrl.isLoadingRooms.value) {
            return Row(
              children: [
                Text('Status: ', style: Get.textTheme.bodyLarge),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            );
          }

          final rooms = ctrl.roomStatuses;
          if (rooms.isEmpty) {
            return Row(
              children: [
                Text('Status: ', style: Get.textTheme.bodyLarge),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (kost.available ? Colors.green : Colors.red)
                        .withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kost.available ? 'Tersedia' : 'Penuh',
                    style: TextStyle(
                      color: kost.available ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }

          final anyAvail = rooms.any((r) => r.isAvailable);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status kamar (${kost.type}): ${anyAvail ? 'Ada yang tersedia' : 'Penuh'}',
                style: Get.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: anyAvail ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: rooms
                    .map(
                      (r) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (r.isAvailable ? Colors.green : Colors.red)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: r.isAvailable ? Colors.green : Colors.red,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          r.code,
                          style: TextStyle(
                            color: r.isAvailable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        }),

        const SizedBox(height: 32),

        // tombol pesan (simple)
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: typeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            onPressed: () {
              final service = ServiceModel(
                id: 'kost_${kost.id}',
                name: 'Sewa ${kost.name}',
                description: 'Sewa kamar kost tipe ${kost.type}',
                price: kost.price,
                unit: 'bulan',
                icon: 'room',
                category: 'room',
              );

              Get.toNamed(
                '/payment',
                arguments: {
                  'service': service,
                  'roomType': kost.type,
                  // roomCode bisa dipilih di tempat lain (opsional)
                },
              );
            },
            child: Text(
              'Pesan Sekarang',
              style: Get.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _rupiah(num value) {
    final s = value.toStringAsFixed(0);
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => '${m[1]}.');
  }
}
