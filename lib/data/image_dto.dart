import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';

class ImageDto {
  final Uint8List dto; // Транспортный пакет: заголовок (длина пакета + ширина/высота картинки) + черно-белые пиксели
  final int width;
  final int height;
  ui.Image? _uiImage; // Кэширование при выводе на экран

  ImageDto._(this.dto, this.width, this.height);

  factory ImageDto.blank() {
    return ImageDto._(Uint8List(0), 0, 0);
  }

  factory ImageDto.fromCameraImage(CameraImage camImg) {
    if (camImg.format.group == ImageFormatGroup.yuv420) {
      final dto = Uint8List(6 + camImg.width * camImg.height);

      final headBuf = dto.buffer.asByteData(0, 6);
      headBuf.setInt16(0, dto.length);
      headBuf.setInt16(2, camImg.width);
      headBuf.setInt16(4, camImg.height);

      final pixels = camImg.planes[0].bytes;
      for (int i = 0; i < pixels.length; i++) {
        dto[6 + i] = pixels[i];
      }

      return ImageDto._(dto, camImg.width, camImg.height);
    } else if (camImg.format.group == ImageFormatGroup.bgra8888) {
      // доделать для IOS
      return ImageDto.blank();
    } else {
      return ImageDto.blank();
    }
  }

  factory ImageDto.fromDto(Uint8List dto) {
    if (dto.length > 6) {
      final headBuf = dto.buffer.asByteData(0, 6);
      return (ImageDto._(dto, headBuf.getInt16(2), headBuf.getInt16(4)));
    } else {
      return ImageDto.blank();
    }
  }

  Uint8List _toBgra() {
    final bgra = Uint8List(width * height * 4);
    for (int y = 0; y < height * width; y += width) {
      for (int x = 0; x < width; x++) {
        final pixel = dto[6 + y + x];
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
