import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/injections.dart';
import '/core/layouts.dart';
import '/model/camera_model.dart';
import '/model/abstract_image_stream_source.dart';
import '/model/network_client_model.dart';
import '/view/camera_screen_2.dart';

class CameraScreen1 extends StatelessWidget {
  const CameraScreen1({super.key});

  @override
  build(context) {
    return ProviderInjector(
      providers: [
        ChangeNotifierProvider(create: (context) => CameraModel()),
        ChangeNotifierProvider<AbstractImageStreamSource>(create: (context) => context.read<CameraModel>()),
        ChangeNotifierProvider(create: (context) => NetworkClientModel(context)),
      ],
      builder: (context) {
        final networkModel = context.watch<NetworkClientModel>();
        final cameraModel = context.watch<CameraModel>();
        return Screen(
          body: Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: TextEditingController(text: networkModel.host),
                    onChanged: (v) => networkModel.host = v,
                    decoration: InputDecoration(label: Text('Server IP')),
                    keyboardType: TextInputType.number,
                  ),
                  Space3(),
                  TextField(
                    controller: TextEditingController(text: networkModel.port.toString()),
                    onChanged: (v) => networkModel.port = int.parse(v),
                    decoration: InputDecoration(label: Text('Server port')),
                    keyboardType: TextInputType.number,
                  ),
                  Space3(),
                  CheckboxListTile(
                    value: cameraModel.withoutPreview,
                    onChanged: (v) => cameraModel.withoutPreview = v!,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Without preview'),
                  ),
                  Space3(),
                  ElevatedButton(
                    onPressed: () => _start(context),
                    child: Text('Start'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _start(BuildContext context) {
    context.read<CameraModel>().init();
    context.read<NetworkClientModel>().init();
    Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScreen2()));
  }
}
