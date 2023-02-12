import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';

import '/settings.dart';
import '/core/log.dart';
import '/core/abstract_model.dart';
import '/data/image_dto.dart';
import '/model/network_client_model.dart';

class CameraModel extends AbstractModel {
  final NetworkClientModel? _networkModel;
  //
  CameraController? cameraController;
  final _imageStreamController = StreamController<ImageDto>.broadcast();
  final _frameDurationMs = (1000 / frameFrequency).round();
  var _lastFrameTime = DateTime.now();

  CameraModel(BuildContext context) : _networkModel = context.read<NetworkClientModel>();

  Stream<ImageDto> get imageStream => _imageStreamController.stream;

  void init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final cams = await availableCameras();
      cameraController = CameraController(
        cams[0],
        ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.yuv420, // Для андроида, не уверен что сработает в IOS
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
              _networkModel?.send(dto);
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
  void dispose() {
    cameraController?.stopImageStream();
    cameraController?.dispose();
    _imageStreamController.close();
    super.dispose();
  }
}
