import '/core/abstract_model.dart';

class CameraScreensModel extends AbstractModel {
  bool _withoutPreview = false;

  bool get withoutPreview => _withoutPreview;
  set withoutPreview(bool v) {
    _withoutPreview = v;
    notifyListeners();
  }
}
