import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/layouts.dart';
import '/core/states.dart';
import '/model/network_server_model.dart';
import '/view/image_stream_view.dart';

class MonitorScreen2 extends StatelessWidget {
  final bool bothTest;

  const MonitorScreen2({super.key, this.bothTest = false});

  @override
  build(context) {
    final network = context.watch<NetworkServerModel>();
    return Screen(
      noBackButton: bothTest,
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ImageStreamView(imageStream: network.imageStream),
            ),
            Space1(),
            (network.error != null)
                ? ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 5),
                    child: ErrorView(network.error!),
                  )
                : Text(network.statusText, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
