import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';

import '/settings.dart';
import '/core/log.dart';
import '/core/abstract_model.dart';
import '/data/image_dto.dart';
import '/model/abstract_image_stream_source.dart';

class CameraModel extends AbstractModel implements AbstractImageStreamSource {
  bool _withoutPreview = false;
  //
  CameraController? cameraController;
  final _imageStreamController = StreamController<ImageDto>.broadcast();
  final _frameDurationMs = (1000 / frameFrequency).round();
  var _lastFrameTime = DateTime.now();

  @override
  Stream<ImageDto> get imageStream => _imageStreamController.stream;

  bool get withoutPreview => _withoutPreview;
  set withoutPreview(bool v) {
    _withoutPreview = v;
    notifyListeners();
  }

  void init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final cams = await availableCameras();
      cameraController = CameraController(
        cams[0],
        ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.yuv420, // В андроиде это родной формат, не уверен сработает в IOS
      );
      await cameraController!.initialize();
      cameraController!.startImageStream(
        (camImg) {
          try {
            final now = DateTime.now();
            if (now.difference(_lastFrameTime) > Duration(milliseconds: _frameDurationMs)) {
              _lastFrameTime = now;
              final dto = ImageDto.fromCameraImage(camImg);
              _imageStreamController.sink.add(dto);
            }
          } catch (e, s) {
            _imageStreamController.sink.addError(Log.error(e, s));
          }
        },
      );
      setDone();
    } catch (e, s) {
      setError(e, s);
    }
  }

  @override
  void dispose() async {
    await cameraController?.stopImageStream();
    await cameraController?.dispose();
    await _imageStreamController.close();
    super.dispose();
  }
}
