import 'package:flutter/material.dart';

class SectionHeaderBox extends StatelessWidget {
  final String title;
  final Widget child; // chips

  const SectionHeaderBox({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.bodyMedium,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
