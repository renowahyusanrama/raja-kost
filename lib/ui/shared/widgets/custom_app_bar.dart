import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;

  /// Tinggi header (fixed agar tidak mendorong layout di bawah)
  final double headerHeight;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.leading,
    this.actions,
    this.headerHeight = 88,
  });

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).padding; // ikuti SafeArea untuk notch
    final titleStyle = Get.textTheme.headlineMedium ??
        const TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
    final subStyle = Get.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
    final cardColor = AppColors.cardBackground;
    final shadowColor = (Get.isDarkMode ? Colors.black : AppColors.textPrimary)
        .withValues(alpha: Get.isDarkMode ? 0.25 : 0.08);
    final leadingWidgets = <Widget>[];

    if (leading != null) {
      leadingWidgets.add(leading!);
    }

    if (showBackButton) {
      leadingWidgets.add(
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 40,
            height: 40,
            margin: EdgeInsets.only(left: leadingWidgets.isEmpty ? 0 : 8),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back),
          ),
        ),
      );
    }

    return Padding(
      // tanpa padding kiri/kanan agar back/actions bisa menempel tepi layar (dengan insets)
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: SizedBox(
        height: headerHeight,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ===== TEKS TENGAH (tanpa bubble) =====
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: titleStyle,
                    ),
                    if (title == 'Raja Kost')
                      Positioned(
                        left: -12,
                        top: -17,
                        child: Transform.rotate(
                          angle: -0.30,
                          child: Image.asset(
                            'assets/icon/crown.png',
                            width: 22,
                            height: 30,
                          ),
                        ),
                      ),
                  ],
                ),
                if (subtitle != null)
                  Text(subtitle!, textAlign: TextAlign.center, style: subStyle),
              ],
            ),

            // ===== LEADING / BACK POJOK KIRI =====
            if (leadingWidgets.isNotEmpty)
              Positioned(
                left: insets.left,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: leadingWidgets,
                  ),
                ),
              ),

            // ===== ACTIONS POJOK KANAN =====
            if (actions != null && actions!.isNotEmpty)
              Positioned(
                right: insets.right,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(children: actions!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
