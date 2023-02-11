import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '/core/layouts.dart';
import '/core/states.dart';
import '/model/camera_model.dart';
import '/model/network_client_model.dart';
import '/view/image_stream_view.dart';

class CameraScreen2 extends StatelessWidget {
  final bool withImageStreamPreview;
  final bool bothTest;

  const CameraScreen2({super.key, this.withImageStreamPreview = false, this.bothTest = false});

  @override
  build(context) {
    final cameraModel = context.watch<CameraModel>();
    final networkModel = context.watch<NetworkClientModel>();
    return Screen(
      noBackButton: bothTest,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ModelViewer<CameraModel>(
                builder: (_, __) => CameraPreview(cameraModel.cameraController!),
              ),
            ),
            ...(withImageStreamPreview)
                ? [
                    Space1(),
                    Expanded(child: ImageStreamView(imageStream: cameraModel.imageStream)),
                  ]
                : [],
            Space1(),
            (networkModel.error != null)
                ? ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 5),
                    child: ErrorView(networkModel.error!),
                  )
                : Text(networkModel.statusText, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
