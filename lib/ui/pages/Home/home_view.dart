import 'package:flutter/material.dart';
import 'package:raja_kost/ui/pages/Home/widgets/background_bubbles.dart';
import 'package:get/get.dart';

import '../../../controllers/home_controller.dart';
import '../../../controllers/catalog_dio_controller.dart';
import '../../../app/theme/app_colors.dart';
import '../../../ui/shared/widgets/custom_app_bar.dart';
import '../../../ui/shared/widgets/loading_widget.dart';
import '../../../ui/shared/widgets/error_widget.dart';
import '../../../ui/shared/widgets/app_overflow_menu.dart';
import 'widgets/search_bar.dart';
import 'widgets/kost_card.dart';
import 'widgets/service_card.dart';
import 'widgets/section_header_box.dart';

// helper pilih kamar (VERSI BARU: return RoomSelection)
import '../../../ui/shared/widgets/room_selector.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final catalogController = Get.find<CatalogDioController>();

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            const BackgroundBubbles(),
            Column(
              children: [
                CustomAppBar(
                  title: 'Raja Kost',
                  subtitle: 'Kost Impian Anak UMM',
                  leading: const AppOverflowMenu(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: SearchBarWidget(onChanged: controller.searchKost),
                ),
                Expanded(
                  child: Obx(() {
                    if (catalogController.isLoading) {
                      return const LoadingWidget();
                    }
                    if (catalogController.error != null) {
                      return CustomErrorWidget(
                        message: catalogController.error!,
                        onRetry: catalogController.refreshData,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: catalogController.refreshData,
                      child: SingleChildScrollView(
                        primary: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ====== KAMAR ======
                            SectionHeaderBox(
                              title: 'Kamar',
                              child: _buildFilterChips(),
                            ),
                            const SizedBox(height: 15),

                            // Grid/list kost
                            LayoutBuilder(
                              builder: (context, c) {
                                final isWide = c.maxWidth >= 900;
                                if (!isWide) {
                                  return Column(
                                    children: controller.filteredKostList
                                        .map<Widget>((kost) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 14.0),
                                              child: KostCard(
                                                kost: kost,
                                                isFavorite:
                                                    controller.isFavorite(kost),
                                                onToggleFavorite: () =>
                                                    controller
                                                        .toggleFavorite(kost),
                                                onTap: () => Get.toNamed(
                                                  '/detail',
                                                  arguments: kost,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  );
                                }

                                const hGap = 16.0;
                                final itemW = (c.maxWidth - hGap) / 2;
                                final items = <Widget>[];

                                for (var i = 0;
                                    i < controller.filteredKostList.length;
                                    i++) {
                                  final kost = controller.filteredKostList[i];
                                  final left = i.isEven;

                                  items.add(
                                    Container(
                                      width: itemW,
                                      margin: EdgeInsets.only(
                                        bottom: 16,
                                        top: left ? 0 : 12,
                                      ),
                                      child: KostCard(
                                        kost: kost,
                                        isFavorite:
                                            controller.isFavorite(kost),
                                        onToggleFavorite: () =>
                                            controller.toggleFavorite(kost),
                                        onTap: () => Get.toNamed(
                                          '/detail',
                                          arguments: kost,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return Wrap(
                                    spacing: hGap,
                                    runSpacing: 0,
                                    children: items);
                              },
                            ),

                            const SizedBox(height: 18),

                            // ====== LAYANAN TAMBAHAN ======
                            SectionHeaderBox(
                              title: 'Layanan Tambahan',
                              child: Column(
                                children: controller.filteredServiceList
                                    .map<Widget>((service) => Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: ServiceCard(
                                            service: service,
                                            onOrder: (svc) async {
                                              // Ambil tipe dari filter (sebagai preselect), boleh null
                                              final current = controller
                                                  .selectedCategory.value;
                                              final initialType = (current ==
                                                          'single_fan' ||
                                                      current == 'single_ac' ||
                                                      current == 'deluxe')
                                                  ? current
                                                  : null;

                                              // >>>> Versi baru: pilih TIPE + KODE kamar
                                              final sel =
                                                  await selectRoomBottomSheet(
                                                initialType: initialType,
                                              );
                                              if (sel == null) return;

                                              // Lanjut ke pembayaran
                                              Get.toNamed('/payment',
                                                  arguments: {
                                                    'service': svc,
                                                    'roomType': sel
                                                        .roomType, // 'single_fan' | 'single_ac' | 'deluxe'
                                                    'roomCode': sel
                                                        .roomCode, // '1C', '2B', '1A', ...
                                                  });
                                            },
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),

                            const SizedBox(height: 140),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 42,
      child: ListView(
        padding: const EdgeInsets.only(right: 8),
        scrollDirection: Axis.horizontal,
        children: [
          _chip('all', 'Semua'),
          _chip('single_fan', 'Single Fan'),
          _chip('single_ac', 'Single AC'),
          _chip('deluxe', 'Deluxe'),
          _chip('favorites', 'Favorit'),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: FilterChip(
          label: Text(label),
          selected: controller.selectedCategory.value == value,
          onSelected: (_) => controller.filterByCategory(value),
          backgroundColor: AppColors.cardBackground,
          selectedColor: AppColors.primary.withValues(alpha: 0.18),
          checkmarkColor: AppColors.primary,
          labelStyle: TextStyle(
            color: controller.selectedCategory.value == value
                ? AppColors.primary
                : Get.theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: controller.selectedCategory.value == value
                ? AppColors.primary.withValues(alpha: .45)
                : Get.theme.colorScheme.outline.withOpacity(0.25),
          ),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}
