import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    // Kunci ke tema terang agar tidak mengikuti sistem, sesuai permintaan.
    themeMode.value = ThemeMode.light;
    Get.changeThemeMode(ThemeMode.light);
  }

  void setThemeMode(ThemeMode mode) {
    // Abaikan input, tetap pakai light.
    themeMode.value = ThemeMode.light;
    Get.changeThemeMode(ThemeMode.light);
  }

  void toggleTheme() {
    setThemeMode(ThemeMode.light);
  }

  bool get isDarkMode => false;
}
