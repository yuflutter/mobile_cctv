import 'dart:io';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/settings.dart';
import '/core/abstract_model.dart';
import '/core/local_storage.dart';
import '/data/image_dto.dart';
import '/model/abstract_image_stream_source.dart';

enum _Status { connecting, connected }

class NetworkClientModel extends AbstractModel {
  final bool forLocalTest;
  //
  late String host;
  late int port;
  late final StreamSubscription<ImageDto> _imageStreamSubscription;
  //
  var _status = _Status.connecting;
  WebSocket? _socket;
  Future? _secondInitAttempt;

  NetworkClientModel(BuildContext context, {this.forLocalTest = false}) {
    if (!forLocalTest) {
      host = LocalStorage.host;
      port = LocalStorage.port;
    } else {
      host = defaultHost;
      port = defaultPort;
    }
    _imageStreamSubscription = context.read<AbstractImageStreamSource>().imageStream.listen(_send);
  }

  String get url => 'ws://$host:$port';
  String get statusText => (_status == _Status.connecting) ? 'Connecting to $url ...' : 'Connected to $host';

  void init() async {
    try {
      if (!forLocalTest) {
        LocalStorage.saveConnectionInfo(host: host, port: port);
      }
      _socket = await WebSocket.connect(url);
      _status = _Status.connected;
      setDone();
    } catch (e, s) {
      if (_secondInitAttempt == null) {
        _secondInitAttempt = Future.delayed(
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

  void _send(ImageDto img) {
    try {
      _socket?.add(img.dto);
    } catch (e, s) {
      setError(e, s);
    }
  }

  @override
  void dispose() {
    _imageStreamSubscription.cancel();
    _socket?.close();
    super.dispose();
  }
}
