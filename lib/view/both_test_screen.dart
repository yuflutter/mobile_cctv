import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/layouts.dart';
import '/core/injections.dart';
import '/model/camera_model.dart';
import '/model/network_client_model.dart';
import '/model/network_server_model.dart';
import '/view/camera_screen_2.dart';
import '/view/monitor_screen_2.dart';

class BothTestScreen extends StatelessWidget {
  const BothTestScreen({super.key});

  @override
  build(context) {
    return ProviderInjector(
        providers: [
          ChangeNotifierProvider(create: (context) => NetworkServerModel(bothTest: true)..init()),
          ChangeNotifierProvider(create: (context) => NetworkClientModel(bothTest: true)..init()),
          ChangeNotifierProvider(create: (context) => CameraModel(context)..init()),
        ],
        builder: (context) {
          return Screen(
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: CameraScreen2(bothTest: true)),
                  Container(height: 2, color: Colors.white),
                  Expanded(child: MonitorScreen2(bothTest: true)),
                ],
              ),
            ),
          );
        });
  }
}
