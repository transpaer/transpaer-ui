import 'package:flutter/material.dart';

class CorsImage extends StatelessWidget {
  final String src;
  final int width;
  final int height;

  const CorsImage({
    required this.src,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      src,
      width: height.toDouble(),
      height: height.toDouble(),
    );
  }
}
