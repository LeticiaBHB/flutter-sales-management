import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ImageDisplayWidget extends StatelessWidget {
  final String imagePath;

  const ImageDisplayWidget({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {

    /// WEB
    if (kIsWeb) {
      return Image.network(
        imagePath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 40),
      );
    }
    /// MOBILE / DESKTOP
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 40),
        );
      }
    } catch (_) {}
    
    /// URL (caso venha API)
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 40),
      );
    }

    return const Icon(Icons.image_not_supported);
  }
}