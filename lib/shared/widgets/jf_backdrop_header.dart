import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Full-bleed backdrop image with a vertical gradient overlay so child
/// content (title, metadata, actions) reads cleanly on top.
class JfBackdropHeader extends StatelessWidget {
  const JfBackdropHeader({
    required this.imageUrl,
    required this.child,
    this.height = 360,
    super.key,
  });

  final String? imageUrl;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: AppColors.surface),
              errorWidget: (_, __, ___) => Container(color: AppColors.surface),
            )
          else
            Container(color: AppColors.surface),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0xCC07060C),
                  Color(0xFF07060C),
                ],
                stops: [0.0, 0.4, 0.85, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }
}
