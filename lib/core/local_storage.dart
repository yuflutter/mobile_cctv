import 'package:shared_preferences/shared_preferences.dart';

import '/settings.dart' as settings;

class LocalStorage {
  static SharedPreferences? _storage;

  static Future<void> init() async {
    _storage = await SharedPreferences.getInstance();
  }

  static String get host => _storage?.getString('host') ?? settings.defaultHost;
  static int get port => _storage?.getInt('port') ?? settings.defaultPort;

  static Future<void> saveConnectionInfo({String? host, required int port}) {
    return Future.wait([
      ...(host != null) ? [_storage!.setString('host', host)] : [],
      _storage!.setInt('port', port),
    ]);
  }
}
