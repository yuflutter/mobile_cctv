import 'dart:io';
import 'dart:async';

import '/settings.dart';
import '/core/log.dart';
import '/core/abstract_model.dart';
import '/core/local_storage.dart';
import '/data/image_dto.dart';

enum _Status { listening, connected }

class NetworkServerModel extends AbstractModel {
  final bool forLocalTest;
  //
  int port;
  //
  HttpServer? _httpServer;
  HttpRequest? _request;
  WebSocket? _socket;
  var _status = _Status.listening;
  final _imageStreamController = StreamController<ImageDto>.broadcast();

  NetworkServerModel({this.forLocalTest = false}) : port = (!forLocalTest) ? LocalStorage.port : defaultPort;

  String get statusText => (_status == _Status.listening)
      ? 'Listening $port ...'
      : 'Connected from ${_request!.connectionInfo!.remoteAddress.host}';

  Stream<ImageDto> get imageStream => _imageStreamController.stream;

  void init() async {
    try {
      if (!forLocalTest) {
        LocalStorage.saveConnectionInfo(port: port);
      }
      _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, port);
      _httpServer!.listen(
        (req) async {
          try {
            _request = req;
            _socket = await WebSocketTransformer.upgrade(req);
            _status = _Status.connected;
            notifyListeners();
            _socket!.listen(
              (bytes) {
                try {
                  try {
                    _imageStreamController.sink.add(ImageDto.fromDto(bytes));
                  } catch (e, s) {
                    _imageStreamController.sink.addError(Log.error(e, s));
                  }
                } catch (e, s) {
                  setError(e, s);
                }
              },
              onError: (e, s) => setError(e, s),
              onDone: () => _disconnect,
            );
          } catch (e, s) {
            setError(e, s);
          }
        },
        onError: (e, s) => setError(e, s),
      );
    } catch (e, s) {
      setError(e, s);
    }
    setDone();
  }

  void _disconnect() async {
    await _socket?.close();
    _socket = null;
    _status = _Status.listening;
    notifyListeners();
  }

  @override
  void dispose() async {
    await _socket?.close();
    await _httpServer?.close();
    super.dispose();
  }
}
