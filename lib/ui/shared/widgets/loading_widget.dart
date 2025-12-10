import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Get.theme.primaryColor)),
          const SizedBox(height: 16),
          Text('Memuat data...', style: Get.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
