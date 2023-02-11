import 'package:flutter/widgets.dart';

import '/core/log.dart';

abstract class AbstractModel with ChangeNotifier {
  bool _waiting = true;
  Object? _error;

  bool get waiting => _waiting;
  Object? get error => _error;

  void setWaiting() {
    _waiting = true;
    notifyListeners();
  }

  void setDone() {
    _waiting = false;
    notifyListeners();
  }

  void setError(Object e, [StackTrace? s]) {
    _waiting = false;
    _error = Log.error(e, s);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    _waiting = true;
    notifyListeners();
  }
}
