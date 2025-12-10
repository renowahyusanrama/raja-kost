import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raja_kost/ui/pages/Home/widgets/background_bubbles.dart';

import '../../../app/theme/app_colors.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/catalog_dio_controller.dart';
import '../../../ui/shared/widgets/custom_app_bar.dart';
import '../../../ui/shared/widgets/loading_widget.dart';
import '../../../ui/shared/widgets/error_widget.dart';
import '../../shared/widgets/app_overflow_menu.dart';
import 'widgets/kost_card.dart';

class WishlistView extends GetView<HomeController> {
  const WishlistView({super.key});

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
                  title: 'Wishlist',
                  subtitle: 'Kost favoritmu',
                  showBackButton: true,
                  leading: const AppOverflowMenu(),
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

                    final favorites = catalogController.kostList
                        .where((k) => controller.isFavorite(k))
                        .toList();

                    if (favorites.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 56,
                                color: AppColors.textSecondary
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada kost di wishlist',
                                style: Get.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap ikon hati pada kost di halaman utama untuk menambahkannya ke wishlist.',
                                style: Get.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final kost = favorites[index];
                        return KostCard(
                          kost: kost,
                          isFavorite: controller.isFavorite(kost),
                          onToggleFavorite: () =>
                              controller.toggleFavorite(kost),
                          onTap: () => Get.toNamed(
                            '/detail',
                            arguments: kost,
                          ),
                        );
                      },
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
}
