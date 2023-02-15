import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';

import '/settings.dart' as settings;
import '/core/log.dart';
import '/core/abstract_model.dart';
import '/data/image_dto.dart';
import '/model/abstract_image_stream_source.dart';

class CameraModel extends AbstractModel implements AbstractImageStreamSource {
  bool _withoutPreview = false;
  //
  CameraController? cameraController;
  final _frameDurationMs = (1000 / settings.frameFrequency).round();
  DateTime? _lastFrameTime;
  //
  final _imageStreamController = StreamController<ImageDto>.broadcast();

  bool get withoutPreview => _withoutPreview;
  set withoutPreview(bool v) {
    _withoutPreview = v;
    notifyListeners();
  }

  @override
  Stream<ImageDto> get imageStream => _imageStreamController.stream;

  void init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final cams = await availableCameras();
      cameraController = CameraController(
        cams[0],
        settings.cameraResolution,
        imageFormatGroup: ImageFormatGroup.yuv420, // В андроиде это родной формат, не уверен что сработает в IOS
        enableAudio: false,
      );
      await cameraController!.initialize();
      cameraController!.startImageStream(
        (camImg) {
          try {
            final now = DateTime.now();
            if (_lastFrameTime == null || now.difference(_lastFrameTime!) > Duration(milliseconds: _frameDurationMs)) {
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
