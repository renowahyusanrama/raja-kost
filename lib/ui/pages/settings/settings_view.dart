import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/settings_controller.dart';
import '../../shared/widgets/app_overflow_menu.dart';
import '../../shared/widgets/custom_app_bar.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(
              title: 'Pengaturan',
              showBackButton: true,
              leading: AppOverflowMenu(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const _SectionHeader(title: 'Akun'),
                  Obx(
                    () => _SettingTile(
                      title: 'Email',
                      subtitle: auth.user?.email ?? 'Belum login',
                      leading: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final loggedIn = auth.isLoggedIn;
                    return _SettingTile(
                      title: loggedIn ? 'Logout' : 'Login',
                      subtitle: loggedIn
                          ? 'Keluar dari Raja Kost'
                          : 'Masuk untuk simpan transaksi',
                      leading: Icon(loggedIn ? Icons.logout : Icons.login),
                      trailing: controller.isLoggingOut.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: () => loggedIn
                          ? controller.logout()
                          : Get.toNamed('/login'),
                    );
                  }),
                  const SizedBox(height: 8),
                  Obx(
                    () => _SettingTile(
                      title: 'Hapus Akun',
                      subtitle:
                          'Hapus data transaksi lalu akhiri sesi akun ini.',
                      leading: const Icon(Icons.delete_forever,
                          color: AppColors.error),
                      titleColor: AppColors.error,
                      trailing: controller.isDeletingAccount.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(Icons.chevron_right,
                              color: AppColors.error),
                      onTap: () => _confirmDeleteAccount(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SectionHeader(title: 'Lainnya'),
                  _SettingTile(
                    title: 'Eksperimen Lokasi',
                    subtitle: 'Bandingkan GPS vs Network, log data real-time',
                    leading: const Icon(Icons.my_location_outlined),
                    onTap: () => Get.toNamed('/location-lab'),
                  ),
                  const SizedBox(height: 8),
                  _SettingTile(
                    title: 'Bantuan & Tentang',
                    subtitle: 'FAQ, kontak admin, versi aplikasi',
                    leading: const Icon(Icons.help_outline),
                    onTap: () => Get.toNamed('/help'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    Get.defaultDialog(
      title: 'Hapus akun?',
      titlePadding: const EdgeInsets.only(top: 16),
      middleText:
          'Semua transaksi di Supabase akan dihapus lalu Anda keluar dari aplikasi.',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.error,
      onConfirm: () {
        Get.back();
        controller.deleteAccount();
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        title,
        style: Get.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Get.theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: leading,
        title: Text(
          title,
          style: Get.textTheme.titleMedium?.copyWith(
            color: titleColor ?? Get.theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Get.textTheme.bodyMedium?.copyWith(
                  color: Get.theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }
}
