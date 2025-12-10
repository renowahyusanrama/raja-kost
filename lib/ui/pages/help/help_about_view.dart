import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../shared/widgets/app_overflow_menu.dart';
import '../../shared/widgets/custom_app_bar.dart';

class HelpAboutView extends StatelessWidget {
  const HelpAboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Bantuan & Tentang',
              showBackButton: true,
              leading: const AppOverflowMenu(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Card(
                    title: 'FAQ Singkat',
                    children: const [
                      _FaqItem(
                        question: 'Bagaimana cara memesan kost?',
                        answer:
                            'Pilih kost atau layanan, tentukan jumlah/durasi, lalu lanjutkan pembayaran. Data tersimpan di Supabase.',
                      ),
                      _FaqItem(
                        question: 'Apakah data saya aman?',
                        answer:
                            'Session dan transaksi disimpan di Supabase. Anda bisa logout atau hapus akun dari menu Pengaturan.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    title: 'Kontak Admin',
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.email_outlined),
                        title: Text(
                          'admin@rajakost.com',
                          style: Get.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Kirimkan kendala atau permintaan fitur.',
                          style: Get.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.chat_bubble_outline),
                        title: Text(
                          'WhatsApp',
                          style: Get.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          '+62 811-456-999',
                          style: Get.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    title: 'Tentang Aplikasi',
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.info_outline),
                        title: Text(
                          'Raja Kost',
                          style: Get.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'Versi 1.0.0 • Dibangun dengan Flutter + Supabase',
                          style: Get.textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      Text(
                        'Aplikasi demo pencarian kost dengan integrasi Supabase untuk autentikasi dan penyimpanan transaksi.',
                        style: Get.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: Get.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
