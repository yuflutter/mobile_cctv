import 'package:mobile_cctv/core/log.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '/core/abstract_model.dart';

class VideoStabilizationModel extends AbstractModel {
  void init() {
    accelerometerEvents.listen(
      (ev) {
        Log.info('${ev.x} - ${ev.y} - ${ev.z}');
      },
    );
    gyroscopeEvents.listen(
      (ev) {
        Log.info('${ev.x} - ${ev.y} - ${ev.z}');
      },
    );
  }
}
