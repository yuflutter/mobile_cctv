import 'dart:io';

import '/settings.dart';
import '/core/abstract_model.dart';
import '/core/local_storage.dart';
import '/data/image_dto.dart';

enum _Status { connecting, connected }

class NetworkClientModel extends AbstractModel {
  final bool bothTest;
  //
  String host;
  int port;
  WebSocket? _socket;
  var _status = _Status.connecting;
  Future? _repeatInit;

  NetworkClientModel({this.bothTest = false})
      : host = (!bothTest) ? LocalStorage.host : defaultHost,
        port = (!bothTest) ? LocalStorage.port : defaultPort;

  String get url => 'ws://$host:$port';
  String get statusText => (_status == _Status.connecting) ? 'Connecting to $url ...' : 'Connected to $host';

  void init() async {
    try {
      if (!bothTest) {
        LocalStorage.saveConnectionInfo(host: host, port: port);
      }
      _socket = await WebSocket.connect(url);
      _status = _Status.connected;
      setDone();
    } catch (e, s) {
      if (_repeatInit == null) {
        _repeatInit = Future.delayed(
          Duration(seconds: 10),
          () {
            clearError();
            init();
          },
        );
      } else {
        setError(e, s);
      }
    }
  }

  void send(ImageDto img) {
    try {
      _socket?.add(img.dto);
    } catch (e, s) {
      setError(e, s);
    }
  }

  @override
  void dispose() async {
    await _socket?.close();
    super.dispose();
  }
}
