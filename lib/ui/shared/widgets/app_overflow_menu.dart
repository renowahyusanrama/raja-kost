import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../app/theme/app_colors.dart';

enum _MenuAction {
  wishlist,
  history,
  settings,
  help,
  admin,
  report,
  adminReports,
  auth,
}

class AppOverflowMenu extends StatelessWidget {
  const AppOverflowMenu({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    final baseIconColor =
        iconColor ?? Get.theme.iconTheme.color ?? Get.theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: () => _openMenu(context, auth),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Get.isDarkMode ? 0.18 : 0.07,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(Icons.menu, color: baseIconColor),
      ),
    );
  }

  void _openMenu(BuildContext context, AuthController auth) {
    final media = MediaQuery.of(context);
    final panelWidth = media.size.width * 0.55;

    showGeneralDialog(
      context: context,
      barrierLabel: 'Menu',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      pageBuilder: (dialogContext, _, __) {
        return SafeArea(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _MenuSidePanel(
              width: panelWidth,
              height: media.size.height,
              auth: auth,
              onSelected: (action) {
                Navigator.of(dialogContext).pop();
                _handleAction(action, auth);
              },
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
    );
  }

  Future<void> _handleAction(_MenuAction action, AuthController auth) async {
    switch (action) {
      case _MenuAction.wishlist:
        Get.toNamed('/wishlist');
        break;
      case _MenuAction.history:
        if (!auth.isLoggedIn) {
          Get.snackbar(
            'Butuh login',
            'Silakan login untuk melihat riwayat.',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.toNamed('/login');
          return;
        }
        Get.toNamed('/history');
        break;
      case _MenuAction.settings:
        Get.toNamed('/settings');
        break;
      case _MenuAction.help:
        Get.toNamed('/help');
        break;
      case _MenuAction.admin:
        if (auth.isAdmin) {
          Get.toNamed('/admin');
        } else {
          Get.snackbar(
            'Akses ditolak',
            'Hanya admin yang dapat membuka menu ini.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        break;
      case _MenuAction.report:
        if (!auth.isLoggedIn) {
          Get.snackbar(
            'Butuh login',
            'Silakan login dulu untuk mengirim laporan.',
            snackPosition: SnackPosition.BOTTOM,
          );
          Get.toNamed('/login');
          return;
        }
        Get.toNamed('/report');
        break;
      case _MenuAction.adminReports:
        if (auth.isAdmin) {
          Get.toNamed('/admin/reports');
        } else {
          Get.snackbar(
            'Akses ditolak',
            'Hanya admin yang dapat membuka laporan admin.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        break;
      case _MenuAction.auth:
        if (auth.isLoggedIn) {
          Get.defaultDialog(
            title: 'Logout?',
            middleText: 'Sesi Supabase akan diakhiri.',
            textConfirm: 'Logout',
            textCancel: 'Batal',
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back();
              auth.logout();
            },
          );
        } else {
          Get.toNamed('/login');
        }
        break;
    }
  }
}

class _MenuSidePanel extends StatelessWidget {
  const _MenuSidePanel({
    required this.width,
    required this.height,
    required this.auth,
    required this.onSelected,
  });

  final double width;
  final double height;
  final AuthController auth;
  final ValueChanged<_MenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final email = auth.user?.email ?? 'Belum login';
    final loggedIn = auth.isLoggedIn;
    final textTheme = Get.textTheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(26),
            bottomRight: Radius.circular(26),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(6, 0),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Akun',
                style: textTheme.labelMedium?.copyWith(
                  letterSpacing: 0.4,
                  color: Get.theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (!loggedIn)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Login untuk menyimpan transaksi.',
                    style: textTheme.bodySmall?.copyWith(
                      color: Get.theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      if (auth.isAdmin)
                        _MenuItem(
                          icon: Icons.admin_panel_settings_outlined,
                          title: 'Admin',
                          subtitle: 'Kelola kamar & penugasan',
                          onTap: () => onSelected(_MenuAction.admin),
                        ),
                      _MenuItem(
                        icon: Icons.feedback_outlined,
                        title: 'Laporan',
                        subtitle: 'Kirim laporan & keluhan',
                        onTap: () => onSelected(_MenuAction.report),
                      ),
                      if (auth.isAdmin)
                        _MenuItem(
                          icon: Icons.mark_chat_read_outlined,
                          title: 'Laporan Admin',
                          subtitle: 'Lihat semua laporan user',
                          onTap: () => onSelected(_MenuAction.adminReports),
                        ),
                      _MenuItem(
                        icon: Icons.favorite_border,
                        title: 'Wishlist',
                        subtitle: 'Kost favoritmu',
                        onTap: () => onSelected(_MenuAction.wishlist),
                      ),
                      _MenuItem(
                        icon: Icons.history,
                        title: 'Riwayat Booking',
                        subtitle: 'Lihat transaksi tersimpan',
                        onTap: () => onSelected(_MenuAction.history),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Pengaturan',
                        onTap: () => onSelected(_MenuAction.settings),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline,
                        title: 'Bantuan & Tentang',
                        onTap: () => onSelected(_MenuAction.help),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                minimum: const EdgeInsets.only(top: 8),
                child: _MenuItem(
                  icon: loggedIn ? Icons.logout : Icons.login,
                  title: loggedIn ? 'Logout' : 'Login',
                  subtitle:
                      loggedIn ? 'Akhiri sesi Supabase' : 'Masuk untuk lanjut',
                  highlight: loggedIn,
                  onTap: () => onSelected(_MenuAction.auth),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Get.textTheme;
    final onSurface = Get.theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: highlight
                ? AppColors.error.withValues(alpha: 0.08)
                : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: highlight ? AppColors.error : onSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: highlight ? AppColors.error : onSurface,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: Get.theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
