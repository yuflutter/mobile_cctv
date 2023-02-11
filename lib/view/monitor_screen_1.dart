import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/layouts.dart';
import '/core/injections.dart';
import '/model/network_server_model.dart';
import '/view/monitor_screen_2.dart';

class MonitorScreen1 extends StatelessWidget {
  const MonitorScreen1({super.key});

  @override
  build(context) {
    return ProviderInjector(
      providers: [
        ChangeNotifierProvider(create: (context) => NetworkServerModel()),
      ],
      builder: (context) {
        final networkModel = context.watch<NetworkServerModel>();
        return Screen(
          body: Center(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: TextEditingController(text: networkModel.port.toString()),
                    onChanged: (v) => networkModel.port = int.parse(v),
                    decoration: InputDecoration(
                      label: Text('Port to listen'),
                    ),
                    keyboardType: TextInputType.number,
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
    context.read<NetworkServerModel>().init();
    Navigator.push(context, MaterialPageRoute(builder: (_) => MonitorScreen2()));
  }
}
