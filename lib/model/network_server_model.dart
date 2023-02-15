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
  final bool forLocalTest;
  //
  int port;
  //
  ServerSocket? _server;
  Socket? _socket;
  StreamSubscription? _serverSubscription;
  StreamSubscription? _socketSubscription;
  Uint8List? _dtoBytes;
  int? _dtoLength;
  var _status = _Status.listening;
  var _bytesReceived = 0;
  //
  final _imageStreamController = StreamController<ImageDto>.broadcast();

  NetworkServerModel({this.forLocalTest = false}) : port = (!forLocalTest) ? LocalStorage.port : settings.defaultPort;

  @override
  Stream<ImageDto> get imageStream => _imageStreamController.stream;

  String get statusText => (_status == _Status.listening)
      ? 'listening $port ...'
      : 'connected from ${_socket?.remoteAddress.host}, received ${_bytesReceived ~/ 1000000} MB';

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
    Timer.periodic(Duration(seconds: 3), (_) => notifyListeners());
  }

  // Написано криво и наспех. Подумать над минимизацией аллокаций памяти + перенести в ImageDto.
  void _processBytes(Uint8List bytes) {
    try {
      // Log.info('RECEIVED ${bytes.length}');
      if (_dtoBytes == null) {
        _dtoBytes = bytes;
      } else {
        final bb = BytesBuilder();
        bb.add(_dtoBytes!);
        bb.add(bytes);
        _dtoBytes = bb.toBytes();
      }
      if (_dtoLength == null && _dtoBytes!.length >= 4) {
        _dtoLength = _dtoBytes!.buffer.asByteData(0, 4).getUint32(0);
      }
      if (_dtoLength != null) {
        if (_dtoBytes!.length > _dtoLength!) {
          _processDto(_dtoBytes!.sublist(0, _dtoLength!));
          final newDtoBytes = _dtoBytes!.sublist(_dtoLength!);
          _dtoBytes = null;
          _dtoLength = null;
          _processBytes(newDtoBytes);
        } else if (_dtoBytes!.length == _dtoLength!) {
          _processDto(_dtoBytes!);
          _dtoBytes = null;
          _dtoLength = null;
        }
      }
    } catch (e, s) {
      setError(e, s);
    }
  }

  void _processDto(Uint8List bytes) {
    _bytesReceived += bytes.length;
    // Log.info('PROCESSED ${bytes.length}');
    _imageStreamController.sink.add(ImageDto.fromBytes(bytes));
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
    await _disconnect();
    await _serverSubscription?.cancel();
    await _server?.close();
    super.dispose();
  }
}
