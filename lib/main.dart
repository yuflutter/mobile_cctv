import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/log.dart';
import '/core/layouts.dart';
import '/core/local_storage.dart';
import '/core/states.dart';
import '/home_screen.dart';

void main() {
  ErrorWidget.builder = (e) => Screen(withoutBackButton: true, body: ErrorView(Log.error(e.exception, e.stack)));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

Future<void> _initApp() async {
  await Log.init();
  await LocalStorage.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  build(context) {
    return MaterialApp(
      title: 'Mobile CCTV',
      theme: themeData,
      home: const HomeScreen(initApp: _initApp),
    );
  }
}
