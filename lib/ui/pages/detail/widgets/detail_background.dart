import 'package:flutter/material.dart';

class DetailBackground extends StatelessWidget {
  const DetailBackground({super.key});

  @override
  Widget build(BuildContext context) {
    const base = Color(0xFF8D6262);

    return IgnorePointer(
      child: Stack(
        children: [
          // Top decorative circles
          Positioned(
            top: -40,
            right: -60,
            child: _bubble(120, 120, base.withValues(alpha: .08)),
          ),
          Positioned(
            top: 100,
            left: -40,
            child: _bubble(80, 80, base.withValues(alpha: .06)),
          ),

          // Middle decorative elements
          Positioned(
            top: 300,
            right: -30,
            child: _bubble(100, 100, base.withValues(alpha: .07)),
          ),
          Positioned(
            top: 450,
            left: -25,
            child: _bubble(90, 90, base.withValues(alpha: .05)),
          ),

          // Bottom accent
          Positioned(
            bottom: 150,
            right: -35,
            child: _bubble(110, 110, base.withValues(alpha: .06)),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: base.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(30),
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
