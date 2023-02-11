import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';

class ImageDto {
  final Uint8List dto; // Транспортные данные (черно-белые данные LUMA + 4 байта ширина/высота)
  final int width;
  final int height;
  ui.Image? _uiImage; // Кэширование при выводе на экран

  ImageDto._(this.dto, this.width, this.height);

  factory ImageDto.blank() {
    return ImageDto._(Uint8List(0), 0, 0);
  }

  factory ImageDto.fromCameraImage(CameraImage img) {
    if (img.format.group == ImageFormatGroup.yuv420) {
      final dto = Uint8List(img.width * img.height + 4);
      final bw = img.planes[0].bytes;
      // Log.info('${img.width} * ${img.height} = ${img.width * img.height} (${bw.length})');

      for (int i = 0; i < bw.length; i++) {
        dto[i] = bw[i];
      }

      final sizeBuf = dto.buffer.asByteData(dto.length - 4);
      sizeBuf.setInt16(0, img.width);
      sizeBuf.setInt16(2, img.height);

      return ImageDto._(dto, img.width, img.height);
    } else if (img.format.group == ImageFormatGroup.bgra8888) {
      // доделать для IOS
      return ImageDto.blank();
    } else {
      return ImageDto.blank();
    }
  }

  factory ImageDto.fromDto(Uint8List dto) {
    if (dto.length > 4) {
      final sizeBuf = dto.buffer.asByteData(dto.length - 4);
      return (ImageDto._(dto, sizeBuf.getInt16(0), sizeBuf.getInt16(2)));
    } else {
      return ImageDto.blank();
    }
  }

  Uint8List _toBgra() {
    final bgra = Uint8List(width * height * 4);
    for (int y = 0; y < height * width; y += width) {
      for (int x = 0; x < width; x++) {
        final luma = dto[y + x];
        final xy = (y + x) * 4;
        bgra
          ..[xy] = luma
          ..[xy + 1] = luma
          ..[xy + 2] = luma
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
