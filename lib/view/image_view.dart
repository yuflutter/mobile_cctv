import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '/core/log.dart';
import '/core/states.dart';
import '/core/layouts.dart';
import '/data/image_dto.dart';

class ImageView extends StatelessWidget {
  final ImageDto imageDto;

  const ImageView({super.key, required this.imageDto});

  @override
  build(context) {
    return AspectRatio(
      aspectRatio: imageDto.height / imageDto.width,
      child: LayoutBuilder(
        builder: (context, box) {
          return FutureBuilder<ui.Image>(
            future: imageDto.toUiImage(targetWidth: box.maxWidth, targetHeight: box.maxHeight),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return ErrorView(Log.error(snapshot.error!, snapshot.stackTrace));
              } else if (!snapshot.hasData) {
                return Void();
              } else {
                final img = snapshot.data!;
                return CustomPaint(
                  painter: _ImagePainter(img),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _ImagePainter extends CustomPainter {
  final ui.Image img;

  const _ImagePainter(this.img);

  @override
  paint(canvas, size) => canvas.drawImage(img, Offset(0, 0), Paint());

  @override
  shouldRepaint(oldDelegate) => true;
}
