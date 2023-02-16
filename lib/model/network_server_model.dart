import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import '/settings.dart' as settings;
import '/core/abstract_model.dart';
import '/core/local_storage.dart';
import '/model/abstract_image_stream_source.dart';
import '/data/image_dto.dart';

enum _Status { listening, connected }

class NetworkServerModel extends AbstractModel implements AbstractImageStreamSource {
  late int port;
  final bool forLocalTest;
  //
  ServerSocket? _server;
  Socket? _socket;
  var _currentFrame = ImageDto.blank();
  var _totslBytesReceived = 0;
  var _status = _Status.listening;
  //
  StreamSubscription? _serverSubscription;
  StreamSubscription? _socketSubscription;
  Timer? _screenRefresher;
  //
  final _imageStreamController = StreamController<ImageDto>.broadcast();

  NetworkServerModel({this.forLocalTest = false}) {
    port = (!forLocalTest) ? LocalStorage.port : settings.defaultPort;
  }

  @override
  Stream<ImageDto> get imageStream => _imageStreamController.stream;

  String get statusText => (_status == _Status.listening)
      ? 'listening $port ...'
      : 'connected from ${_socket?.remoteAddress.host}, received ${_totslBytesReceived ~/ 1000000} MB';

  void init() async {
    try {
      if (!forLocalTest) {
        LocalStorage.saveConnectionInfo(port: port);
      }
      _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _serverSubscription = _server!.listen(
        (req) async {
          try {
            _socket = req;
            _status = _Status.connected;
            notifyListeners();
            _socketSubscription = _socket!.listen(
              _processBytes,
              onError: (e) => setError(e),
              onDone: () => _disconnect,
            );
          } catch (e, s) {
            setError(e, s);
          }
        },
        onError: (e) => setError(e),
      );
    } catch (e, s) {
      setError(e, s);
    }
    setDone();
    _screenRefresher = Timer.periodic(Duration(seconds: 3), (_) => notifyListeners());
  }

  void _processBytes(Uint8List part) {
    try {
      // Log.info('RECEIVED ${bytes.length}');
      _currentFrame.appendBytes(
        part,
        (newFrame) {
          try {
            _imageStreamController.sink.add(_currentFrame);
            _totslBytesReceived += _currentFrame.bytes.length;
            _currentFrame = newFrame ?? ImageDto.blank();
          } catch (e, s) {
            setError(e, s);
          }
        },
      );
    } catch (e, s) {
      setError(e, s);
    }
  }

  @override
  setError(Object e, [StackTrace? s]) {
    _disconnect();
    super.setError(e, s);
  }

  Future<void> _disconnect() async {
    await _socketSubscription?.cancel();
    await _socket?.close();
    _socket = null;
    _status = _Status.listening;
    notifyListeners();
  }

  @override
  dispose() async {
    _screenRefresher?.cancel();
    await _disconnect();
    await _serverSubscription?.cancel();
    await _server?.close();
    super.dispose();
  }
}
