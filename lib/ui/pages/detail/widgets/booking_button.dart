import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/kost_model.dart';
import '../../../../app/theme/app_colors.dart';

class BookingButton extends StatelessWidget {
  final KostModel kost;
  final VoidCallback onTap;

  const BookingButton({super.key, required this.kost, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: kost.available ? AppColors.primary : Colors.grey),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: kost.available ? onTap : null,
          child: Center(
            child: Text(kost.available ? 'Pesan Sekarang' : 'Tidak Tersedia',
                style:
                    Get.textTheme.titleMedium?.copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }
}
