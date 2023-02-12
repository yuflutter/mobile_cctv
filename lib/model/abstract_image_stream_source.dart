import 'package:flutter/widgets.dart';

import '/data/image_dto.dart';

abstract class AbstractImageStreamSource implements ChangeNotifier {
  Stream<ImageDto> get imageStream;
}
