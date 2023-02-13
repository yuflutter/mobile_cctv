import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import '/core/layouts.dart';
import '/core/states.dart';
import '/model/camera_model.dart';
import '/model/network_client_model.dart';
import '/view/image_stream_view.dart';

class CameraScreen2 extends StatelessWidget {
  const CameraScreen2({super.key});

  @override
  build(context) {
    final cameraModel = context.watch<CameraModel>();
    final networkModel = context.watch<NetworkClientModel>();
    return Screen(
      withoutBackButton: networkModel.forLocalTest,
      withoutPadding: networkModel.forLocalTest,
      body: Center(
        child: Column(
          children: [
            ...(!cameraModel.withoutPreview)
                ? [
                    Expanded(
                      child: ModelViewer<CameraModel>(
                        builder: (_, __) => CameraPreview(cameraModel.cameraController!),
                      ),
                    ),
                    ...(!networkModel.forLocalTest)
                        ? [
                            Space1(),
                            Expanded(
                              child: ImageStreamView(imageStream: cameraModel.imageStream),
                            ),
                          ]
                        : [],
                    Space1(),
                  ]
                : [
                    SizedBox(height: mediaSize(context).height / 2.1),
                  ],
            (networkModel.error != null)
                ? ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: mediaSize(context).height / 5),
                    child: ErrorView(networkModel.error!),
                  )
                : Text(networkModel.statusText, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
