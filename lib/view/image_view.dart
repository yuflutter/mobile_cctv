import 'dart:io';
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
    final sourceRatio = imageDto.width / imageDto.height;
    return RotatedBox(
      quarterTurns:
          (!Platform.isAndroid && !Platform.isIOS || MediaQuery.of(context).orientation == Orientation.portrait)
              ? 1
              : 0,
      child: AspectRatio(
        aspectRatio: sourceRatio,
        child: LayoutBuilder(
          builder: (context, box) {
            double targetWidth;
            double targetHeight;
            final boxRatio = box.maxWidth / box.maxHeight;
            if (boxRatio <= sourceRatio) {
              targetWidth = box.maxWidth;
              targetHeight = targetWidth / sourceRatio;
            } else {
              targetHeight = box.maxHeight;
              targetWidth = targetHeight * sourceRatio;
            }
            return FutureBuilder<ui.Image>(
              future: imageDto.toUiImage(targetWidth: targetWidth, targetHeight: targetHeight),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorView(Log.error(snapshot.error!, snapshot.stackTrace));
                } else if (!snapshot.hasData) {
                  return Void();
                } else {
                  return CustomPaint(painter: _ImagePainter(snapshot.data!));
                }
              },
            );
          },
        ),
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
