import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart'; // <- path dibetulkan

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.onChanged,
    this.hintText = 'Cari kost...',
  });

  final ValueChanged<String>? onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface, // tetap putih (atau atur di AppColors)
      elevation: 4,
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.surface, // paksa fill putih
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

