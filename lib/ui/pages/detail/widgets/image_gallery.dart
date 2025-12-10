import 'package:flutter/material.dart';

class ImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? kostType;

  const ImageGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.kostType,
  });

  /// Versi khusus untuk header hero (full width, aspect ratio tetap, anti-overflow)
  factory ImageGallery.headerHero({
    required List<String> images,
    String? kostType,
  }) {
    return ImageGallery(
      images: images,
      initialIndex: 0,
      kostType: kostType,
      key: const Key('header_hero_gallery'),
    );
  }

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late final PageController _pageCtrl;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pageCtrl = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  String _fallbackAsset() {
    switch (widget.kostType) {
      case 'single_fan':
        return 'assets/images/kamar-single-fan.jpg';
      case 'single_ac':
        return 'assets/images/kamar-ac.jpg';
      case 'deluxe':
        return 'assets/images/kamar-deluxe.jpg';
      default:
        return 'assets/images/kamar-single-fan.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgs =
        (widget.images.isEmpty || widget.images.every((e) => e.isEmpty))
            ? <String>[_fallbackAsset()]
            : widget.images;

    return AspectRatio(
      aspectRatio: 16 / 9, // aman di berbagai device, anti overflow
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: imgs.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final path = imgs[i];
              final isNetwork = path.startsWith('http');
              if (isNetwork) {
                return Image.network(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Image.asset(_fallbackAsset(), fit: BoxFit.cover),
                );
              }
              return Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset(_fallbackAsset(), fit: BoxFit.cover),
              );
            },
          ),

          // dot indicator
          if (imgs.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imgs.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.15),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
