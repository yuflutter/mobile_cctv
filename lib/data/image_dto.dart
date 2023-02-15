import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';

class ImageDto {
  // Транспортный пакет: длина пакета(4) + ширина картинки(2) + высота картинки(2) + черно-белые пиксели
  final Uint8List bytes;
  final int width;
  final int height;
  ui.Image? _uiImage; // Кэширование при выводе на экран

  ImageDto._(this.bytes, this.width, this.height);

  factory ImageDto.blank() {
    return ImageDto._(Uint8List(0), 0, 0);
  }

  factory ImageDto.fromCameraImage(CameraImage camImg) {
    if (camImg.format.group == ImageFormatGroup.yuv420) {
      final bytes = Uint8List(8 + camImg.width * camImg.height);

      final headBuf = bytes.buffer.asByteData(0, 8);
      headBuf.setUint32(0, bytes.length);
      headBuf.setUint16(4, camImg.width);
      headBuf.setUint16(6, camImg.height);

      final pixels = camImg.planes[0].bytes;
      for (int i = 0; i < pixels.length; i++) {
        bytes[8 + i] = pixels[i];
      }

      return ImageDto._(bytes, camImg.width, camImg.height);
    } else if (camImg.format.group == ImageFormatGroup.bgra8888) {
      // доделать для IOS
      return ImageDto.blank();
    } else {
      return ImageDto.blank();
    }
  }

  factory ImageDto.fromBytes(Uint8List bytes) {
    if (bytes.length > 8) {
      final headBuf = bytes.buffer.asByteData(0, 8);
      return (ImageDto._(bytes, headBuf.getUint16(4), headBuf.getUint16(6)));
    } else {
      return ImageDto.blank();
    }
  }

  Uint8List _toBgra() {
    final bgra = Uint8List(width * height * 4);
    for (int y = 0; y < height * width; y += width) {
      for (int x = 0; x < width; x++) {
        final pixel = bytes[6 + y + x];
        final xy = (y + x) * 4;
        bgra
          ..[xy] = pixel
          ..[xy + 1] = pixel
          ..[xy + 2] = pixel
          ..[xy + 3] = 0xFF;
      }
    }
    return bgra;
  }

  Future<ui.Image> toUiImage({double? targetWidth, double? targetHeight}) async {
    if (_uiImage == null) {
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        _toBgra(),
        width,
        height,
        ui.PixelFormat.bgra8888,
        (img) => completer.complete(img),
        targetWidth: targetWidth?.round(),
        targetHeight: targetHeight?.round(),
      );
      return completer.future;
    } else {
      return _uiImage!;
    }
  }
}
