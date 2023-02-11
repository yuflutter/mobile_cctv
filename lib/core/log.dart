import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class Log {
  static Future<void> init() async {}

  static void info(dynamic info) {
    if (kDebugMode) {
      dev.log('$info');
    } else {
      print('$info');
    }
  }

  static String error(Object error, [StackTrace? stack]) {
    final msg = '===== ERROR =====\n$error\n$stack===== / =====';
    if (kDebugMode) {
      dev.log('===== ERROR =====', error: error, stackTrace: stack);
    } else {
      print(msg);
    }
    return msg;
  }
}
