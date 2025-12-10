import 'package:flutter/material.dart';

class BackgroundBubbles extends StatelessWidget {
  const BackgroundBubbles({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna bubble seperti mockup - lebih subtle
    const base = Color(0xFF8D6262);

    return IgnorePointer(
      child: Stack(
        children: [
          // TOP-LEFT semi circle di balik "Tipe Kamar" - lebih kecil dan subtle
          Positioned(
            top: 150,
            left: -10,
            child: _bubble(120, 120, base.withValues(alpha: .15)),
          ),
          // Soft circle behind header
          Positioned(
            top: -40,
            left: -60,
            child: _bubble(140, 140, base.withValues(alpha: .12)),
          ),
          Positioned(
            top: 180,
            right: -20,
            child: _bubble(
                100, 100, const Color(0xFF8D6262).withValues(alpha: .12)),
          ),
          // MID band (bar panjang di tengah) - lebih tipis dan subtle
          Positioned(
            top: 480,
            left: 320,
            right: 32,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: base.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          // RIGHT middle small circle - lebih kecil
          Positioned(
            top: 50,
            right: -15,
            child: _bubble(80, 80, base.withValues(alpha: .14)),
          ),
          Positioned(
            bottom: 200,
            left: -25,
            child: _bubble(90, 90, base.withValues(alpha: .13)),
          ),
          // FOOTER block - lebih kecil dan subtle
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: base.withValues(alpha: .20),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(double w, double h, Color c) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(999),
        ),
      );
}
