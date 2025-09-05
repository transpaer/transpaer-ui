import 'package:flutter/material.dart';

import 'package:web/web.dart' as web;

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
    return SizedBox(
      width: width as double,
      height: height as double,
      child: Center(
        child: HtmlElementView.fromTagName(
          tagName: 'img',
          onElementCreated: (imgElement) {
            imgElement as web.HTMLElement;
            imgElement.setAttribute('src', src);
            imgElement.style.width = "";
            imgElement.style.height = "";
            imgElement.style.maxWidth = "${width.toString()}px";
            imgElement.style.maxHeight = "${height.toString()}px";
          },
        ),
      ),
    );
  }
}
