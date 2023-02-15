import 'dart:io';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/settings.dart' as settings;
import '/core/abstract_model.dart';
import '/core/local_storage.dart';
import '/core/log.dart';
import '/data/image_dto.dart';
import '/model/abstract_image_stream_source.dart';

enum _Status { connecting, connected }

class NetworkClientModel extends AbstractModel {
  late final Stream<ImageDto> _imageStream;
  final bool forLocalTest;
  //
  late String host;
  late int port;
  //
  var _status = _Status.connecting;
  Socket? _socket;
  Future? _nextAttemptConnect;
  StreamSubscription? _socketSubscription;

  NetworkClientModel(BuildContext context, {this.forLocalTest = false}) {
    _imageStream = context.read<AbstractImageStreamSource>().imageStream;
    if (!forLocalTest) {
      host = LocalStorage.host;
      port = LocalStorage.port;
    } else {
      host = settings.defaultHost;
      port = settings.defaultPort;
    }
  }

  String get statusText => '${_status.name} to $host:$port';

  void init() async {
    try {
      if (!forLocalTest) {
        LocalStorage.saveConnectionInfo(host: host, port: port);
      }
      _connect();
      Timer.periodic(Duration(seconds: 3), (_) => notifyListeners());
    } catch (e, s) {
      setError(e, s);
    }
  }

  void _connect() async {
    try {
      _socket = await Socket.connect(host, port);
      _socketSubscription = _imageStream.listen(_send);
      _status = _Status.connected;
      setDone();
    } catch (e, s) {
      Log.error(e, s);
      if (_nextAttemptConnect == null) {
        _nextAttemptConnect = Future.delayed(
          Duration(seconds: 10),
          () {
            clearError();
            _connect();
          },
        );
      } else {
        setError(e, s);
      }
    }
  }

  void _disconnect() async {
    await _socketSubscription?.cancel();
    await _socket?.close();
  }

  void _send(ImageDto img) {
    try {
      // Log.info('SENT ${img.bytes.length}');
      _socket?.add(img.bytes);
    } catch (e, s) {
      setError(e, s);
    }
  }

  @override
  setError(Object e, [StackTrace? s]) {
    _disconnect();
    super.setError(e, s);
  }

  @override
  void dispose() async {
    _disconnect();
    super.dispose();
  }
}
