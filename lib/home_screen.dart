import 'package:flutter/material.dart';

import '/core/log.dart';
import '/core/layouts.dart';
import '/core/states.dart';
import '/view/monitor_screen_1.dart';
import '/view/camera_screen_1.dart';
import '/view/both_test_screen.dart';

class HomeScreen extends StatefulWidget {
  final Future<void> Function() initApp;

  const HomeScreen({super.key, required this.initApp});

  @override
  createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  late Future<void> _initFuture;

  @override
  initState() {
    _initFuture = widget.initApp();
    super.initState();
  }

  @override
  build(context) {
    return Screen(
      withoutBackButton: true,
      body: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorView(Log.error(snapshot.error!, snapshot.stackTrace));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Waiting();
          } else {
            return Center(
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Spacer(flex: 2),
                    Text('Local mobile network CCTV sample', textAlign: TextAlign.center),
                    Spacer(flex: 2),
                    ElevatedButton(
                      onPressed: () => _cli(context),
                      child: Text('Camera (client)'),
                    ),
                    Space3(),
                    ElevatedButton(
                      onPressed: () => _srv(context),
                      child: Text('Monitor (server)'),
                    ),
                    Spacer(flex: 3),
                    ElevatedButton(
                      onPressed: () => _both(context),
                      child: Text('Both (for test)'),
                    ),
                    Space1(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _cli(context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CameraScreen1()));
  }

  void _srv(context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MonitorScreen1()));
  }

  void _both(context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => BothTestScreen()));
  }
}
