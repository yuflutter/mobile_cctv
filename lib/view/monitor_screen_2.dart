import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/layouts.dart';
import '/core/states.dart';
import '/model/network_server_model.dart';
import '/view/image_stream_view.dart';

class MonitorScreen2 extends StatelessWidget {
  const MonitorScreen2({super.key});

  @override
  build(context) {
    final networkModel = context.watch<NetworkServerModel>();
    return Screen(
      withoutBackButton: networkModel.forLocalTest,
      withoutPadding: networkModel.forLocalTest,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ImageStreamView(imageStream: networkModel.imageStream),
              ),
            ),
            Space1(),
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
